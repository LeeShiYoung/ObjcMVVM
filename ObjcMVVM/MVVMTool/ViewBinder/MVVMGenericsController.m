//
//  MVVMGenericsController.m
//  ObjcMVVM
//
//  Created by 李世洋 on 2019/6/9.
//  Copyright © 2019 _coderYoung. All rights reserved.
//

#import "MVVMGenericsController.h"
#import "ViewBinder.h"

@interface MVVMGenericsController ()

@end

@implementation MVVMGenericsController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)bindTransfrom {
    if ([self conformsToProtocol:@protocol(ViewBinder)] && [self respondsToSelector:@selector(bind:)]) {
        if ([self.viewModel conformsToProtocol:@protocol(ViewModelProtocol)]) {
            [((id <ViewBinder>)self) bind:self.viewModel];
        }
    }
}

@end
