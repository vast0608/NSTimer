//
//  ViewController.m
//  Test11111
//
//  Created by 张影 on 2020/4/3.
//  Copyright © 2020 张影. All rights reserved.
//

#import "ViewController.h"
#import "AAAViewController.h"
@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50, 100, 100, 100)];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    
}

-(void)click {
    
    AAAViewController *vc = [[AAAViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    
}



@end
