//
//  UIViewController+MLTransition.m
//  MLTransitionNavigationController
//
//  Created by molon on 6/28/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import "UIViewController+MLTransition.h"
#import <objc/runtime.h>
#import "MLTransitionAnimation.h"

//有效的向右拖动的最小速率，即为大于这个速率就认为想返回上一页罢了
#define kMLTransitionConstant_Valid_MIN_Velocity 300.0f

NSString * const kMLTransition_PercentDrivenInteractivePopTransition = @"__MLTransition_PercentDrivenInteractivePopTransition";

NSString * const kMLTransition_GestureRecognizer = @"__MLTransition_GestureRecognizer";

NSString * const kMLTransition_ViewController_OfPan = @"__MLTransition_ViewController_OfPan";

//设置一个默认的全局使用的type
static MLTransitionGestureRecognizerType __MLTransitionGestureRecognizerType = MLTransitionGestureRecognizerTypePan;

//静态就交换静态，实例方法就交换实例方法
void __MLTransition_Swizzle(Class c, SEL origSEL, SEL newSEL)
{
    //获取实例方法
    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method newMethod = nil;
	if (!origMethod) {
        //获取静态方法
		origMethod = class_getClassMethod(c, origSEL);
        newMethod = class_getClassMethod(c, newSEL);
    }else{
        newMethod = class_getInstanceMethod(c, newSEL);
    }
    
    if (!origMethod||!newMethod) {
        return;
    }
    
    //自身已经有了就添加不成功，直接交换即可
    if(class_addMethod(c, origSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))){
        //添加成功一般情况是因为，origSEL本身是在c的父类里。这里添加成功了一个继承方法。
        class_replaceMethod(c, newSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }else{
        method_exchangeImplementations(origMethod, newMethod);
	}
}

@interface UIGestureRecognizer(__MLTransistion)

@property (nonatomic, assign) UIViewController *__MLTransition_ViewController;

@end

@implementation UIGestureRecognizer(__MLTransistion)

- (void)set__MLTransition_ViewController:(UIViewController *)__MLTransition_ViewController
{
    [self willChangeValueForKey:kMLTransition_ViewController_OfPan];
	objc_setAssociatedObject(self, &kMLTransition_ViewController_OfPan, __MLTransition_ViewController, OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:kMLTransition_ViewController_OfPan];
}

- (UIViewController *)__MLTransition_ViewController
{
	return objc_getAssociatedObject(self, &kMLTransition_ViewController_OfPan);
}

@end

//作为手势的delegate，原因是如果delegate是当前vc则可能产生子类覆盖的情况
@interface __MLTransistion_Gesture_Delegate_Object : NSObject<UIGestureRecognizerDelegate>

@end

@implementation __MLTransistion_Gesture_Delegate_Object

+ (instancetype)shareInstance {
    static __MLTransistion_Gesture_Delegate_Object *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[[self class] alloc]init];
    });
    return _shareInstance;
}


//直接在这处理的话对性能有好处。
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIViewController *vc = gestureRecognizer.__MLTransition_ViewController;
    if (!vc) {
        return NO;
    }
    
    if (!vc.navigationController||
        [vc.navigationController.transitionCoordinator isAnimated]||
        vc.navigationController.viewControllers.count < 2) {
        return NO;
    }
    
    //普通拖曳模式，如果开始方向不对即不启用
    if (__MLTransitionGestureRecognizerType==MLTransitionGestureRecognizerTypePan&&[gestureRecognizer velocityInView:vc.view].x<=0) {
        return NO;
    }
    
    return YES;
}

@end

@interface UIViewController ()

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *percentDrivenInteractivePopTransition;
@property (nonatomic, strong) UIGestureRecognizer *MLTransition_gestureRecognizer;

@end

@implementation UIViewController (MLTransition)

#pragma mark - outside call
+ (void)validatePanPackWithMLTransitionGestureRecognizerType:(MLTransitionGestureRecognizerType)type
{
    //整个程序的生命周期只允许执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //设置记录type,并且执行hook
        __MLTransitionGestureRecognizerType = type;
        
        __MLTransition_Swizzle([self class],@selector(viewDidLoad),@selector(__MLTransition_Hook_ViewDidLoad));
        __MLTransition_Swizzle([self class],@selector(viewDidAppear:),@selector(__MLTransition_Hook_ViewDidAppear:));
        __MLTransition_Swizzle([self class],@selector(viewWillDisappear:),@selector(__MLTransition_Hook_ViewWillDisappear:));
        __MLTransition_Swizzle([self class], NSSelectorFromString(@"dealloc"),@selector(__MLTransition_Hook_Dealloc));
    });
}

#pragma mark - add property
- (void)setPercentDrivenInteractivePopTransition:(UIPercentDrivenInteractiveTransition *)percentDrivenInteractivePopTransition
{
    [self willChangeValueForKey:kMLTransition_PercentDrivenInteractivePopTransition];
	objc_setAssociatedObject(self, &kMLTransition_PercentDrivenInteractivePopTransition, percentDrivenInteractivePopTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:kMLTransition_PercentDrivenInteractivePopTransition];
}

- (UIPercentDrivenInteractiveTransition *)percentDrivenInteractivePopTransition
{
	return objc_getAssociatedObject(self, &kMLTransition_PercentDrivenInteractivePopTransition);
}

- (void)setMLTransition_gestureRecognizer:(UIGestureRecognizer *)MLTransition_gestureRecognizer
{
    [self willChangeValueForKey:kMLTransition_GestureRecognizer];
	objc_setAssociatedObject(self, &kMLTransition_GestureRecognizer, MLTransition_gestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:kMLTransition_GestureRecognizer];
}

- (UIGestureRecognizer *)MLTransition_gestureRecognizer
{
	return objc_getAssociatedObject(self, &kMLTransition_GestureRecognizer);
}

#pragma mark - hook
- (void)__MLTransition_Hook_ViewDidLoad
{
    [self __MLTransition_Hook_ViewDidLoad];
    
    if ([self isKindOfClass:[UINavigationController class]]) {
        return;
    }
    
    if (!self.MLTransition_gestureRecognizer) {
        UIGestureRecognizer *gestureRecognizer = nil;
        if (__MLTransitionGestureRecognizerType == MLTransitionGestureRecognizerTypeScreenEdgePan) {
            gestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(__MLTransition_HandlePopRecognizer:)];
            ((UIScreenEdgePanGestureRecognizer*)gestureRecognizer).edges = UIRectEdgeLeft;
        }else{
            gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(__MLTransition_HandlePopRecognizer:)];
        }
    
        gestureRecognizer.__MLTransition_ViewController = self;
        gestureRecognizer.delegate = [__MLTransistion_Gesture_Delegate_Object shareInstance];
        
        self.MLTransition_gestureRecognizer = gestureRecognizer;
        [self.view addGestureRecognizer:gestureRecognizer];
    }
}

- (void)__MLTransition_Hook_ViewDidAppear:(BOOL)animated {
    [self __MLTransition_Hook_ViewDidAppear:animated];
    
    if (![self isKindOfClass:[UINavigationController class]]) {
        //经过测试，只有delegate是vc的时候vc的title或者navigationItem.titleView才会跟着移动。
        //所以在下并没有使用一个单例一直作为delegate存在，单例的话效果和新版QQ一样，title不会移动，但是也会有fade效果啦。
        self.navigationController.delegate = self;
    }
}

- (void)__MLTransition_Hook_ViewWillDisappear:(BOOL)animated {
    [self __MLTransition_Hook_ViewWillDisappear:animated];
    
    if (![self isKindOfClass:[UINavigationController class]]) {
        if (self.navigationController.delegate == self) {
            self.navigationController.delegate = nil;
        }
    }
}

- (void)__MLTransition_Hook_Dealloc
{
    self.MLTransition_gestureRecognizer.delegate = nil;
    self.MLTransition_gestureRecognizer.__MLTransition_ViewController = nil;

    [self __MLTransition_Hook_Dealloc];
}

#pragma mark - UINavigationControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    if (fromVC == self) {
        if (operation == UINavigationControllerOperationPop) {
            MLTransitionAnimation *animationController = [MLTransitionAnimation new];
            animationController.type = MLTransitionAnimationTypePop;
            return animationController;
        }
        //        else{
        //            MLTransitionAnimation *animationController = [MLTransitionAnimation new];
        //            animationController.type = MLTransitionAnimationTypePush;
        //            return animationController;
        //        }
        //Push的话，发现自定义的性能可能有点问题，由于这里需求和系统的效果一样，就默认使用系统的吧
    }
    
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if ([animationController isKindOfClass:[MLTransitionAnimation class]]&&((MLTransitionAnimation*)animationController).type==MLTransitionAnimationTypePop) {
        return self.percentDrivenInteractivePopTransition;
    }
    
    return nil;
}

#pragma mark - UIGestureRecognizer handlers
- (void)__MLTransition_HandlePopRecognizer:(UIPanGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        //建立一个transition的百分比控制对象
        self.percentDrivenInteractivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        self.percentDrivenInteractivePopTransition.completionCurve = UIViewAnimationCurveLinear;
        
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (!self.percentDrivenInteractivePopTransition) {
        return;
    }
    
    
    CGFloat progress = [recognizer translationInView:self.view].x / (self.view.bounds.size.width * 1.0f);
    progress = MIN(1.0, MAX(0.0, progress));
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        //根据拖动调整transition状态
        [self.percentDrivenInteractivePopTransition updateInteractiveTransition:progress];
    }else if ((recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)) {
        //结束或者取消了手势，根据方向和速率来判断应该完成transition还是取消transition
        CGFloat velocity = [recognizer velocityInView:self.view].x; //我们只关心x的速率
        
        if (velocity > kMLTransitionConstant_Valid_MIN_Velocity) { //向右速率太快就完成
            self.percentDrivenInteractivePopTransition.completionSpeed /= 1.3f;
            [self.percentDrivenInteractivePopTransition finishInteractiveTransition];
        }else if (velocity < -kMLTransitionConstant_Valid_MIN_Velocity){ //向左速率太快就取消
            self.percentDrivenInteractivePopTransition.completionSpeed /= 1.8f;
            [self.percentDrivenInteractivePopTransition cancelInteractiveTransition];
        }else{
            BOOL isFinished = NO;
            if (progress > 0.8f || (progress>=0.2f&&velocity>0.0f)) {
                isFinished = YES;
            }
            if (isFinished) {
                self.percentDrivenInteractivePopTransition.completionSpeed /= 1.5f;
                [self.percentDrivenInteractivePopTransition finishInteractiveTransition];
            }else{
                self.percentDrivenInteractivePopTransition.completionSpeed /= 2.0f;
                [self.percentDrivenInteractivePopTransition cancelInteractiveTransition];
            }
        }
        self.percentDrivenInteractivePopTransition = nil;
    }
    
}

@end
