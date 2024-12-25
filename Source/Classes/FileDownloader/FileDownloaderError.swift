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
            value: "Invalid URL address",
            comment: "Invalid URL error message"
        )
        
        static let downloadFailed = NSLocalizedString(
            "FSUIKit.FileDownloader.Error.DownloadFailed",
            value: "Download failed: %@",
            comment: "Download failed error message"
        )
        
        static let saveFailed = NSLocalizedString(
            "FSUIKit.FileDownloader.Error.SaveFailed",
            value: "File save failed: %@",
            comment: "Save failed error message"
        )
        
        static let cancelled = NSLocalizedString(
            "FSUIKit.FileDownloader.Error.Cancelled",
            value: "Download cancelled",
            comment: "Download cancelled message"
        )
        
        static let diskSpaceLow = NSLocalizedString(
            "FSUIKit.FileDownloader.Error.DiskSpaceLow",
            value: "Insufficient device storage space",
            comment: "Disk space low error message"
        )
        
        static let unknown = NSLocalizedString(
            "FSUIKit.FileDownloader.Error.Unknown",
            value: "Unknown error",
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
            return "The provided URL is either in an incorrect format or empty."
        case .downloadFailed(let error):
            return "Network request failed: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "File system operation failed: \(error.localizedDescription)"
        case .cancelled:
            return "The download operation was cancelled by the user."
        case .diskSpaceLow:
            return "Insufficient storage space on the device to save the file."
        case .unknown:
            return "An unknown error occurred."
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .invalidURL:
            return "Please check if the URL is correct."
        case .downloadFailed:
            return "Please check your network connection and try again."
        case .saveFailed:
            return "Please check your device's storage space or file access permissions."
        case .cancelled:
            return "If you need to download, please restart the download task."
        case .diskSpaceLow:
            return "Please clear your device's storage space and try again."
        case .unknown:
            return "Please try again later."
        }
    }
} 
