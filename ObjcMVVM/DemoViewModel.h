//
//  DemoViewModel.h
//  ObjcMVVM
//
//  Created by 李世洋 on 2019/6/9.
//  Copyright © 2019 _coderYoung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DemoViewModel : NSObject<ViewModelProtocol>

- (void)changeTitle;

@property (nonatomic, copy, readonly) NSString *title;

@property (nonatomic, copy, readonly) NSArray *titleArray;

@end


@interface DemoViewModel(Random)

-(NSInteger)randomFloatBetween:(float)num1 andLargerFloat:(float)num2;

@end

NS_ASSUME_NONNULL_END
