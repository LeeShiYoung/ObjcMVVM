//
//  NSObject+MethodSwizzling.h
//  MVVM_Demo
//
//  Created by 李世洋 on 2019/6/9.
//  Copyright © 2019 Y. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MethodSwizzling)

+ (BOOL)hookOrigInstanceMenthod:(SEL)oriSEL newInstanceMenthod:(SEL)swizzledSEL;

@end

NS_ASSUME_NONNULL_END
