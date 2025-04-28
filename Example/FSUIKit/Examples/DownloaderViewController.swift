//
//  DownloaderViewController.swift
//  FSUIKit_Example
//
//  Created by VincentLee on 2024/11/28.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit
import FSUIKitSwift

final class DownloaderViewController: FSViewController {
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    private let downloader = {
        let document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let path = document + "/kiti_gift"
        try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
        return FileDownloader(path: path)
    }()
    
    private let url = "https://dldir1.qq.com/qqfile/qq/PCQQ9.7.17/QQ9.7.17.29225.exe"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressLabel.font = .monospacedDigitSystemFont(ofSize: 20.0, weight: .medium)
        progressLabel.isHidden = true
        downloader.cache.deleteAll()
        startButton.fs.title("Start Download", for: .normal)
    }
    
    @IBAction func startDownload(_ sender: Any) {
        startButton.isEnabled = false
        progressLabel.isHidden = false
        downloader.download(url: url) { total, received, progress in
            self.progressLabel.text = String(format: "%.5f", progress)
        } completion: { path, error in
            self.startButton.isEnabled = true
            self.progressLabel.isHidden = true
            if let error {
                FSToast.showError(error.localizedDescription)
            } else if let _ = path {
                FSToast.showSuccess("Download Success")
            }
        }
    }
}
