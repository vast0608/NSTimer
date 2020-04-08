//
//  FFWeakProxy.m
//  Test11111
//
//  Created by 张影 on 2020/4/3.
//  Copyright © 2020 张影. All rights reserved.
//

#import "FFWeakProxy.h"

@interface FFWeakProxy()
@property (nonatomic ,weak)id target;
@end

@implementation FFWeakProxy
+ (instancetype)proxyWithTarget:(id)target {
    //NSProxy实例方法为alloc
    FFWeakProxy *proxy = [FFWeakProxy alloc];
    proxy.target = target;
    return proxy;
}

/**
 这个函数让重载方有机会抛出一个函数的签名，再由后面的forwardInvocation:去执行
    为给定消息提供参数类型信息
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.target methodSignatureForSelector:sel];
}

/**
 *  NSInvocation封装了NSMethodSignature，通过invokeWithTarget方法将消息转发给其他对象。这里转发给控制器执行。
 */
- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.target];
}
@end
