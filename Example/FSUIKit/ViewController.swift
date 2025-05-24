//
//  ViewController.swift
//  FSUIKitSwift
//
//  Created by Sheng on 12/21/2023.
//  Copyright (c) 2023 Sheng. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit
import FSUIKitSwift

class ViewController: UITableViewController {
    
//    private let timer = FSTimer(timeInterval: 1.0)
    
    @IBOutlet weak var canvasView: UIView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            // FSMutexLock/FSUnfairLock 压力测试
            testLock()
        }
        
        do {
            let loader = FadingRingLoaderView(
                size: 100,
                lineWidth: 15,
                color: .systemBlue,
                fadeExponent: 2.5,
                sweepRatio: 0.95
            )
            canvasView.addSubview(loader)
            loader.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 100.0, height: 100.0))
            }
        }
        
//        timer.autoSuspendInBackground = false
//        timer.eventHandler = {
//            print("timer callback")
//        }
//        timer.resume()
        
//        do {
//            UIView.appearance().semanticContentAttribute = .forceRightToLeft
//            
//            let view = SwitchView()
//            view.isOn = true
//            view.onColor = .green
//            view.hitInsets = .fs.create(with: -10.0)
//            canvasView.addSubview(view)
//            view.snp.makeConstraints { make in
//                make.center.equalToSuperview()
//            }
//        }
        
//        do {
//            UIView.appearance().semanticContentAttribute = .forceRightToLeft
//
//            let button = FSButton()
//            button.setImage(UIImage(named: "gift"), for: .normal)
//            button.setTitle("Gifts", for: .normal)
//            button.setTitleColor(.black, for: .normal)
//            button.imagePosition = .left
//            button.spacingBetweenImageAndTitle = 5.0
//            button.backgroundColor = .cyan.withAlphaComponent(0.15)
//            canvasView.addSubview(button)
//            button.snp.makeConstraints { make in
//                make.center.equalToSuperview()
//            }
//        }
        
        do {
//            let label = UILabel()
//            label.text = "😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂"
//            label.font = UIFont.boldSystemFont(ofSize: 18.0)
//            label.textColor = .black
//            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//            navigationBar.titleView = label
            
//            navigationBar.title = "😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂"
//            navigationBar.leftItemViews = []
//            view.addSubview(navigationBar)
//            navigationBar.snp.makeConstraints { (make) in
//                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
//                make.left.right.equalTo(0.0)
//            }
        }
        do {
            /*
            let view = UIView()
            view.backgroundColor = .red
            
            let label = UILabel()
            label.text = "I'm a label"
            label.backgroundColor = .cyan
            
            let giftButton = FSButton()
            giftButton.backgroundColor = .cyan
            giftButton.setImage(UIImage(named: "gift"), for: .normal)
            
            navigationBar.rightItemViews = [view, label, giftButton]
            
            view.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 40.0, height: 40.0))
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                label.text = "Oh!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.navigationBar.rightItemViews = nil
                }
            }
             */
        }
//        do {
//            let toolBar = FSToolBar()
//            toolBar.backgroundView.backgroundColor = .yellow.withAlphaComponent(0.35)
//            view.addSubview(toolBar)
//            toolBar.snp.makeConstraints { make in
//                make.left.right.equalTo(0.0)
//                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
//            }
//        }
        
//        do {
//            let view = UIImageView()
//            canvasView.addSubview(view)
//            view.snp.makeConstraints { make in
//                make.size.equalTo(CGSize(width: 300.0, height: 150.0))
//                make.center.equalToSuperview()
//            }
//            view.image = GradientImageRenderer.render(.init(
//                size: .init(width: 300.0, height: 150.0),
//                colors: [.fs.colorWithHex(0xFC308C), .fs.colorWithHex(0x8771DE)],
//                locations: [0, 1],
//                direction: .leftToRight,
//                cornerRadius: 20.0))
//        }
    }
    
    func testLock() {
        print("开始并发测试...")
        
        // 测试1：并发计数
//        let lock = FSUnfairLock()
        let lock = FSMutexLock()
        var sharedValue = 0
        let iterations = 10000
        let concurrentThreads = 10
        
        let group = DispatchGroup()
        
        // 记录开始时间
        let startTime = Date()
        
        // 创建并发线程
        for _ in 0..<concurrentThreads {
            group.enter()
            DispatchQueue.global().async {
                for _ in 0..<iterations {
                    lock.withLock {
                        sharedValue += 1
                    }
                }
                group.leave()
            }
        }
        
        // 等待所有线程完成
        group.wait()
        
        // 计算耗时
        let timeElapsed = Date().timeIntervalSince(startTime)
        
        // 验证结果
        let expectedValue = iterations * concurrentThreads
        print("测试1 - 并发计数:")
        print("预期值: \(expectedValue)")
        print("实际值: \(sharedValue)")
        print("耗时: \(String(format: "%.3f", timeElapsed))秒")
        print("测试结果: \(sharedValue == expectedValue ? "通过" : "失败")")
        print("------------------------")
        
        // 测试2：并发读写数组
        var sharedArray: [Int] = []
        let arrayIterations = 1000
        let arrayThreads = 5
        
        // 重置计时器
        let arrayStartTime = Date()
        
        // 写入线程
        for i in 0..<arrayThreads {
            group.enter()
            DispatchQueue.global().async {
                for j in 0..<arrayIterations {
                    lock.withLock {
                        let value = i * arrayIterations + j
                        sharedArray.append(value)
                    }
                }
                group.leave()
            }
        }
        
        // 读取线程
        for _ in 0..<arrayThreads {
            group.enter()
            DispatchQueue.global().async {
                for _ in 0..<arrayIterations {
                    lock.withLock {
                        _ = sharedArray.count
                    }
                }
                group.leave()
            }
        }
        
        // 等待所有线程完成
        group.wait()
        
        // 计算耗时
        let arrayTimeElapsed = Date().timeIntervalSince(arrayStartTime)
        
        // 验证结果
        let expectedArrayCount = arrayIterations * arrayThreads
        
        print("\n测试2 - 并发读写数组:")
        print("预期数组长度: \(expectedArrayCount)")
        print("实际数组长度: \(sharedArray.count)")
        print("耗时: \(String(format: "%.3f", arrayTimeElapsed))秒")
        
        // 验证数据一致性
        let uniqueElements = Set(sharedArray)
        let hasDuplicates = uniqueElements.count != sharedArray.count
        let hasAllExpectedElements = uniqueElements.count == expectedArrayCount
        
        print("\n数据一致性分析:")
        print("唯一元素数量: \(uniqueElements.count)")
        print("是否有重复元素: \(hasDuplicates ? "是" : "否")")
        print("是否包含所有预期元素: \(hasAllExpectedElements ? "是" : "否")")
        
        // 验证元素范围
        let minValue = sharedArray.min() ?? 0
        let maxValue = sharedArray.max() ?? 0
        print("元素范围: \(minValue) - \(maxValue)")
        print("预期范围: 0 - \(expectedArrayCount - 1)")
        
        // 验证每个线程写入的元素是否存在
        var threadElementsExist = true
        for i in 0..<arrayThreads {
            let threadStart = i * arrayIterations
            let threadEnd = threadStart + arrayIterations - 1
            let threadElements = Set(threadStart...threadEnd)
            if !threadElements.isSubset(of: uniqueElements) {
                threadElementsExist = false
                print("线程 \(i) 的部分元素缺失")
            }
        }
        print("所有线程的元素是否都存在: \(threadElementsExist ? "是" : "否")")
        
        let testPassed = sharedArray.count == expectedArrayCount &&
                        !hasDuplicates &&
                        hasAllExpectedElements &&
                        threadElementsExist
        
        print("\n测试结果: \(testPassed ? "通过" : "失败")")
        print("------------------------")
    }
}

extension ViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}


class FadingRingLoaderView: UIView {
    private let ringLayer = CALayer()

    /// 自定义初始化
    init(size: CGFloat = 40,
         lineWidth: CGFloat = 4,
         color: UIColor = .systemBlue,
         fadeExponent: CGFloat = 2.5,
         sweepRatio: CGFloat = 0.85) {

        let frame = CGRect(x: 0, y: 0, width: size, height: size)
        super.init(frame: frame)
        isUserInteractionEnabled = false

        let image = FadingRingLoaderView.drawFadingRing(size: frame.size,
                                                        lineWidth: lineWidth,
                                                        startColor: color,
                                                        fadeExponent: fadeExponent,
                                                        sweepRatio: sweepRatio)
        ringLayer.contents = image.cgImage
        ringLayer.frame = bounds
        layer.addSublayer(ringLayer)

        startSpinning()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func startSpinning() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = 2 * CGFloat.pi
        animation.duration = 1.0
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        ringLayer.add(animation, forKey: "rotation")
    }

    // MARK: - Drawing Code
    static private func drawFadingRing(size: CGSize,
                                       lineWidth: CGFloat,
                                       startColor: UIColor,
                                       fadeExponent: CGFloat,
                                       sweepRatio: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2 - lineWidth / 2

        return renderer.image { ctx in
            let context = ctx.cgContext
            context.setLineCap(.round)
            context.setLineWidth(lineWidth)

            let segments = 200
            let startAngle = -CGFloat.pi / 2
            let sweepAngle = CGFloat.pi * 2 * sweepRatio
            let angleIncrement = sweepAngle / CGFloat(segments)

            for i in 0..<segments {
                let progress = CGFloat(i) / CGFloat(segments)
                let alpha = pow(1 - progress, fadeExponent) // 实色 -> 透明

                // ✅ 真正逆时针绘制
                let angle1 = startAngle - CGFloat(i) * angleIncrement
                let angle2 = angle1 - angleIncrement

                let path = UIBezierPath(arcCenter: center,
                                        radius: radius,
                                        startAngle: angle1,
                                        endAngle: angle2,
                                        clockwise: false)

                context.setStrokeColor(startColor.withAlphaComponent(alpha).cgColor)
                context.addPath(path.cgPath)
                context.strokePath()
            }
        }
    }
}
