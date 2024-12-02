//
//  FileDownloader.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/27.
//  Copyright © 2024 VincentLee. All rights reserved.
//

import UIKit

public typealias FileDownloaderProgress = (_ total: Int64, _ received: Int64, _ progress: Double) -> Void
public typealias FileDownloaderCompletion = (_ path: String?, _ error: Error?) -> Void

open class FileDownloader: NSObject {
    
    public let cache: FileCache
    
    private let progressKeypath = "countOfBytesReceived"
    
    private var downloadTasks = [String: URLSessionDownloadTask]()
    private var progressHandlers = [String: [FileDownloaderProgress]]()
    private var completionHandlers = [String: [FileDownloaderCompletion]]()
    
    private lazy var session = URLSession(configuration: URLSessionConfiguration.default)
    
    /// path: 缓存路径
    /// 外部如果需要自定义路径可在初始化方法中传入对应的 path，
    /// 如果 path 为 nil 则使用默认的路径。
    public init(path: String?) {
        cache = FileCache(path: path)
        super.init()
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == progressKeypath else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        guard
            let task = object as? URLSessionDownloadTask,
            let url = task.currentRequest?.url?.absoluteString,
            !url.isEmpty
        else {
            return
        }
        if let handlers = progressHandlers[url], !handlers.isEmpty {
            let total = task.countOfBytesExpectedToReceive
            let received = task.countOfBytesReceived
            var progress = Double(received) / Double(total)
            if progress.isNaN {
                progress = 0.0
            }
            DispatchQueue.fs.asyncOnMainThread {
                handlers.forEach { $0(total, received, progress) }
            }
        }
    }
    
    /// 下载文件并缓存到本地沙盒，如果 URL 对应的文件已经存在缓存中则会直接回调。
    ///
    /// - Parameters:
    ///   - url:        文件的下载链接
    ///   - format:     文件的格式，在保存到沙盒时使用，可不传。
    ///   - progress:   下载进度，该 closure 会在下载任务结束后移除，使用者无需担心循环引用问题，如果已存在缓存则会返回 `(0, 0, 1.0)`，该 closure 总是会在主线程回调。
    ///   - completion: 结束回调，该 closure 会在下载任务结束后移除，使用者无需担心循环引用问题，该 closure 总是在主线程回调。
    ///
    open func download(
        url: String,
        format: String? = nil,
        progress: FileDownloaderProgress? = nil,
        completion: FileDownloaderCompletion? = nil
    ) {
        guard let downloadURL = URL(string: url) else {
            let error = NSError(domain: "com.fsuikitswift.filedownloader",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Invalid url"])
            DispatchQueue.fs.asyncOnMainThread {
                completion?(nil, error)
            }
            return
        }
        // 判断沙盒中是否有缓存，有缓存则直接回调完成 closure。
        if cache.fileExists(for: url, format: format), let path = cache.filePath(for: url, format: format) {
            fs_print("有缓存，使用缓存: [\(path)]")
            DispatchQueue.fs.asyncOnMainThread {
                progress?(0, 0, 1.0)
                completion?(path, nil)
            }
            return
        }
        // 正在下载中，添加 progress 和 completion 的「一对多」绑定。
        if let _ = downloadTasks[url] {
            // 更新 url 绑定的 progress 和 completion 回调。
            if let handler = completion {
                completionHandlers[url]?.append(handler)
            }
            if let handler = progress {
                progressHandlers[url]?.append(handler)
            }
            return
        }
        // 开始下载
        let task = session.downloadTask(with: downloadURL) { (location, response, error) in
            if let location = location {
                // 下载成功，转移到指定的缓存文件夹。
                self.cache.saveFile(at: location, for: url, format: format) { path, error in
                    self.completionHandlers[url]?.forEach { $0(path, error) }
                    // 缓存文件完成后再移除下载任务，否则下载的临时文件有可能在转移文件夹前就被删除了。
                    self.removeAllOperation(for: url)
                }
            } else {
                // 下载失败。
                DispatchQueue.main.async {
                    self.completionHandlers[url]?.forEach { $0(nil, error) }
                    self.removeAllOperation(for: url)
                }
            }
        }
        downloadTasks[url] = task
        progressHandlers[url] = []
        if let handler = progress {
            progressHandlers[url]?.append(handler)
        }
        completionHandlers[url] = []
        if let handler = completion {
            completionHandlers[url]?.append(handler)
        }
        startObservingProgress(for: url)
        task.resume()
    }
    
    open func cancelMission(for url: String) {
        removeAllOperation(for: url)
    }
    
    open func cancelAll() {
        let urls = downloadTasks.keys
        urls.forEach { removeAllOperation(for: $0) }
    }
}

private extension FileDownloader {
    
    func removeAllOperation(for url: String) {
        stopObservingProgress(for: url)
        if let task = downloadTasks[url] {
            task.cancel()
        }
        downloadTasks.removeValue(forKey: url)
        progressHandlers.removeValue(forKey: url)
        completionHandlers.removeValue(forKey: url)
    }
    
    func startObservingProgress(for url: String) {
        guard let task = downloadTasks[url] else {
            return
        }
        if let _ = task.observationInfo {
            task.removeObserver(self, forKeyPath: progressKeypath)
        }
        task.addObserver(self, forKeyPath: progressKeypath, options: [.initial, .new], context: nil)
    }
    
    func stopObservingProgress(for url: String) {
        guard let task = downloadTasks[url] else {
            return
        }
        if let _ = task.observationInfo {
            task.removeObserver(self, forKeyPath: progressKeypath)
        }
    }
}
