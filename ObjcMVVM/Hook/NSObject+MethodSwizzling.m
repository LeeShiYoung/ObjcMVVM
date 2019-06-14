//
//  NSObject+MethodSwizzling.m
//  MVVM_Demo
//
//  Created by 李世洋 on 2019/6/9.
//  Copyright © 2019 Y. All rights reserved.
//

#import "NSObject+MethodSwizzling.h"
#import <objc/message.h>

@implementation NSObject (MethodSwizzling)

+ (BOOL)hookOrigInstanceMenthod:(SEL)oriSEL newInstanceMenthod:(SEL)swizzledSEL {
    Class cls = self;
    Method oriMethod = class_getInstanceMethod(cls, oriSEL);
    Method swiMethod = class_getInstanceMethod(cls, swizzledSEL);
    
    if (!swiMethod) {
        return NO;
    }
    if (!oriMethod) {
        class_addMethod(cls, oriSEL, method_getImplementation(swiMethod), method_getTypeEncoding(swiMethod));
        method_setImplementation(swiMethod, imp_implementationWithBlock(^(id self, SEL _cmd){ }));
    }
    
    BOOL didAddMethod = class_addMethod(cls, oriSEL, method_getImplementation(swiMethod), method_getTypeEncoding(swiMethod));
    
    if (didAddMethod) {
        class_replaceMethod(cls, swizzledSEL, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    }else{
        method_exchangeImplementations(oriMethod, swiMethod);
    }
    return YES;
}

@end
