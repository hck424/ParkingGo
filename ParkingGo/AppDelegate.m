//
//  AppDelegate.m
//  ParkingGo
//
//  Created by 김학철 on 03/11/2019.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "AppDelegate.h"
#import "UIView+Utility.h"


@interface AppDelegate ()
@property (nonatomic, strong) UIView *loadingView;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0)){
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}
+ (AppDelegate *)sharedInstance {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)startIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.loadingView == nil) {
            self.loadingView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        }
        
        [[UIApplication sharedApplication].keyWindow addSubview:self.loadingView];
        [self.loadingView startAnimationWithRaduis:25];
    });
}
- (void)stopIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.loadingView) {
            [self.loadingView stopAnimation];
        }
        [self.loadingView removeFromSuperview];
    });
}

@end
