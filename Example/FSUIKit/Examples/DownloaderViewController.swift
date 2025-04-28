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
    }
    
    @IBAction func startDownload(_ sender: Any) {
        startButton.isEnabled = false
//        progressLabel.isHidden = false
//        downloader.download(url: url) { total, received, progress in
//            self.progressLabel.text = String(format: "%.5f", progress)
//        } completion: { path, error in
//            self.startButton.isEnabled = true
//            self.progressLabel.isHidden = true
//            if let error {
//                FSToast.showError(error.localizedDescription)
//            } else if let _ = path {
//                FSToast.showSuccess("Download Success")
//            }
//        }
//        return;
        let urls: [String] = ["https://img.kitichat.com/20250401/17434977774778821.zip", "https://img.kitichat.com/20250401/17434976295771805.zip", "https://img.kitichat.com/20250402/17435605348908644.zip", "https://img.kitichat.com/20250402/17435611803546001.zip", "https://img.kitichat.com/20250402/17435760897076678.zip", "https://img.kitichat.com/20250402/17435757025802527.zip", "https://img.kitichat.com/20250402/17435761107176978.zip", "https://img.kitichat.com/20250401/17434973544696474.zip", "https://img.kitichat.com/20250401/17434977860776311.zip", "https://img.kitichat.com/20250402/17435756825395382.zip", "https://img.kitichat.com/20250402/17435762126388480.zip", "https://img.kitichat.com/20250401/17435126955027426.zip", "https://img.kitichat.com/20250402/17435760433402819.zip", "https://img.kitichat.com/20250402/17435609992922906.zip", "https://img.kitichat.com/20250402/17435624561611953.zip", "https://img.kitichat.com/20250402/17435757273761031.zip", "https://img.kitichat.com/20250401/17434976674696293.zip", "https://img.kitichat.com/20250402/17435758469280640.zip", "https://img.kitichat.com/20250401/17435132250716251.zip", "https://img.kitichat.com/20250401/17435129189622643.zip", "https://img.kitichat.com/20250402/17435605141129239.zip", "https://img.kitichat.com/20250416/17447689346362082.zip", "https://img.kitichat.com/20250402/17435755575815326.zip", "https://img.kitichat.com/20250402/17435604162600304.zip", "https://img.kitichat.com/20250402/17435745174744029.zip", "https://img.kitichat.com/20250402/17435604396281578.zip", "https://img.kitichat.com/20250402/17435623932012580.zip", "https://img.kitichat.com/20250402/17435756614691787.zip", "https://img.kitichat.com/20250402/17435604943778320.zip", "https://img.kitichat.com/20250402/17435608160299987.zip", "https://img.kitichat.com/20250402/17435760660910121.zip", "https://img.kitichat.com/20250401/17434973344313641.zip", "https://img.kitichat.com/20250402/17435623494722290.zip", "https://img.kitichat.com/20250402/17435759255174184.zip", "https://img.kitichat.com/20250402/17435759453873160.zip", "https://img.kitichat.com/20250402/17435755061943885.zip", "https://img.kitichat.com/20250401/17435131551964995.zip", "https://img.kitichat.com/20250402/17435761354335234.zip", "https://img.kitichat.com/20250401/17435128720398444.zip", "https://img.kitichat.com/20250401/17434973453327407.zip", "https://img.kitichat.com/20250402/17435757870791040.zip", "https://img.kitichat.com/20250401/17435124707529129.zip", "https://img.kitichat.com/20250401/17435124935825484.zip", "https://img.kitichat.com/20250402/17435623312319428.zip", "https://img.kitichat.com/20250402/17435625534475157.zip", "https://img.kitichat.com/20250402/17435625311469084.zip", "https://img.kitichat.com/20250401/17435126471228689.zip", "https://img.kitichat.com/20250401/17435124546672015.zip", "https://img.kitichat.com/20250402/17435744880154617.zip", "https://img.kitichat.com/20250402/17435760250379362.zip", "https://img.kitichat.com/20250401/17434973244878666.zip", "https://img.kitichat.com/20250401/17435127225952432.zip", "https://img.kitichat.com/20250402/17435603891174473.zip", "https://img.kitichat.com/20250401/17434976794396572.zip", "https://img.kitichat.com/20250402/17435624143110271.zip", "https://img.kitichat.com/20250401/17434975436383169.zip", "https://img.kitichat.com/20250402/17435603614848888.zip", "https://img.kitichat.com/20250402/17435758993581224.zip", "https://img.kitichat.com/20250402/17435759804272227.zip", "https://img.kitichat.com/20250401/17435125934150845.zip", "https://img.kitichat.com/20250402/17435762499891947.zip", "https://img.kitichat.com/20250401/17435126695789963.zip", "https://img.kitichat.com/20250402/17435609744345899.zip", "https://img.kitichat.com/20250402/17435762323084127.zip", "https://img.kitichat.com/20250402/17435626072140157.zip", "https://img.kitichat.com/20250401/17435126202880478.zip", "https://img.kitichat.com/20250401/17434976582144235.zip", "https://img.kitichat.com/20250402/17435755337966790.zip", "https://img.kitichat.com/20250402/17435623736962771.zip", "https://img.kitichat.com/20250402/17435758254485669.zip", "https://img.kitichat.com/20250402/17435760044571312.zip", "https://img.kitichat.com/20250401/17435125630230945.zip", "https://img.kitichat.com/20250402/17435754795714864.zip", "https://img.kitichat.com/20250402/17435757659545410.zip", "https://img.kitichat.com/20250402/17435611016494494.zip", "https://img.kitichat.com/20250402/17435756416584236.zip", "https://img.kitichat.com/20250402/17435744651467940.zip", "https://img.kitichat.com/20250402/17435609090160808.zip", "https://img.kitichat.com/20250401/17434976417893705.zip", "https://img.kitichat.com/20250401/17435124069372136.zip", "https://img.kitichat.com/20250402/17435605750352215.zip", "https://img.kitichat.com/20250402/17435611482331169.zip", "https://img.kitichat.com/20250401/17435128956689577.zip", "https://img.kitichat.com/20250402/17435624368224789.zip", "https://img.kitichat.com/20250401/17434975101338659.zip", "https://img.kitichat.com/20250402/17435625856200529.zip", "https://img.kitichat.com/20250402/17435758075915356.zip", "https://img.kitichat.com/20250401/17435124303081754.zip", "https://img.kitichat.com/20250416/17447676661694364.zip"]
        let group = DispatchGroup()
        urls.forEach { url in
            group.enter()
            downloader.download(url: url) { total, received, progress in
                fs_print("progress: [\(String(format: "%.5f", progress))]")
            } completion: { path, error in
                if let error {
                    fs_print(error.localizedDescription)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            fs_print("全部下载结束")
            self.startButton.isEnabled = true
        }
    }
}
