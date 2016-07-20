//
//  DGSyncService.h
//  DG Open House
//
//  Created by Chase Acton on 5/12/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//
#import "AppDelegate.h"
#import <Foundation/Foundation.h>

@interface DGSyncService : NSObject <NSURLConnectionDataDelegate> {

}


+ (void)downloadAllDataWithHUD:(BOOL)showHUD callback:(void (^)(BOOL success, NSError *error)) callback;
+ (void)downloadAllDataInBackGroundWithHUD:(BOOL)showHUD callback:(void (^)(BOOL success, NSError *error)) callback;





@end