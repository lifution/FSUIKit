//
//  FileCache.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/27.
//  Copyright © 2024 VincentLee. All rights reserved.
//

import UIKit

/// 文件缓存管理类
///
/// - Note:
///     * 该类仅适用于**同磁盘**下的操作，**跨磁盘**操作不建议使用该类。
///     * 该类仅适用于小量的操作，如果操作量特别大，比如成千上万，那么也不建议使用该类。
///     * 建议外部在主线程上调用该类的所有方法。
///
open class FileCache {
    
    /// 缓存所在路径
    public let path: String
    
    /// path: 缓存路径
    /// 外部如果需要自定义路径可在初始化方法中传入对应的 path，
    /// 如果 path 为 nil 或该路径不存在则使用默认的路径。
    public init(path: String?) {
        if let value = path, FileManager.default.fileExists(atPath: value) {
            self.path = value
        } else {
            self.path = {
                guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
                    #if DEBUG
                    fatalError()
                    #else
                    return ""
                    #endif
                }
                let folderPath = path + "/com_fsuikitswift_files"
                do {
                    try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true)
                    return folderPath
                } catch {
                    #if DEBUG
                    fatalError()
                    #else
                    return ""
                    #endif
                }
            }()
        }
        #if DEBUG
        if let _ = URL(string: self.path) {} else {
            fatalError("Invalid path")
        }
        #endif
    }
    
    /// 缓存文件在沙盒中的路径。
    ///
    /// - Parameters:
    ///   - key: 与文件对应的唯一标识符，一般使用文件的下载链接。
    ///   - format: 文件格式，可不传。
    ///
    /// - Returns:
    ///   - key 无效的话直接返回 nil。
    ///   - 如果存在对应的文件则返回对应的路径地址，否则返回 nil。
    ///
    open func filePath(for key: String, format: String? = nil) -> String? {
        let name = key.fs.toMD5()
        guard !name.isEmpty else {
            return nil
        }
        var path = path as NSString
        path = path.appendingPathComponent(name) as NSString
        if let format = format, !format.isEmpty, let result = path.appendingPathExtension(format) {
            path = result as NSString
        }
        return path as String
    }
    
    open func fileExists(for key: String, format: String? = nil) -> Bool {
        guard let path = filePath(for: key, format: format) else {
            return false
        }
        return FileManager.default.fileExists(atPath: path)
    }
    
    open func fileName(for key: String, format: String? = nil) -> String? {
        let name = key.fs.toMD5()
        guard !name.isEmpty else {
            return nil
        }
        if let format = format {
            return (name as NSString).appendingPathExtension(format)
        }
        return name
    }
    
    @discardableResult
    open func deleteFile(of key: String, format: String? = nil) -> Bool {
        guard let path = filePath(for: key, format: format) else {
            return false
        }
        do {
            /// 不用判断文件路径是否有效，如果该路径无效，会抛出异常进入 catch 方法。
            /// 不用预先判断文件是否存在，避免不必要的 I/O 操作。
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }
    
    /// 清除所有缓存文件（仅限当前设定的路径下的缓存文件）
    ///
    open func deleteAll(completion: (() -> Void)? = nil) {
        DispatchQueue.fs.asyncOnMainThread {
            do {
                let manager = FileManager.default
                let names = try manager.contentsOfDirectory(atPath: self.path)
                try names.forEach {
                    let filePath = (self.path as NSString).appendingPathComponent($0)
                    try manager.removeItem(atPath: filePath)
                }
                completion?()
            } catch {
                fs_print("FileCache deleteAll failed: [\(error.localizedDescription)]")
                completion?()
            }
        }
    }
    
    /// 缓存指定路径下的文件到 FileCache 设定的文件夹。
    /// 该方法是移动本地沙盒文件所用，一般配合 ``FileDownloader`` 一起使用。
    ///
    /// - Parameters:
    ///   - location:   文件所在沙盒路径。
    ///   - key:        与文件对应的唯一标识符，一般使用文件的下载链接。
    ///   - completion: 缓存结束回调，该 closure 始终会在主线程中回调。
    ///
    open func saveFile(at location: URL, for key: String, format: String? = nil, completion: ((_ path: String?, _ error: Error?) -> Void)?) {
        DispatchQueue.fs.asyncOnMainThread {
            guard let filePath = self.filePath(for: key, format: format) else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid key"])
                completion?(nil, error)
                return
            }
            do {
                try FileManager.default.moveItem(atPath: location.path, toPath: filePath)
                completion?(filePath, nil)
            } catch {
                completion?(nil, error)
            }
        }
    }
}
