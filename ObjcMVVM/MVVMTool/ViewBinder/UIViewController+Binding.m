//
//  UIViewController+Binding.m
//  MVVM_Demo
//
//  Created by 李世洋 on 2019/6/9.
//  Copyright © 2019 Y. All rights reserved.
//

#import "UIViewController+Binding.h"
#import "NSObject+MethodSwizzling.h"
#import <objc/message.h>
#import "MVVMGenericsController.h"

static const UInt8 kIsAlreadyBind = 0;

@interface UIViewController()

@property (nonatomic, assign) BOOL isAlreadyBind;

@end

@implementation UIViewController (Binding)

+ (void)load {
    [self hookOrigInstanceMenthod:@selector(viewWillAppear:) newInstanceMenthod:@selector(mvvm_viewWillAppear:)];
}

- (void)mvvm_viewWillAppear:(BOOL)animated {
    
    if (!self.isAlreadyBind) {
        if ([self isKindOfClass:[MVVMGenericsController class]]) {
            objc_msgSend((MVVMGenericsController *)self, @selector(bindTransfrom));
        }
        
        self.isAlreadyBind = YES;
    }
    
    [self mvvm_viewWillAppear:animated];
}

- (void)setIsAlreadyBind:(BOOL)isAlreadyBind {
    objc_setAssociatedObject(self, &kIsAlreadyBind, @(isAlreadyBind), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isAlreadyBind {
    return !(objc_getAssociatedObject(self, &kIsAlreadyBind) == nil);
}

- (void)bindTransfrom {}


@end
