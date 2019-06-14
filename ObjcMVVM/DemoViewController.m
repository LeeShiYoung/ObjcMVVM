//
//  DemoViewController.m
//  ObjcMVVM
//
//  Created by 李世洋 on 2019/6/9.
//  Copyright © 2019 _coderYoung. All rights reserved.
//

#import "DemoViewController.h"
#import "NSObject+Binder.h"

@interface DemoViewController ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.titleLabel];
    self.titleLabel.frame = CGRectMake(0, 0, 375, 50);
    self.titleLabel.center = self.view.center;
    
}

- (void)bind:(DemoViewModel *)viewModel {

    [viewModel bind:@"title" to:self.titleLabel at:@"text"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.viewModel changeTitle];
}

- (void)dealloc {
    NSLog(@"Controller dealloc");
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor redColor];
        _titleLabel.font = [UIFont systemFontOfSize:40];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
@end
