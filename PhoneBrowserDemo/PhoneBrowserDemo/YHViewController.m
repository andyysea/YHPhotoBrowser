//
//  YHViewController.m
//  PhoneBrowserDemo
//
//  Created by junde on 2017/5/27.
//  Copyright © 2017年 junde. All rights reserved.
//

#import "YHViewController.h"
#import "OneViewController.h"

@interface YHViewController ()

@end

@implementation YHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.view.backgroundColor = [UIColor whiteColor];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [self.view addSubview:button];
    button.center = self.view.center;
    
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonClick:(UIButton *)button {
    
    [self.navigationController pushViewController:[OneViewController new] animated:YES];
}


@end
