//
//  RightViewController.m
//  WYApp
//
//  Created by chen on 14-7-17.
//  Copyright (c) 2014年 chen. All rights reserved.
//

#import "RightViewController.h"

@implementation RightViewController

- (void)viewDidLoad
{
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height*0.4)];
    [headerV setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:headerV];
    
    UIButton *backbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backbtn setFrame:CGRectMake(20, 40, 60, 30)];
    [backbtn setTitle:@"返回" forState:UIControlStateNormal];
    [backbtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [backbtn setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
    backbtn.layer.borderWidth = 1;
    backbtn.layer.borderColor = [UIColor whiteColor].CGColor;
    backbtn.layer.masksToBounds = YES;
    backbtn.layer.cornerRadius = 6;
    [backbtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backbtn];
    
    // 头像
    _headImageView = [[UIImageView alloc] init];
    _headImageView.backgroundColor = [UIColor clearColor];
    _headImageView.frame = CGRectMake(self.view.center.x - 25, 44, 50, 50);
    _headImageView.layer.cornerRadius = _headImageView.frame.size.width/2;
    _headImageView.layer.borderWidth = 1.0;
    _headImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.image = [UIImage imageNamed:@"head1.jpg"];
    [headerV addSubview:_headImageView];
    _headImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] init];
    singleTapRecognizer.numberOfTapsRequired = 1;
    [singleTapRecognizer addTarget:self action:@selector(headPhotoAnimation)];
    [_headImageView addGestureRecognizer:singleTapRecognizer];
    
    UIView *middleV = [[UIView alloc] initWithFrame:CGRectMake(0, headerV.frame.size.height, headerV.frame.size.width, self.view.frame.size.height*0.5)];
    [middleV setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:middleV];
    
    NSArray *arD = @[@"商城", @"活动", @"应用", @"游戏"];
    float h = CGRectGetHeight(middleV.frame)/[arD count];
    float hh = 20;
    [arD enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop)
    {
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(40, h * idx + (h - hh)/2, 30, hh)];
        [l setText:obj];
        [l setBackgroundColor:[QHCommonUtil getRandomColor]];
        [l setTextColor:[UIColor whiteColor]];
        [l setFont:[UIFont systemFontOfSize:13]];
        [l setTextAlignment:NSTextAlignmentCenter];
        l.layer.masksToBounds = YES;
        l.layer.cornerRadius = 3;
        [middleV addSubview:l];
    }];
    
    UIImageView *lineIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) * 0.9, CGRectGetWidth(self.view.frame), 0.5)];
    [lineIV setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:lineIV];
    
    UIView *footV = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineIV.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(lineIV.frame))];
    [footV setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:footV];
}

- (void)headPhotoAnimation
{
    [self rotate360WithDuration:2.0 repeatCount:1];
    _headImageView.animationDuration = 2.0;
    _headImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"head1.jpg"],
                                      [UIImage imageNamed:@"head2.jpg"],[UIImage imageNamed:@"head2.jpg"],
                                      [UIImage imageNamed:@"head2.jpg"],[UIImage imageNamed:@"head2.jpg"],
                                      [UIImage imageNamed:@"head1.jpg"], nil];
    _headImageView.animationRepeatCount = 1;
    [_headImageView startAnimating];
}

- (void)rotate360WithDuration:(CGFloat)aDuration repeatCount:(CGFloat)aRepeatCount
{
	CAKeyframeAnimation *theAnimation = [CAKeyframeAnimation animation];
	theAnimation.values = [NSArray arrayWithObjects:
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0,1,0)],
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0,1,0)],
                           [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0,1,0)],
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(2*M_PI, 0,1,0)],
						   nil];
	theAnimation.cumulative = YES;
	theAnimation.duration = aDuration;
	theAnimation.repeatCount = aRepeatCount;
	theAnimation.removedOnCompletion = YES;
    
	[_headImageView.layer addAnimation:theAnimation forKey:@"transform"];
}

- (void)backAction:(id)sender
{
    [[QHSliderViewController sharedSliderController] closeSideBar];
}

@end
