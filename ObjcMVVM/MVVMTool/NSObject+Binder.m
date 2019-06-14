//
//  NSObject+Binder.m
//  ETown
//
//  Created by 李世洋 on 2019/5/17.
//  Copyright © 2019 米一米. All rights reserved.
//

#import "NSObject+Binder.h"
#import <KVOController/KVOController.h>
#import <objc/message.h>

@implementation NSObject (Binder)

- (void)bind:(NSString *)sourceKeyPath to:(id)target at:(NSString *)targetKeyPath {
    
    [self.KVOController observe:self keyPath:sourceKeyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        
        id newValue = change[NSKeyValueChangeNewKey];
   
        if ([self verification:newValue]) {
            [target setValue:newValue forKey:targetKeyPath];
        }
    }];
}

- (void)bind:(NSString *)sourceKeyPath bindHandler:(BindHandler)handler {
    [self.KVOController observe:self keyPath:sourceKeyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        
        id newValue = change[NSKeyValueChangeNewKey];
      
        if ([self verification:newValue]) {
            handler(newValue);
        }
    }];
}

- (void)bind:(NSString *)sourceKeyPath to:(id)target selector:(SEL)sel {
    [self.KVOController observe:self keyPath:sourceKeyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        
        id newValue = change[NSKeyValueChangeNewKey];
        if ([self verification:newValue]) {
            objc_msgSend(target, sel, newValue);
        }
        
    }];
}


- (BOOL)verification:(id)newValue {
    if ([newValue isEqual: [NSNull null]]) {
        return NO;
    }
    return YES;
}

@end
