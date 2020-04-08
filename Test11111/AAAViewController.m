//
//  AAAViewController.m
//  Test11111
//
//  Created by 张影 on 2020/4/3.
//  Copyright © 2020 张影. All rights reserved.
//

#import "AAAViewController.h"
#import "FFProxy.h"
#import "FFWeakProxy.h"

@interface AAAViewController ()
@property(nonatomic, strong)NSTimer *timer;

@property (nonatomic, strong) NSThread *thread;
@property (assign, nonatomic) BOOL stopTimer;

@property(nonatomic,strong)dispatch_source_t gcdTimer;
@end

@implementation AAAViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    #warning mark - 注意⚠️：用的时候要根据提示打开dealloc中的方法
    
    //---------------------默认主线程中创建定时器----------------------
    
    //采用中间对象法解决
    [self setFFProxyMethod];
    
    //采用中间代理法解决
    //[self setFFWeakProxyMethod];
    
    //采用block法解决（iOS 10以后才能使用）
    //[self setBlockMethod];
    
    //---------------------子线程中创建定时器----------------------
    
    //NSThread新开辟线程（子线程）创建和销毁timer
    //[self setNSThreadMethod];
    
    //纯CGD子线程创建定时器
    //[self setGCDMethod];
}



//---------------------默认主线程中创建定时器----------------------

#pragma mark - 采用中间对象法解决
- (void)setFFProxyMethod {
    //repeats设为YES时，采用继承于NSObject的中间对象法解决循环引用问题
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:[FFProxy proxyWithTarget:self] selector:@selector(timerRun) userInfo:nil repeats:YES];

    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

#pragma mark - 采用中间代理法解决
- (void)setFFWeakProxyMethod {
    //repeats设为YES时，采用继承于NSProxy的中间代理法解决循环引用问题
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:[FFWeakProxy proxyWithTarget:self] selector:@selector(timerRun) userInfo:nil repeats:YES];

    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

#pragma mark - 采用block法解决（iOS 10以后才能使用）
- (void)setBlockMethod {
    //repeats设置为YES，NSTimer采用block方式进行调用（该方法在iOS 10新增方法）但要注意block体内的循环引用问题
    
    //__weak __typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"%s", __func__);
    }];

    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}


//---------------------子线程中创建定时器----------------------
/*

#pragma mark - GCD创建子线程+NSTimer创建定时器
//子线程创建timer
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    //由于放在了子线程，不用担心线程阻塞而造成push卡顿
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        weakSelf.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:weakSelf selector:@selector(timerRun) userInfo:nil repeats:YES];
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [runloop addTimer:weakSelf.timer forMode:NSDefaultRunLoopMode];
        [runloop run];
    });

}

//子线程销毁timer
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [weakSelf.timer invalidate];
        weakSelf.timer = nil;
    });
}

 */
 
#pragma mark - NSThread新开辟线程（子线程）创建和销毁timer
- (void)setNSThreadMethod {
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:[FFProxy proxyWithTarget:self] selector:@selector(timerRun) userInfo:nil repeats:YES] ;
    //开辟新线程
    __weak typeof(self) weakSelf = self;
    self.thread = [[NSThread alloc] initWithBlock:^{//(iOS 10有效)
        [[NSRunLoop currentRunLoop] addTimer:weakSelf.timer forMode:NSDefaultRunLoopMode];
        //通过run方法开启的RunLoop是无法停止的，但在控制器pop的时候，需要将timer，子线程，子线程的RunLoop停止和销毁，因此需要通过while循环和runMode: beforeDate:来运行RunLoop
        while (weakSelf && !weakSelf.stopTimer) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }];
    [self.thread start];
}

// 用于停止子线程的RunLoop
- (void)stopThread {
    // 设置标记为YES
    self.stopTimer = YES;
    // 停止RunLoop
    CFRunLoopStop(CFRunLoopGetCurrent());
    // 清空线程
    self.thread = nil;
}


#pragma mark - 纯CGD子线程创建定时器
- (void)setGCDMethod{
    NSTimeInterval start = 0.0;//开始时间
    NSTimeInterval interval = 1.0;//时间间隔
    //创建一个 time 并放到队列中
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    //首次执行时间 间隔时间 时间精度
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"%s", __func__);
    });
    //需要强引用否则 time会销毁,无法继续执行
    self.gcdTimer = timer;
    //激活 timer
    dispatch_resume(self.gcdTimer);
}
//---------------------公共调用方法----------------------


- (void)timerRun {
    NSLog(@"%s", __func__);
}

//销毁
-(void)dealloc{

    //采用中间对象、中间代理、block方法时打开timer销毁方法
    [self.timer invalidate];
    self.timer = nil;

    //采用NSThread打开
    //[self performSelector:@selector(stopThread) onThread:self.thread withObject:nil waitUntilDone:YES];
    
    //采用纯GCD子线程的需要打开
    //dispatch_source_cancel(self.gcdTimer);

    NSLog(@"%s", __func__);

}



@end
