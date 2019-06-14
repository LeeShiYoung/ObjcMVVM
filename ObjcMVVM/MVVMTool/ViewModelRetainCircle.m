//
//  ViewModelRetainCircle.m
//  ETown
//
//  Created by 李世洋 on 2019/6/14.
//  Copyright © 2019 米一米. All rights reserved.
//

#import "ViewModelRetainCircle.h"
#import "NSObject+MethodSwizzling.h"
#import "ViewModelProtocol.h"
#import "MVVMGenericsController.h"
#import <objc/Runtime.h>
#import <KVOController/KVOController.h>


const void* const kIsCallPop = &kIsCallPop;

@implementation UIViewController (RetainCircle)

+ (void)load {
    [self hookOrigInstanceMenthod:@selector(viewDidDisappear:) newInstanceMenthod:@selector(mvvm_viewDidDisappear:)];
}


- (void)mvvm_viewDidDisappear:(BOOL)animated {
    [self mvvm_viewDidDisappear:animated];
    
    if ([objc_getAssociatedObject(self, kIsCallPop) boolValue]) {
        if ([self isKindOfClass:[MVVMGenericsController class]] && [((MVVMGenericsController *)self).viewModel conformsToProtocol:@protocol(ViewModelProtocol)]) {
            NSObject *vm = ((MVVMGenericsController *)self).viewModel;
            [vm.KVOController unobserveAll];
        }
    }
}


@end

@implementation UINavigationController (RetainCircle)

+ (void)load {
    [self hookOrigInstanceMenthod:@selector(popViewControllerAnimated:) newInstanceMenthod:@selector(mvvm_popViewControllerAnimated:)];
}

- (UIViewController *)mvvm_popViewControllerAnimated:(BOOL)animated {
    UIViewController* popViewController = [self mvvm_popViewControllerAnimated:animated];
    objc_setAssociatedObject(popViewController, kIsCallPop, @(YES), OBJC_ASSOCIATION_RETAIN);
    return popViewController;
}

@end
