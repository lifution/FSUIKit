//
//  FileDownloaderError.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/27.
//  Copyright © 2024 VincentLee. All rights reserved.
//

import UIKit

public enum FileDownloaderError: LocalizedError {
    
    case invalidURL
    case downloadFailed(Error)
    case saveFailed(Error)
    case cancelled
    case diskSpaceLow
    case unknown
    
    // 添加调试信息
    var debugInfo: [String: Any] {
        var info: [String: Any] = [
            "timestamp": Date().timeIntervalSince1970,
            "error_type": String(describing: self)
        ]
        
        switch self {
        case .invalidURL:
            break
        case .downloadFailed(let error):
            info["underlying_error"] = error
            if let nsError = error as NSError? {
                info["error_code"] = nsError.code
                info["error_domain"] = nsError.domain
            }
        case .saveFailed(let error):
            info["underlying_error"] = error
            if let nsError = error as NSError? {
                info["error_code"] = nsError.code
                info["error_domain"] = nsError.domain
            }
        case .cancelled:
            break
        case .diskSpaceLow:
            info["free_disk_space"] = "\(UIDevice.current.fs.storage.freeDiskSpaceInBytes)bytes"
        case .unknown:
            break
        }
        return info
    }
    
    // 支持多语言本地化
    private enum Localized {
        static let invalidURL = NSLocalizedString(
            "FSUIKit.FileDownloader.Error.InvalidURL",
            value: "无效的URL地址",
            comment: "Invalid URL error message"
        )
        
        static let downloadFailed = NSLocalizedString(
            "FSUIKit.FileDownloader.Error.DownloadFailed",
            value: "下载失败: %@",
            comment: "Download failed error message"
        )
        
        static let saveFailed = NSLocalizedString(
            "FSUIKit.FileDownloader.Error.SaveFailed",
            value: "文件保存失败: %@",
            comment: "Save failed error message"
        )
        
        static let cancelled = NSLocalizedString(
            "FSUIKit.FileDownloader.Error.Cancelled",
            value: "下载已取消",
            comment: "Download cancelled message"
        )
        
        static let diskSpaceLow = NSLocalizedString(
            "FSUIKit.FileDownloader.Error.DiskSpaceLow",
            value: "设备存储空间不足",
            comment: "Disk space low error message"
        )
        
        static let unknown = NSLocalizedString(
            "FSUIKit.FileDownloader.Error.Unknown",
            value: "未知错误",
            comment: "Unknown error message"
        )
    }
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return Localized.invalidURL
        case .downloadFailed(let error):
            return String(format: Localized.downloadFailed, error.localizedDescription)
        case .saveFailed(let error):
            return String(format: Localized.saveFailed, error.localizedDescription)
        case .cancelled:
            return Localized.cancelled
        case .diskSpaceLow:
            return Localized.diskSpaceLow
        case .unknown:
            return Localized.unknown
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .invalidURL:
            return "提供的URL格式不正确或为空"
        case .downloadFailed(let error):
            return "网络请求失败: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "文件系统操作失败: \(error.localizedDescription)"
        case .cancelled:
            return "用户取消了下载操作"
        case .diskSpaceLow:
            return "设备剩余存储空间不足以保存文件"
        case .unknown:
            return "发生了未知错误"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .invalidURL:
            return "请检查URL地址是否正确"
        case .downloadFailed:
            return "请检查网络连接后重试"
        case .saveFailed:
            return "请检查设备存储空间或文件访问权限"
        case .cancelled:
            return "如需下载，请重新开始下载任务"
        case .diskSpaceLow:
            return "请清理设备存储空间后重试"
        case .unknown:
            return "请稍后重试"
        }
    }
} 
