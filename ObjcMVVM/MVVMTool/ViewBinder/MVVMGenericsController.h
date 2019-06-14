//
//  MVVMGenericsController.h
//  ObjcMVVM
//
//  Created by 李世洋 on 2019/6/9.
//  Copyright © 2019 _coderYoung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewBinder.h"
#import "ViewModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MVVMGenericsController<ViewModelType: id<ViewModelProtocol>> : UIViewController

@property (nonatomic, strong) ViewModelType viewModel;

@end

NS_ASSUME_NONNULL_END
