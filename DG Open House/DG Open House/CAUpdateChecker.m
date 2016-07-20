//
//  CAUpdateChecker.m
//  Elli
//
//  Created by Chase Acton on 3/14/16.
//  Copyright © 2016 Amnesiapps. All rights reserved.
//

#import "CAUpdateChecker.h"
#import "AppDelegate.h"
#import "DGConstants.h"
#import "NSUserDefaults+Convenience.h"

static NSString * const CAiTunesAPIKeyResults       = @"results";
static NSString * const CAiTunesAPIKeyVersion       = @"version";
static NSString * const CAiTunesAPIKeyDownloadURL   = @"trackViewUrl";

@implementation CAUpdateChecker

+ (void)checkForUpdate{
    NSURL *url = [[NSURL alloc] initWithString:DGLatestVersionURL];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            NSLog(@"JSON Error: %@",error.localizedDescription);
        } else {
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            if (parsedObject){
                NSString *latestVersion = [parsedObject objectForKey:@"latest"];
                NSURL *appStoreURL = [[NSURL alloc] initWithString:[parsedObject objectForKey:@"downloadURL"]];
                [self compareVersions:latestVersion updateURL:appStoreURL];
                
            }else{
                NSLog(@"iTunes lookup failed");
            }
        }
    }];
    
    [self checkForSafeAgent];
}

+ (void)compareVersions:(NSString *)latestVersion updateURL:(NSURL *)url{
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSLog(@"Current app version is: %@, latest is: %@",currentVersion,latestVersion);
    
    if ([latestVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending){
        NSLog(@"App is outdated, prompting to update");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert =   [UIAlertController
                                          alertControllerWithTitle:@"Update Available"
                                          message:@"Please download the latest version"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *downloadAction = [UIAlertAction
                                             actionWithTitle:@"Download Update"
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action){
                                                 [[UIApplication sharedApplication] openURL:url];
                                             }];
            
            [alert addAction:downloadAction];
            
            UIViewController *currentTopVC = [self currentTopViewController];
            [currentTopVC presentViewController:alert animated:YES completion:nil];
        });
    }else{
        NSLog(@"App is up to date");
    }
}

+ (UIViewController *)currentTopViewController{
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    
    while (topVC.presentedViewController){
        topVC = topVC.presentedViewController;
    }
    
    return topVC;
}

#pragma mark - Safe Agent

+ (void)checkForSafeAgent{
//    NSURL *url = [[NSURL alloc] initWithString:DGKillSwitchURL];
//    
//    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//        
//        if (error) {
//            NSLog(@"JSON Error: %@",error.localizedDescription);
//        } else {
//            NSError *localError = nil;
//            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
//            if (parsedObject){
//
//                if ([parsedObject objectForKey:@"version"]){
//                    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//                    
//                    if ([[parsedObject objectForKey:@"version"] isEqualToString:currentVersion]){
//                        BOOL enable = [[parsedObject objectForKey:@"enable"] boolValue];
//                        [NSUserDefaults setShouldEnableSafeAgent:enable];
//
//                    }else{
//                        [NSUserDefaults setShouldEnableSafeAgent:YES];
//                    }
//                    
//                    //Update view controllers
//                    [[NSNotificationCenter defaultCenter] postNotificationName:DGSafeAgentCheckNotification object:nil];
//                }
//            }
//        }
//    }];
}

@end
