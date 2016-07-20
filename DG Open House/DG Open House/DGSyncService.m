//
//  DGSyncService.m
//  DG Open House
//
//  Created by Chase Acton on 5/12/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGSyncService.h"
#import "SVProgressHUD.h"
#import "DGListingsManager.h"
#import "DGEventsManager.h"
#import "AFNetworkReachabilityManager.h"
#import "NSUserDefaults+Convenience.h"
//#import "ZipArchive.h"
#import "SSZipArchive.h"
#import "DGConstants.h"

@implementation DGSyncService


#define ZIP_URL @"http://dgapi.danielgale.com/images/brs/dgphotos.zip"

+ (void)downloadAllDataWithHUD:(BOOL)showHUD callback:(void (^)(BOOL success, NSError *error)) callback{
    NSLog(@"downloadAllDataWithHUD - Start");
    

    //Don't sync if no network
    if (![[AFNetworkReachabilityManager sharedManager] isReachable]){
        NSLog(@"downloadAllDataWithHUD failed - no internet");
        return callback(NO, nil);
    }
   /// Downloading Zip Files
     //   if(KAppDelegate.flagIsLoginFirstTime) {//// When ever user login for first timw then this condition executes
   
    NSURL *yourURL = [NSURL URLWithString:@"http://dgapi.danielgale.com/images/brs/dgphotos.zip"];
    //NSURL *yourURL = [NSURL URLWithString:@"http://192.168.0.195:8888/api-laravel/dgphotos.zip"];
    
    // turn it into a request and use NSData to load its content
    
    NSData *data = [NSData dataWithContentsOfURL:yourURL];
    NSLog(@"data = %d", (int)data.length);
    // find Documents directory and append your local filename
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    documentsURL = [documentsURL URLByAppendingPathComponent:@"dgphotos.zip"];
    NSLog(@"DGAPI Client filePath = %@", documentsURL);
    // and finally save the file
    [data writeToURL:documentsURL atomically:YES];
    
    NSString * strZipDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    strZipDirectory = [strZipDirectory stringByAppendingPathComponent:@"dgphotos.zip"];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.90 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *zipFilePath, * strFolderName, * strOutputPath;
        if(data.length > 0){
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            zipFilePath = [NSString stringWithFormat:@"%@", strZipDirectory];
            NSLog(@"zipFilePath = %@", zipFilePath);
            strFolderName = @"dgPhotos";
            strOutputPath = [documentsDirectory stringByAppendingPathComponent:strFolderName];
            //  NSString *zipPath = @"path_to_your_zip_file";
            //   NSString *destinationPath = @"path_to_the_folder_where_you_want_it_unzipped";
            [SSZipArchive unzipFileAtPath:zipFilePath toDestination:strOutputPath];
            
            NSLog(@"output path = %@", strOutputPath);
            KAppDelegate.flagIsLoginFirstTime =  NO;
        }
    });
    
   
   // [DGListingsManager sharedInstance].syncInProgress = YES;
    
    [self showStatus:@"Downloading Listings…" showHUD:showHUD];
    [[DGListingsManager sharedInstance] getListings:^(BOOL success, NSError *error) {
        @try {
        if (success){
            NSLog(@"Starting listing images");
            [NSUserDefaults setHasSignedInBefore:YES];
            [self showStatus:@"Downloading Listing Images…" showHUD:showHUD];
            [[DGListingsManager sharedInstance] downloadListingImages:^(BOOL success, NSError *error) {
                
                if (success){
                    
                    [self showStatus:@"Downloading Listing Attendees…" showHUD:showHUD];
                    [[DGListingsManager sharedInstance] getListingAttendees:^(BOOL success, NSError *error) {
                        
                        if (success){
                            [self showStatus:@"Downloading Events…" showHUD:showHUD];
                            [[DGEventsManager sharedInstance] getEvents:^(BOOL success, NSError *error) {
                                
                                if (success){
                                    [self showStatus:@"Downloading Event Attendees…" showHUD:showHUD];
                                    [[DGEventsManager sharedInstance] getEventAttendees:^(BOOL success, NSError *error) {
                                        
                                        if (success){
                                            [self showStatus:@"Downloading User Files…" showHUD:showHUD];
                                            [[DGListingsManager sharedInstance] downloadFiles:^(BOOL success, NSError *error) {
                                                
                                                if (success){
                                                    [SVProgressHUD dismiss];
                                                    
                                                    [DGListingsManager sharedInstance].syncInProgress = NO;

                                                    NSLog(@"downloadAllDataWithHUD - Finished");

                                                    callback(success, error);
                                                }else{
                                                    callback(NO, error);
                                                }
                                            }];
                                        }else{
                                            callback(NO, error);
                                        }
                                    }];
                                }else{
                                    callback(NO, error);
                                }
                            }];
                        }else{
                            callback(NO, error);
                        }
                    }];
                }else{
                    callback(NO, error);
                }
            }];
        }else{
            callback(NO, error);
        }
        }@catch (NSException *exception) {
            callback(success, error);
            NSLog(@"Downloading Exception = %@", exception.reason);
        }
    }];
   
}

+ (void)showStatus:(NSString *)status showHUD:(BOOL)showHUD{
    if (showHUD){
        [SVProgressHUD showWithStatus:status];
    }
}

+ (void)downloadAllDataInBackGroundWithHUD:(BOOL)showHUD callback:(void (^)(BOOL success, NSError *error)) callback{
    NSLog(@"downloadAllDataWithHUD BackGround - Start");
    
    //Don't sync if no network
    if (![[AFNetworkReachabilityManager sharedManager] isReachable]){
        NSLog(@"downloadAllDataWithHUD failed - no internet");
        return callback(NO, nil);
    }
   
    [DGListingsManager sharedInstance].syncInProgress = YES;
    
    [[DGListingsManager sharedInstance] getListings:^(BOOL success, NSError *error) {
        
        if (success){
            NSLog(@"Starting listing images");
            [[DGListingsManager sharedInstance] downloadListingImages:^(BOOL success, NSError *error) {
                
                if (success){
                    [[DGListingsManager sharedInstance] getListingAttendees:^(BOOL success, NSError *error) {
                        
                       if (success){
                            [[DGEventsManager sharedInstance] getEvents:^(BOOL success, NSError *error) {
                                
                                if (success){
                                    [[DGEventsManager sharedInstance] getEventAttendees:^(BOOL success, NSError *error) {
                                        
                                        if (success){
                                             [[DGListingsManager sharedInstance] downloadFiles:^(BOOL success, NSError *error) {
                                                
                                               if (success){
                                                    
                                                    [DGListingsManager sharedInstance].syncInProgress = NO;
                                                    
                                                    NSLog(@"downloadAllDataWithHUD BackGround- Finished");
                                                    
                                                    callback(success, error);
                                                }else{
                                                    callback(NO, error);
                                                }
                                            }]; 
                                        }else{
                                            callback(NO, error);
                                        }
                                    }];
                                }else{
                                    callback(NO, error);
                                }
                            }];
                        }else{
                            callback(NO, error);
                        }
                    }];
                }else{
                    callback(NO, error);
                }
            }];
        }else{
            callback(NO, error);
        }
    }];
}



@end