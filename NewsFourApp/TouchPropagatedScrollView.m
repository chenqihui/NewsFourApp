//
//  TouchPropagatedScrollView.m
//
//  Created by chen on 14/7/13.
//  Copyright (c) 2014年 chen. All rights reserved.
//

#import "TouchPropagatedScrollView.h"

@implementation TouchPropagatedScrollView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
	return YES;
}

@end
