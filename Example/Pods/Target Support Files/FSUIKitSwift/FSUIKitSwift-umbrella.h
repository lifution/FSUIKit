#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "UIApplication+FSUIKitSwiftHook.h"

FOUNDATION_EXPORT double FSUIKitSwiftVersionNumber;
FOUNDATION_EXPORT const unsigned char FSUIKitSwiftVersionString[];

