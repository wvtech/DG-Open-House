//
//  DGAPIClient+ErrorHandling.m
//  DG Open House
//
//  Created by Chase Acton on 2/1/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGAPIClient+ErrorHandling.h"
#import "DGAPIClient.h"
#import "AFNetworking.h"

@implementation DGAPIClient (ErrorHandling)

+ (void)handleError:(NSError *)error forOperation:(AFHTTPRequestOperation *)operation completion:(void (^)(BOOL success, NSError *error, id responseObject, BOOL shouldRetry)) block{
//    [self logError:error];
//
//    if (operation.response.statusCode == 400){
//        //Bad request. Possible that credentials have changed. Probably need to have user enter new credentials.
//        [self postAuthNotification];
//        block(NO, error, nil, NO);
//    }else if (operation.response.statusCode == 401){
//        //Session probably expired. Obtain a new session cookie using the user's saved credentials from Keychain.
//        [self retryLogin:^(BOOL credentialsStillValid){
//            if (credentialsStillValid){
//                //Credentials worked and the new auth cookie has been set. Retry the request.
//                block(NO, error, nil, YES);
//            }else{
//                //Credentials have most likely changed. Present sign in screen.
//                [PHAPIClient postAuthNotification];
//                block(NO, error, nil, NO);
//            }
//        }];
//    }else{
//        //Something else unexpected happen. Show a message to the user and inform the requester of the failure.
//        [self displayError:error];
//        block(NO, error, nil, NO);
//    }
}

+ (void)logError:(NSError *)error{
    //    [CrashlyticsKit recordError:error];
    //    DDLogError(@"Error: %@", error.localizedDescription);
    //
    //    if ([error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey]){
    //        NSDictionary *errorJSON = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:kNilOptions error:&error];
    //        DDLogError(@"API Error Response: %@",errorJSON);
    //    }
}

+ (void)retryLogin:(void (^)(BOOL credentialsStillValid)) block{
    //Session probably expired. First retry login using existing credentials.
    // Get the saved user email and password from keychain
    //    NSString* storedUserEmail = [DGKeychain  userEmail];
    //    NSString* storedUserPassword = [DGKeychain userPassword];
    //
    //    [PHServer signInWithEmail:storedUserEmail password:storedUserPassword completion:^(BOOL success, NSError *error, PROPUser* user) {
    //        block(success);
    //    }];
}

+ (void)postAuthNotification{
    //    [[NSNotificationCenter defaultCenter] postNotificationName:PROPShowLoginViewNotification object:nil userInfo:nil];
}

+ (void)displayError:(NSError *)error{
    //    if ([error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey]){
    //        NSDictionary *errorJSON = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:kNilOptions error:&error];
    //        DDLogError(@"API Error Response: %@",errorJSON);
    //        [PROPAlert alertWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription sender:[self currentTopViewController]];
    //    }else if (![[[AppDelegate sharedDelegate] reachability] isReachable]){
    //        [PROPAlert alertWithTitle:NSLocalizedString(@"Internet Unavailable", nil) message:NSLocalizedString(@"Please connect to the internet and try again", nil) sender:[self currentTopViewController]];
    //    }
}

//+ (UIViewController *)currentTopViewController{
//    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
//    while (topVC.presentedViewController){
//        topVC = topVC.presentedViewController;
//    }
//    return topVC;
//}


@end