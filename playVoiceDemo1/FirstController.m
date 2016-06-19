//
//  FirstController.m
//  playVoiceDemo1
//
//  Created by 张智勇 on 16/4/1.
//  Copyright © 2016年 张智勇. All rights reserved.
//

#import "FirstController.h"
#import "ViewController.h"

@implementation FirstController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIButton *comeInButton = [[UIButton alloc]initWithFrame:CGRectMake(120, 200, 160, 40)];
    comeInButton.center = self.view.center;
    [comeInButton setTitle:@"进入录音界面" forState:UIControlStateNormal];
    [comeInButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [comeInButton addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:comeInButton];
}

- (void)pop{
    ViewController *viewController = [[ViewController alloc]init];
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
