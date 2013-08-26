//
//  STAppDelegate.m
//  Stig
//
//  Created by Lucas Tenório on 24/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STAppDelegate.h"
#import "STSticker.h"
#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AFNetworking.h"
#import "STOverlord.h"

@implementation STAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    // Override point for customization after application launch.
    UIFont *testFont = [UIFont fontWithName:@"Futura" size:20.0];
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeFont:testFont,UITextAttributeTextColor:[UIColor whiteColor],
                          UITextAttributeTextShadowColor:[UIColor clearColor]}];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"barra_topo_stig"] forBarMetrics:UIBarMetricsDefault];

    NSDictionary *barButtonAppearanceDict = @{UITextAttributeFont : [UIFont fontWithName:@"Futura" size:14.0]};
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
    //self.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
//    [[STHiveCluster spawnOverlord] authenticateUserOpeningUI:NO completion:^(STUser *user) {
//
//    } error:^(NSError *error) {
//        
//    }];
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

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [FBSession.activeSession handleOpenURL: url];
}

@end
