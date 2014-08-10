//
//  MLTransitionAnimation.m
//  MLTransitionNavigationController
//
//  Created by molon on 6/29/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import "MLTransitionAnimation.h"

//通常意义上的动画时间
#define kMLTransitionConstant_TransitionDuration 0.25f

//左VC移动的长度和其整个宽度的比例
#define kMLTransitionConstant_LeftVC_Move_Ratio_Of_Width 0.29f

//阴影相关
#define kMLTransitionConstant_RightVC_ShadowOffset_Width (-0.4f)
#define kMLTransitionConstant_RightVC_ShadowRadius 3.0f
#define kMLTransitionConstant_RightVC_ShadowOpacity 0.3f


@implementation MLTransitionAnimation

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    //可以理解为是动画进行中的view容器,当前fromVC.view已经在容器里了,但是toVC.view没有
    UIView *containerView = [transitionContext containerView];
    
    //设置阴影
    UIViewController *vc = nil;
    if (self.type==MLTransitionAnimationTypePush) {
        vc = toVC;
    }else{
        vc = fromVC;
    }
    vc.view.layer.shadowColor = [UIColor blackColor].CGColor;
    vc.view.layer.shadowOffset = CGSizeMake(kMLTransitionConstant_RightVC_ShadowOffset_Width,0);
    vc.view.layer.shadowRadius = kMLTransitionConstant_RightVC_ShadowRadius;
    vc.view.layer.shadowOpacity = kMLTransitionConstant_RightVC_ShadowOpacity;
    
    if (self.type==MLTransitionAnimationTypePush) {
        //添加到容器View
        [containerView insertSubview:toVC.view aboveSubview:fromVC.view];
        //从右边推进来
        toVC.view.transform = CGAffineTransformMakeTranslation(toVC.view.frame.size.width, 0);
    }else{
        //放进容器
        [containerView insertSubview:toVC.view belowSubview:fromVC.view];
        //设置初始值
        toVC.view.transform = CGAffineTransformMakeTranslation(-toVC.view.frame.size.width*kMLTransitionConstant_LeftVC_Move_Ratio_Of_Width, 0);
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        if (self.type == MLTransitionAnimationTypePush) {
            fromVC.view.transform = CGAffineTransformMakeTranslation(-fromVC.view.frame.size.width*kMLTransitionConstant_LeftVC_Move_Ratio_Of_Width, 0); //向左移10分之3的宽度位置
        }else{
            fromVC.view.transform = CGAffineTransformMakeTranslation(fromVC.view.frame.size.width, 0);
        }
        toVC.view.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        vc.view.layer.shadowOpacity = 0.0f;
        
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        
        
        fromVC.view.transform = CGAffineTransformIdentity; //重置回来,两个都重置是因为动画可能会被取消
        toVC.view.transform = CGAffineTransformIdentity;
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    //设置一个动画时间。
    return kMLTransitionConstant_TransitionDuration;
}



@end
