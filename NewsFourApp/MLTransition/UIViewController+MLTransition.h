//
//  UIViewController+MLTransition.h
//  MLTransitionNavigationController
//
//  Created by molon on 6/28/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MLTransitionGestureRecognizerTypePan, //拖动模式
	MLTransitionGestureRecognizerTypeScreenEdgePan, //边界拖动模式
} MLTransitionGestureRecognizerType;

@interface UIViewController (MLTransition)<UINavigationControllerDelegate>

+ (void)validatePanPackWithMLTransitionGestureRecognizerType:(MLTransitionGestureRecognizerType)type;

@end
