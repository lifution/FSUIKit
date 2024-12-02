//
//  FSSystemInfoObjC.h
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/12/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSSystemInfoObjC : NSObject

/// cpu 使用率（百分比）
@property (class, nonatomic, readonly) float cpu_usage;

@end

NS_ASSUME_NONNULL_END
