//
//  AppDelegate.h
//  ParkingGo
//
//  Created by 김학철 on 03/11/2019.
//  Copyright © 2019 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

+ (AppDelegate *)sharedInstance;
- (void)startIndicator;
- (void)stopIndicator;

@end

