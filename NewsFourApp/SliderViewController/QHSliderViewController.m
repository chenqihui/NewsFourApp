//
//  SliderViewController.m
//  LeftRightSlider
//
//  Created by heroims on 13-11-27.
//  Copyright (c) 2013年 heroims. All rights reserved.
//

#import "QHSliderViewController.h"

#import "UIImageView+LBBlurredImage.h"

#define COMMON_DURATION_TIME  0.4

@interface QHSliderViewController ()<UIGestureRecognizerDelegate>
{
    UIView *_mainContentView;
    UIView *_leftSideView;
    UIView *_rightSideView;
    
    NSMutableDictionary *_controllersDict;
    
    UITapGestureRecognizer *_tapGestureRec;
    UIPanGestureRecognizer *_panGestureRec;
    
    BOOL showingLeft;
    BOOL showingRight;
    
    float _nDurationLeft;
    UIImageView *_mainBackgroundIV;
}

@end

@implementation QHSliderViewController

-(void)dealloc{
#if __has_feature(objc_arc)
    _mainContentView = nil;
    _leftSideView = nil;
    _rightSideView = nil;
    
    _controllersDict = nil;
    
    _tapGestureRec = nil;
    _panGestureRec = nil;
    
    _LeftVC = nil;
    _RightVC = nil;
    _MainVC = nil;
    
    _mainBackgroundIV = nil;
#else
    [_mainContentView release];
    [_leftSideView release];
    [_rightSideView release];
    
    [_controllersDict release];
    
    [_tapGestureRec release];
    [_panGestureRec release];
    
    [_LeftVC release];
    [_RightVC release];
    [_MainVC release];
    if (_mainBackgroundIV != nil)
    {
        [_mainBackgroundIV release];
        _mainBackgroundIV = nil;
    }
    [super dealloc];
#endif

}

+ (QHSliderViewController*)sharedSliderController
{
    static QHSliderViewController *sharedSVC;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSVC = [[self alloc] init];
    });
    
    return sharedSVC;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if ((self = [super initWithCoder:decoder]))
    {
        _canShowLeft=YES;
        _canShowRight=YES;
	}
	return self;
}

- (id)init{
    if (self = [super init])
    {
        _canShowLeft=YES;
        _canShowRight=YES;
    }
        
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    /* { hide status bar } */
    [[self navigationController] setNavigationBarHidden:YES];
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden=YES;

    _controllersDict = [[NSMutableDictionary alloc] init];
    
    [self initSubviews];

    [self initChildControllers:_LeftVC rightVC:_RightVC];
    
    [self showContentControllerWithModel:_MainVC!=nil?NSStringFromClass([_MainVC class]):@"MainViewController"];
    
//    if((self.wantsFullScreenLayout=_MainVC.wantsFullScreenLayout))
//    {
//        _rightSideView.frame=[UIScreen mainScreen].bounds;
//        _leftSideView.frame=[UIScreen mainScreen].bounds;
//        _mainContentView.frame=[UIScreen mainScreen].bounds;
//    }

    _tapGestureRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSideBar)];
    _tapGestureRec.delegate=self;
    _tapGestureRec.enabled = NO;
    
    _panGestureRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGesture:)];
    [_mainContentView addGestureRecognizer:_panGestureRec];
    [self.view addGestureRecognizer:_panGestureRec];
    
}

#pragma mark - Init

- (void)initSubviews
{
    _rightSideView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:_rightSideView];
    
    _leftSideView = [[UIView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:_leftSideView];
    
    _mainContentView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_mainContentView];

}

- (void)initChildControllers:(UIViewController*)leftVC rightVC:(UIViewController*)rightVC
{
    if (_canShowRight&&rightVC!=nil) {
        [self addChildViewController:rightVC];
        rightVC.view.frame=CGRectMake(0, 0, rightVC.view.frame.size.width, rightVC.view.frame.size.height);
        [_rightSideView addSubview:rightVC.view];
    }
    if (_canShowLeft&&leftVC!=nil) {
        [self addChildViewController:leftVC];
        _nDurationLeft = self.view.frame.size.width - leftVC.view.frame.size.width;
        leftVC.view.frame=CGRectMake(_nDurationLeft, 0, leftVC.view.frame.size.width, leftVC.view.frame.size.height);
        [_leftSideView addSubview:leftVC.view];
    }
}

#pragma mark - Actions

- (void)showContentControllerWithModel:(NSString *)className
{
//    [self closeSideBar];
    
    UIViewController *controller = _controllersDict[className];
    if (!controller)
    {
        Class c = NSClassFromString(className);
        
#if __has_feature(objc_arc)
        controller = [[c alloc] init];
#else
        controller = [[[c alloc] init] autorelease];
#endif
        [_controllersDict setObject:controller forKey:className];
    }
    
    if (_mainContentView.subviews.count > 0)
    {
        UIView *view = [_mainContentView.subviews firstObject];
        [view removeFromSuperview];
    }
    
    controller.view.frame = _mainContentView.frame;
    [_mainContentView addSubview:controller.view];
    
    self.MainVC=controller;
}

- (void)showLeftViewController
{
    if (showingLeft) {
        [self closeSideBar];
        return;
    }
    if (!_canShowLeft||_LeftVC==nil) {
        return;
    }
    showingLeft = YES;
    [self.view bringSubviewToFront:_leftSideView];
//    float durationTime = (-_leftSideView.frame.origin.x)/(_MainVC.view.frame.size.width);
    [self configureViewBlurWith:0 scale:0.8];
    [UIView animateWithDuration:COMMON_DURATION_TIME animations:^
     {
         [self configureViewBlurWith:_MainVC.view.frame.size.width scale:0.8];
         [_leftSideView setFrame:CGRectMake(-_nDurationLeft, _leftSideView.frame.origin.y, _leftSideView.frame.size.width, _leftSideView.frame.size.height)];
     } completion:^(BOOL finished)
     {
         _leftSideView.userInteractionEnabled = YES;
         _tapGestureRec.enabled = YES;
     }];
}

- (void)showRightViewController
{
    if (showingRight) {
        [self closeSideBar];
        return;
    }
    if (!_canShowRight||_RightVC==nil) {
        return;
    }
    showingRight = YES;
    [self.view bringSubviewToFront:_rightSideView];
//    float durationTime = (_rightSideView.frame.origin.x)/(_MainVC.view.frame.size.width);
    [self configureViewBlurWith:0 scale:1];
    [UIView animateWithDuration:COMMON_DURATION_TIME animations:^
     {
         [self configureViewBlurWith:_MainVC.view.frame.size.width scale:1];
         [_rightSideView setFrame:CGRectMake(0, _rightSideView.frame.origin.y, _rightSideView.frame.size.width, _rightSideView.frame.size.height)];
     } completion:^(BOOL finished)
     {
         _rightSideView.userInteractionEnabled = YES;
         _tapGestureRec.enabled = YES;
         
         if (self.finishShowRight != nil)
         {
             self.finishShowRight();
         }
     }];
}

- (void)closeSideBar
{
    [self closeSideBarWithAnimate:YES complete:^(BOOL finished) {}];
}

- (void)closeSideBarWithAnimate:(BOOL)bAnimate complete:(void(^)(BOOL finished))complete
{
    if (showingLeft)
    {
        if (bAnimate)
        {
//            float durationTime = 1 - (-_leftSideView.frame.origin.x)/(_MainVC.view.frame.size.width);
            [UIView animateWithDuration:COMMON_DURATION_TIME animations:^
             {
                 [self configureViewBlurWith:0 scale:0.8];
                 [_leftSideView setFrame:CGRectMake(-_leftSideView.frame.size.width, _leftSideView.frame.origin.y, _leftSideView.frame.size.width, _leftSideView.frame.size.height)];
             } completion:^(BOOL finished)
             {
                 [self.view sendSubviewToBack:_leftSideView];
                 showingLeft = NO;
                 showingRight = NO;
                 _tapGestureRec.enabled = NO;
                 
                 [self removeconfigureViewBlur];
                 
                 complete(YES);
             }];
        }else
        {
            [self configureViewBlurWith:0 scale:0.8];
            [_leftSideView setFrame:CGRectMake(-_leftSideView.frame.size.width, _leftSideView.frame.origin.y, _leftSideView.frame.size.width, _leftSideView.frame.size.height)];
            [self.view sendSubviewToBack:_leftSideView];
            showingLeft = NO;
            showingRight = NO;
            _tapGestureRec.enabled = NO;
            
            [self removeconfigureViewBlur];
            
            complete(YES);
        }
    }else
    {
        if (bAnimate)
        {
//            float durationTime = 1 - (_rightSideView.frame.origin.x)/(_MainVC.view.frame.size.width);
            [UIView animateWithDuration:COMMON_DURATION_TIME animations:^
             {
                 [self configureViewBlurWith:0 scale:1];
                 [_rightSideView setFrame:CGRectMake(_MainVC.view.frame.size.width, _rightSideView.frame.origin.y, _rightSideView.frame.size.width, _rightSideView.frame.size.height)];
             } completion:^(BOOL finished)
             {
                 [self.view sendSubviewToBack:_rightSideView];
                 showingLeft = NO;
                 showingRight = NO;
                 _tapGestureRec.enabled = NO;
                 
                 [self removeconfigureViewBlur];
                 
                 complete(YES);
             }];
        }else
        {
            [self configureViewBlurWith:0 scale:1];
            [_rightSideView setFrame:CGRectMake(_MainVC.view.frame.size.width, _rightSideView.frame.origin.y, _rightSideView.frame.size.width, _rightSideView.frame.size.height)];
            [self.view sendSubviewToBack:_rightSideView];
            showingLeft = NO;
            showingRight = NO;
            _tapGestureRec.enabled = NO;
            
            [self removeconfigureViewBlur];
            
            complete(YES);
        }
    }
}

- (void)moveViewWithGesture:(UIPanGestureRecognizer *)panGes
{
    static CGFloat startX;
    static CGFloat lastX;
    static CGFloat durationX;
    CGPoint touchPoint = [panGes locationInView:[[UIApplication sharedApplication] keyWindow]];
    
    if (panGes.state == UIGestureRecognizerStateBegan)
    {
        startX = touchPoint.x;
        lastX = touchPoint.x;
    }
    if (panGes.state == UIGestureRecognizerStateChanged)
    {
        CGFloat currentX = touchPoint.x;
        durationX = currentX - lastX;
        lastX = currentX;
        if (durationX > 0)
        {
            if(!showingLeft && !showingRight)
            {
                showingLeft = YES;
                [self.view bringSubviewToFront:_leftSideView];
            }
        }else
        {
            if(!showingRight && !showingLeft)
            {
                showingRight = YES;
                [self.view bringSubviewToFront:_rightSideView];
            }
        }
        
        if (showingLeft)
        {
            if (_leftSideView.frame.origin.x >= -_nDurationLeft && durationX > 0)
            {
                return;
            }
            if (!_canShowLeft||_LeftVC==nil) {
                return;
            }
            
            [self configureViewBlurWith:currentX scale:0.8];
            float x = durationX + _leftSideView.frame.origin.x;
            [_leftSideView setFrame:CGRectMake(x, _leftSideView.frame.origin.y, _leftSideView.frame.size.width, _leftSideView.frame.size.height)];
        }
        else    //transX < 0
        {
            if (!_canShowRight||_RightVC==nil) {
                return;
            }
            
            [self configureViewBlurWith:(self.view.frame.size.width - currentX) scale:0.8];
            float x = durationX + _rightSideView.frame.origin.x;
            [_rightSideView setFrame:CGRectMake(x, _rightSideView.frame.origin.y, _rightSideView.frame.size.width, _rightSideView.frame.size.height)];
        }
    }
    else if (panGes.state == UIGestureRecognizerStateEnded)
    {
        if (showingLeft)
        {
            if (!_canShowLeft||_LeftVC==nil) {
                return;
            }
            
            if ((_leftSideView.frame.origin.x + _leftSideView.frame.size.width) > (_leftSideView.frame.size.width - _nDurationLeft)/2)
            {
                float durationTime = (-_leftSideView.frame.origin.x)/(_MainVC.view.frame.size.width);
                [UIView animateWithDuration:durationTime animations:^
                 {
                    [self configureViewBlurWith:_MainVC.view.frame.size.width scale:0.8];
                    [_leftSideView setFrame:CGRectMake(-_nDurationLeft, _leftSideView.frame.origin.y, _leftSideView.frame.size.width, _leftSideView.frame.size.height)];
                } completion:^(BOOL finished)
                {
                    _leftSideView.userInteractionEnabled = YES;
                     _tapGestureRec.enabled = YES;
                }];
            }else
            {
                float durationTime = 1 - (-_leftSideView.frame.origin.x)/(_MainVC.view.frame.size.width);
                [UIView animateWithDuration:durationTime animations:^
                 {
                     [self configureViewBlurWith:0 scale:0.8];
                     [_leftSideView setFrame:CGRectMake(-_leftSideView.frame.size.width, _leftSideView.frame.origin.y, _leftSideView.frame.size.width, _leftSideView.frame.size.height)];
                 } completion:^(BOOL finished)
                 {
                     [self.view sendSubviewToBack:_leftSideView];
                     showingLeft = NO;
                     showingRight = NO;
                     _tapGestureRec.enabled = NO;
                     
                     [self removeconfigureViewBlur];
                 }];
            }
            
            return;
        }
        if (showingRight)
        {
            if (!_canShowRight||_RightVC==nil) {
                return;
            }
            
            if (_rightSideView.frame.origin.x < _MainVC.view.frame.size.width/2)
            {
                float durationTime = (_rightSideView.frame.origin.x)/(_MainVC.view.frame.size.width);
                [UIView animateWithDuration:durationTime animations:^
                 {
                     [self configureViewBlurWith:_MainVC.view.frame.size.width scale:1];
                     [_rightSideView setFrame:CGRectMake(0, _rightSideView.frame.origin.y, _rightSideView.frame.size.width, _rightSideView.frame.size.height)];
                 } completion:^(BOOL finished)
                 {
                     _rightSideView.userInteractionEnabled = YES;
                     _tapGestureRec.enabled = YES;
                     
                     if (self.finishShowRight != nil)
                     {
                         self.finishShowRight();
                     }
                 }];
            }else
            {
                float durationTime = 1 - (_rightSideView.frame.origin.x)/(_MainVC.view.frame.size.width);
                [UIView animateWithDuration:durationTime animations:^
                 {
                     [self configureViewBlurWith:0 scale:1];
                     [_rightSideView setFrame:CGRectMake(_MainVC.view.frame.size.width, _rightSideView.frame.origin.y, _rightSideView.frame.size.width, _rightSideView.frame.size.height)];
                 } completion:^(BOOL finished)
                 {
                     [self.view sendSubviewToBack:_rightSideView];
                     showingLeft = NO;
                     showingRight = NO;
                     _tapGestureRec.enabled = NO;
                     
                     [self removeconfigureViewBlur];
                 }];
            }
        }
    }
}

#pragma mark -

- (void)configureViewBlurWith:(float)nValue scale:(float)nScale
{
    if(_mainBackgroundIV == nil)
    {
        _mainBackgroundIV = [[UIImageView alloc] initWithFrame:_MainVC.view.bounds];
        _mainBackgroundIV.userInteractionEnabled = YES;
        [_mainBackgroundIV addGestureRecognizer:_tapGestureRec];
        [_tapGestureRec setEnabled:YES];
    
        UIImage *image = [QHCommonUtil getImageFromView:_MainVC.view];
        [_mainBackgroundIV setImageToBlur:image
                               blurRadius:kLBBlurredImageDefaultBlurRadius
                          completionBlock:^(){}];
        
        [_MainVC.view addSubview:_mainBackgroundIV];
    }
    [_mainBackgroundIV setAlpha:(nValue/_MainVC.view.frame.size.width) * nScale];
}

- (void)removeconfigureViewBlur
{
    [_mainBackgroundIV removeFromSuperview];
    
#if __has_feature(objc_arc)
    
#else
    [_mainBackgroundIV release];
#endif
    _mainBackgroundIV = nil;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{    
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}

@end
