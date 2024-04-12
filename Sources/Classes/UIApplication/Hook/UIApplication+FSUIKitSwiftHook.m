//
//  UIApplication+FSUIKitSwiftHook.m
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/19.
//  Copyright © 2024 Sheng. All rights reserved.
//

#import "UIApplication+FSUIKitSwiftHook.h"
#import <FSUIKitSwift/FSUIKitSwift-Swift.h>

@implementation UIApplication (FSUIKitSwiftHook)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [FSUIApplicationLoader activate];
    });
}

@end
