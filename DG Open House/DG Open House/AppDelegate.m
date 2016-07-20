//
//  AppDelegate.m
//  DG Open House
//
//  Created by Chase Acton on 1/27/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "AppDelegate.h"
#import "CocoaLumberjack.h"
#import "LeftMenuViewController.h"
#import "AFNetworkReachabilityManager.h"
#import "SVProgressHUD.h"
#import "NSUserDefaults+Convenience.h"
#import "PROPLocationManager.h"
#import "DGConstants.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "DGListingsManager.h"
#import <Realm/Realm.h>
#import "CAUpdateChecker.h"

@implementation AppDelegate
@synthesize intCounter, intPhaseNo, arrListingData, arrAlter, flagIsLoginFirstTime;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    

//    [[PROPLocationManager sharedManager] startRequestingSignificantLocationUpdates];

    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {        
        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi){
            [[NSNotificationCenter defaultCenter] postNotificationName:DGNetworkReachableNotification object:nil];
            
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:DGNetworkUnreachableNotification object:nil];
        }
    }];

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    LeftMenuViewController *leftMenu = (LeftMenuViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"LeftMenuViewController"];
    [SlideNavigationController sharedInstance].leftMenu = leftMenu;
    [SlideNavigationController sharedInstance].menuRevealAnimationDuration = .18;
    [SlideNavigationController sharedInstance].landscapeSlideOffset = 690;//[self pixelsFromIndex:sender.selectedSegmentIndex];
    [SlideNavigationController sharedInstance].avoidSwitchingToSameClassViewController = NO;
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
    [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs
    [UIApplication sharedApplication].statusBarHidden = YES;
    self.window.backgroundColor = [UIColor whiteColor];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    [NSUserDefaults registerUserDefaults];
    [[DGListingsManager sharedInstance] startSyncTimer];
    [CAUpdateChecker checkForSafeAgent];
    [NSUserDefaults setShouldEnableSafeAgent:NO];
    [Fabric with:@[[Crashlytics class]]];

    return YES;
}

@end
