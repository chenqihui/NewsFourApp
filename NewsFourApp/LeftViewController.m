//
//  LeftViewController.m
//  WYApp
//
//  Created by chen on 14-7-17.
//  Copyright (c) 2014年 chen. All rights reserved.
//

#import "LeftViewController.h"

#import "SubViewController.h"

@interface LeftViewController ()
{
    NSArray *_arData;
}

@end

@implementation LeftViewController

- (void)viewDidLoad
{
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    _arData = @[@"新闻", @"订阅", @"图片", @"视频", @"跟帖", @"电台"];
    
    UIButton *toNewViewbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [toNewViewbtn setFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 170, CGRectGetHeight(self.view.frame) - 60, 60, 30)];
    [toNewViewbtn setTitle:@"新页面" forState:UIControlStateNormal];
    [toNewViewbtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [toNewViewbtn setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
    [toNewViewbtn addTarget:self action:@selector(toNewViewbtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:toNewViewbtn];
    
    __block float h = self.view.frame.size.height*0.7/[_arData count];
    __block float y = 0.15*self.view.frame.size.height;
    [_arData enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop)
    {
        UIView *listV = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, h)];
        [listV setBackgroundColor:[UIColor clearColor]];
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, listV.frame.size.width - 60, listV.frame.size.height)];
        [l setFont:[UIFont systemFontOfSize:20]];
        [l setTextColor:[UIColor whiteColor]];
        [l setBackgroundColor:[UIColor clearColor]];
        [l setText:obj];
        [listV addSubview:l];
        [self.view addSubview:listV];
        y += h;
        
        UITapGestureRecognizer *tapGestureRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backAction:)];
        [listV addGestureRecognizer:tapGestureRec];
    }];
}

- (void)backAction:(id)sender
{
    [[QHSliderViewController sharedSliderController] closeSideBar];
}

- (void)toNewViewbtn:(UIButton *)btn
{
//    [[QHSliderViewController sharedSliderController] closeSideBarWithAnimate:YES complete:^(BOOL finished)
//    {
//    }];
    SubViewController *subViewController = [[SubViewController alloc] initWithFrame:[UIScreen mainScreen].bounds andSignal:@"new view"];
    
    [[QHSliderViewController sharedSliderController].navigationController pushViewController:subViewController animated:YES];
}

@end
