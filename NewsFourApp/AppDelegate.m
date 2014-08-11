//
//  AppDelegate.m
//  NewsFourApp
//
//  Created by chen on 14/8/8.
//  Copyright (c) 2014年 chen. All rights reserved.
//

#import "AppDelegate.h"

#import "MainAppViewController.h"
#import "LeftViewController.h"
#import "RightViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    [UIViewController validatePanPackWithMLTransitionGestureRecognizerType:MLTransitionGestureRecognizerTypePan];
    
    LeftViewController *leftVC = [[LeftViewController alloc] init];
    [leftVC.view setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width*0.75, [UIScreen mainScreen].bounds.size.height)];
    [QHSliderViewController sharedSliderController].LeftVC = leftVC;
    RightViewController *rightVC = [[RightViewController alloc] init];
    [QHSliderViewController sharedSliderController].RightVC = rightVC;
    [QHSliderViewController sharedSliderController].finishShowRight = ^()
    {
        [rightVC headPhotoAnimation];
    };
    [QHSliderViewController sharedSliderController].MainVC = [[MainAppViewController alloc] init];
    
    UINavigationController *naviC = [[UINavigationController alloc] initWithRootViewController:[QHSliderViewController sharedSliderController]];
    self.window.rootViewController = naviC;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
