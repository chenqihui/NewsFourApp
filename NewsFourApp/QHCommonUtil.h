//
//  QHCommonUtil.h
//  NewsFourApp
//
//  Created by chen on 14/8/9.
//  Copyright (c) 2014年 chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QHCommonUtil : NSObject

//将view转为image
+ (UIImage *)getImageFromView:(UIView *)view;

//获取随机颜色color
+ (UIColor *)getRandomColor;

//根据比例（0...1）在min和max中取值
+ (float)lerp:(float)percent min:(float)nMin max:(float)nMax;

@end
