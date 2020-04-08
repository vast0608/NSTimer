//
//  FFProxy.m
//  Test11111
//
//  Created by 张影 on 2020/4/3.
//  Copyright © 2020 张影. All rights reserved.
//

//FFProxy.m
#import "FFProxy.h"

@interface FFProxy()
@property (nonatomic ,weak) id target;
@end

@implementation FFProxy

+(instancetype)proxyWithTarget:(id)target
{
    FFProxy *proxy = [[FFProxy alloc] init];
    proxy.target = target;
    return proxy;
}

//仅仅添加了weak类型的属性还不够，为了保证中间件能够响应外部self的事件，需要通过消息转发机制，让实际的响应target还是外部self，这一步至关重要，主要涉及到runtime的消息机制。
-(id)forwardingTargetForSelector:(SEL)aSelector
{
    return self.target;
}
@end
