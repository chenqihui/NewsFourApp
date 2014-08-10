//
//  SubViewController.h
//  testMyBackNavigation
//
//  Created by chen on 14-3-25.
//  Copyright (c) 2014年 User. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubViewController : UIViewController

@property (nonatomic, strong) NSString *szSignal;

- (id)initWithFrame:(CGRect)frame andSignal:(NSString *)szSignal;

@end
