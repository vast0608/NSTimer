//
//  FFWeakProxy.h
//  Test11111
//
//  Created by 张影 on 2020/4/3.
//  Copyright © 2020 张影. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FFWeakProxy : NSProxy
+ (instancetype)proxyWithTarget:(id)target;
@end

NS_ASSUME_NONNULL_END
