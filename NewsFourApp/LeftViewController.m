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
    UITableView *_tableView;
}

@end

@implementation LeftViewController

- (void)viewDidLoad
{
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    _arData = @[@"新闻", @"订阅", @"图片", @"视频", @"跟帖", @"电台"];
    
    float y = 0.15*self.view.frame.size.height;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(60, y, CGRectGetWidth(self.view.bounds) * 0.75 -60, CGRectGetHeight(self.view.bounds))];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.scrollEnabled = NO;
    [self.view addSubview:_tableView];
    
    UIButton *toNewViewbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [toNewViewbtn setFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 170, CGRectGetHeight(self.view.frame) - 60, 60, 30)];
    [toNewViewbtn setTitle:@"新页面" forState:UIControlStateNormal];
    [toNewViewbtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [toNewViewbtn setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
    [toNewViewbtn addTarget:self action:@selector(toNewViewbtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:toNewViewbtn];
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

#pragma mark - <UITableViewDataSource>
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_arData count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.frame.size.height*0.7/[_arData count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [_arData objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:20];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - <UITableViewDelegate>
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSelectorOnMainThread:@selector(backAction:) withObject:nil waitUntilDone:nil];
}
@end
