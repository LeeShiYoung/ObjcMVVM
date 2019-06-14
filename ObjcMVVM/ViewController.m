//
//  ViewController.m
//  ObjcMVVM
//
//  Created by 李世洋 on 2019/6/9.
//  Copyright © 2019 _coderYoung. All rights reserved.
//

#import "ViewController.h"
#import "ViewBinder.h"
#import "DemoViewController.h"
#import "DemoViewModel.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];

}
- (IBAction)buttonAction:(UIButton *)sender {
    DemoViewController *controller = [[DemoViewController alloc] init];
    controller.viewModel = [DemoViewModel new];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
