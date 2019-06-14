//
//  DemoViewModel.m
//  ObjcMVVM
//
//  Created by 李世洋 on 2019/6/9.
//  Copyright © 2019 _coderYoung. All rights reserved.
//

#import "DemoViewModel.h"
#import "ViewModelProtocol.h"

@interface DemoViewModel()

@property (nonatomic, copy, readwrite) NSString *title;

@end

@implementation DemoViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _titleArray = @[@"MVC", @"MVVM", @"SWift", @"ReactNative"];
        _title = _titleArray[1];
    }
    return self;
}

- (void)changeTitle {
    
    self.title = _titleArray[[self randomFloatBetween:0 andLargerFloat:4]];
}

- (void)dealloc {
    NSLog(@"ViewModel dealloc");
}

@end

// Extension
@implementation DemoViewModel(Random)

-(NSInteger)randomFloatBetween:(float)num1 andLargerFloat:(float)num2
{
    int startVal = num1*10000;
    int endVal = num2*10000;
    
    int randomValue = startVal +(arc4random()%(endVal - startVal));
    float a = randomValue;
    
    return (NSInteger)(a /10000.0);
}


@end
