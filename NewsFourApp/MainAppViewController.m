//
//  MainAppViewController.m
//  helloworld
//
//  Created by chen on 14/7/13.
//  Copyright (c) 2014年 chen. All rights reserved.
//

#import "MainAppViewController.h"

#import "SubViewController.h"
#import "TouchPropagatedScrollView.h"

#define MENU_HEIGHT 36
#define MENU_BUTTON_WIDTH  60

#define MIN_MENU_FONT  13.f
#define MAX_MENU_FONT  18.f

@interface MainAppViewController ()<UIScrollViewDelegate>
{
    UIView *_navView;
    UIView *_topNaviV;
    UIScrollView *_scrollV;
    
    TouchPropagatedScrollView *_navScrollV;
    
    float _startPointX;
    UIView *_selectTabV;
}

@end

@implementation MainAppViewController

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    UIView *statusBarView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, 0.f)];
    if (isIos7 >= 7 && __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1)
    {
        statusBarView.frame = CGRectMake(statusBarView.frame.origin.x, statusBarView.frame.origin.y, statusBarView.frame.size.width, 20.f);
        statusBarView.backgroundColor = [UIColor clearColor];
        ((UIImageView *)statusBarView).backgroundColor = RGBA(212,25,38,1);
        [self.view addSubview:statusBarView];
    }
    
    _navView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, StatusbarSize, self.view.frame.size.width, 44.f)];
    ((UIImageView *)_navView).backgroundColor = RGBA(212,25,38,1);
    [self.view insertSubview:_navView belowSubview:statusBarView];
    _navView.userInteractionEnabled = YES;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_navView.frame.size.width - 200)/2, (_navView.frame.size.height - 40)/2, 200, 40)];
    [titleLabel setText:@"新闻列表"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:22]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    UIButton *lbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [lbtn setFrame:CGRectMake(10, 2, 40, 40)];
    [lbtn setTitle:@"左" forState:UIControlStateNormal];
    lbtn.layer.borderWidth = 1;
    lbtn.layer.borderColor = [UIColor whiteColor].CGColor;
    lbtn.layer.masksToBounds = YES;
    lbtn.layer.cornerRadius = 20;
    [lbtn addTarget:self action:@selector(leftAction:) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:lbtn];
    
    UIButton *rbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rbtn setFrame:CGRectMake(_navView.frame.size.width - 50, 2, 40, 40)];
    [rbtn setTitle:@"右" forState:UIControlStateNormal];
    rbtn.layer.borderWidth = 1;
    rbtn.layer.borderColor = [UIColor whiteColor].CGColor;
    rbtn.layer.masksToBounds = YES;
    rbtn.layer.cornerRadius = 20;
    [rbtn addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:rbtn];
    
    _topNaviV = [[UIView alloc] initWithFrame:CGRectMake(0, _navView.frame.size.height + _navView.frame.origin.y, self.view.frame.size.width, MENU_HEIGHT)];
    _topNaviV.backgroundColor = RGBA(236.f, 236.f, 236.f, 1);
    [self.view addSubview:_topNaviV];
    
    _scrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _topNaviV.frame.origin.y + _topNaviV.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - _topNaviV.frame.origin.y - _topNaviV.frame.size.height)];
    [_scrollV setPagingEnabled:YES];
//    [_scrollV setBounces:NO];
    [_scrollV setShowsHorizontalScrollIndicator:NO];
    [self.view insertSubview:_scrollV belowSubview:_navView];
    _scrollV.delegate = self;
    [_scrollV.panGestureRecognizer addTarget:self action:@selector(scrollHandlePan:)];
    
    _selectTabV = [[UIView alloc] initWithFrame:CGRectMake(0, _scrollV.frame.origin.y - _scrollV.frame.size.height, _scrollV.frame.size.width, _scrollV.frame.size.height)];
    [_selectTabV setBackgroundColor:RGBA(236.f, 236.f, 236.f, 1)];
    [_selectTabV setHidden:YES];
    [self.view insertSubview:_selectTabV belowSubview:_navView];
    
    [self createTwo];
}

- (void)createTwo
{
    float btnW = 30;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(_topNaviV.frame.size.width - btnW, 0, btnW, MENU_HEIGHT)];
    [btn setBackgroundColor:[UIColor redColor]];
    [btn setTitle:@"+" forState:UIControlStateNormal];
    [_topNaviV addSubview:btn];
    [btn addTarget:self action:@selector(showSelectView:) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *arT = @[@"测试1", @"测试2", @"测试3", @"测试4", @"测试5", @"测试6", @"测试7", @"测试8", @"测试9", @"测试10"];
    _navScrollV = [[TouchPropagatedScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - btnW, MENU_HEIGHT)];
    [_navScrollV setShowsHorizontalScrollIndicator:NO];
    for (int i = 0; i < [arT count]; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(MENU_BUTTON_WIDTH * i, 0, MENU_BUTTON_WIDTH, MENU_HEIGHT)];
        [btn setTitle:[arT objectAtIndex:i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.tag = i + 1;
        if(i==0)
        {
            [self changeColorForButton:btn red:1];
            btn.titleLabel.font = [UIFont systemFontOfSize:MAX_MENU_FONT];
        }else
        {
            btn.titleLabel.font = [UIFont systemFontOfSize:MIN_MENU_FONT];
            [self changeColorForButton:btn red:0];
        }
        [btn addTarget:self action:@selector(actionbtn:) forControlEvents:UIControlEventTouchUpInside];
        [_navScrollV addSubview:btn];
    }
    [_navScrollV setContentSize:CGSizeMake(MENU_BUTTON_WIDTH * [arT count], MENU_HEIGHT)];
    [_topNaviV addSubview:_navScrollV];
    
    [self addView2Page:_scrollV count:[arT count] frame:CGRectZero];
}

- (void)addView2Page:(UIScrollView *)scrollV count:(NSUInteger)pageCount frame:(CGRect)frame
{
    for (int i = 0; i < pageCount; i++)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(scrollV.frame.size.width * i, 0, scrollV.frame.size.width, scrollV.frame.size.height)];
        view.tag = i + 1;
        view.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] init];
        singleTapRecognizer.numberOfTapsRequired = 1;
        [singleTapRecognizer addTarget:self action:@selector(pust2View:)];
        [view addGestureRecognizer:singleTapRecognizer];
        
        [self initPageView:view];
        
        [scrollV addSubview:view];
    }
    [scrollV setContentSize:CGSizeMake(scrollV.frame.size.width * pageCount, scrollV.frame.size.height)];
}

- (void)initPageView:(UIView *)view
{
    int width = (view.frame.size.width - 20)/3;
    float x = 5;
    float y = 4;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, self.view.frame.size.height - 64)];
    int sumJ = (int)(1+arc4random()%4);
    int sumI = (int)(1+arc4random()%3);
    for (int j = 1; j <= sumJ; j++)
    {
        for (int i = 1; i <= 3; i++)
        {
            if (j == sumJ && i > sumI)
            {
                break;
            }
            float w = x * i + width * (i - 1);
            float h = y * j + width * (j - 1);
            UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(w, h, width, width)];
            [l setBackgroundColor:[QHCommonUtil getRandomColor]];
            [v addSubview:l];
        }
    }
    
    [view addSubview:v];
}

- (void)changeView:(float)x
{
    float xx = x * (MENU_BUTTON_WIDTH / self.view.frame.size.width);
    
    float startX = xx;
//    float endX = xx + MENU_BUTTON_WIDTH;
    int sT = (x)/_scrollV.frame.size.width + 1;
    
    if (sT <= 0)
    {
        return;
    }
    UIButton *btn = (UIButton *)[_navScrollV viewWithTag:sT];
    float percent = (startX - MENU_BUTTON_WIDTH * (sT - 1))/MENU_BUTTON_WIDTH;
    float value = [QHCommonUtil lerp:(1 - percent) min:MIN_MENU_FONT max:MAX_MENU_FONT];
    btn.titleLabel.font = [UIFont systemFontOfSize:value];
    [self changeColorForButton:btn red:(1 - percent)];
    
    if((int)xx%MENU_BUTTON_WIDTH == 0)
        return;
    UIButton *btn2 = (UIButton *)[_navScrollV viewWithTag:sT + 1];
    float value2 = [QHCommonUtil lerp:percent min:MIN_MENU_FONT max:MAX_MENU_FONT];
    btn2.titleLabel.font = [UIFont systemFontOfSize:value2];
    [self changeColorForButton:btn2 red:percent];
}

- (void)changeColorForButton:(UIButton *)btn red:(float)nRedPercent
{
    float value = [QHCommonUtil lerp:nRedPercent min:0 max:212];
    [btn setTitleColor:RGBA(value,25,38,1) forState:UIControlStateNormal];
}

#pragma mark - action

- (void)actionbtn:(UIButton *)btn
{
    [_scrollV scrollRectToVisible:CGRectMake(_scrollV.frame.size.width * (btn.tag - 1), _scrollV.frame.origin.y, _scrollV.frame.size.width, _scrollV.frame.size.height) animated:YES];
    
    float xx = _scrollV.frame.size.width * (btn.tag - 1) * (MENU_BUTTON_WIDTH / self.view.frame.size.width) - MENU_BUTTON_WIDTH;
    [_navScrollV scrollRectToVisible:CGRectMake(xx, 0, _navScrollV.frame.size.width, _navScrollV.frame.size.height) animated:YES];
}

- (void)leftAction:(UIButton *)btn
{
    if ([_selectTabV isHidden] == NO)
    {
        [self showSelectView:btn];
        return;
    }
    [[QHSliderViewController sharedSliderController] showLeftViewController];
}

- (void)rightAction:(UIButton *)btn
{
    if ([_selectTabV isHidden] == NO)
    {
        [self showSelectView:btn];
        return;
    }
    [[QHSliderViewController sharedSliderController] showRightViewController];
}

- (void)showSelectView:(UIButton *)btn
{
    if ([_selectTabV isHidden] == YES)
    {
        [_selectTabV setHidden:NO];
        [UIView animateWithDuration:0.6 animations:^
         {
             [_selectTabV setFrame:CGRectMake(0, _scrollV.frame.origin.y, _scrollV.frame.size.width, _scrollV.frame.size.height)];
         } completion:^(BOOL finished)
         {
         }];
    }else
    {
        [UIView animateWithDuration:0.6 animations:^
         {
             [_selectTabV setFrame:CGRectMake(0, _scrollV.frame.origin.y - _scrollV.frame.size.height, _scrollV.frame.size.width, _scrollV.frame.size.height)];
         } completion:^(BOOL finished)
         {
             [_selectTabV setHidden:YES];
         }];
    }
}

-(void)scrollHandlePan:(UIPanGestureRecognizer*) panParam
{
    BOOL isPaning = NO;
    if(_scrollV.contentOffset.x < 0)
    {
        isPaning = YES;
//        isLeftDragging = YES;
//        [self showMask];
    }
    else if(_scrollV.contentOffset.x > (_scrollV.contentSize.width - _scrollV.frame.size.width))
    {
        isPaning = YES;
//        isRightDragging = YES;
//        [self showMask];
    }
    if(isPaning)
    {
        [[QHSliderViewController sharedSliderController] moveViewWithGesture:panParam];
    }
}

- (void)pust2View:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:_scrollV];
    int t = point.x/_scrollV.frame.size.width + 1;
    SubViewController *subViewController = [[SubViewController alloc] initWithFrame:[UIScreen mainScreen].bounds andSignal:@""];
    subViewController.szSignal = [NSString stringWithFormat:@"%d--%d", t, 1];
    
    [[QHSliderViewController sharedSliderController].navigationController pushViewController:subViewController animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _startPointX = scrollView.contentOffset.x;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self changeView:scrollView.contentOffset.x];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float xx = scrollView.contentOffset.x * (MENU_BUTTON_WIDTH / self.view.frame.size.width) - MENU_BUTTON_WIDTH;
    [_navScrollV scrollRectToVisible:CGRectMake(xx, 0, _navScrollV.frame.size.width, _navScrollV.frame.size.height) animated:YES];
}

@end
