//
//  FFProxy.h
//  Test11111
//
//  Created by 张影 on 2020/4/3.
//  Copyright © 2020 张影. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FFProxy : NSObject

//公开类方法
+(instancetype)proxyWithTarget:(id)target;

@end

NS_ASSUME_NONNULL_END
