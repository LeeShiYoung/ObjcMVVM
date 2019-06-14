//
//  ViewBinder.h
//  ObjcMVVM
//
//  Created by 李世洋 on 2019/6/9.
//  Copyright © 2019 _coderYoung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ViewBinder <NSObject>

- (void)bind:(id<ViewModelProtocol>)viewModel; // id -> viewModel

@end

NS_ASSUME_NONNULL_END
