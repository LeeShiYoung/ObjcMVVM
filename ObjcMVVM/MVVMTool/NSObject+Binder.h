//
//  NSObject+Binder.h
//  ETown
//
//  Created by 李世洋 on 2019/5/17.
//  Copyright © 2019 米一米. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^BindHandler)(id value);

@class FBKVOController;
@interface NSObject (Binder)

- (void)bind: (NSString * _Nullable)sourceKeyPath to:(id)target at:(NSString * _Nullable)targetKeyPath;

- (void)bind: (NSString * _Nullable)sourceKeyPath bindHandler: (BindHandler)handler;

- (void)bind: (NSString * _Nullable)sourceKeyPath to:(id)target selector:(SEL)sel;

@end

NS_ASSUME_NONNULL_END
