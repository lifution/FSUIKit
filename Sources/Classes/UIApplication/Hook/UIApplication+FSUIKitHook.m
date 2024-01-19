//
//  UIApplication+FSUIKitHook.m
//  FSUIKit
//
//  Created by Sheng on 2024/1/19.
//  Copyright © 2024 Sheng. All rights reserved.
//

#import "UIApplication+FSUIKitHook.h"
#import <FSUIKit/FSUIKit-Swift.h>

@implementation UIApplication (FSUIKitHook)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [FSUIApplicationLoader activate];
    });
}

@end
