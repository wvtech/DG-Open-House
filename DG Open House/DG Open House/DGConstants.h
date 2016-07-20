//
//  DGConstants.h
//  DG Open House
//
//  Created by Chase Acton on 2/1/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "CocoaLumberjack.h"

#import "AppDelegate.h"

typedef NS_ENUM(NSUInteger, EditField) {
    EditFieldOpenHouseDate,
    EditFieldStartTime,
    EditFieldEndTime
};


#define KAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])



//URLs
static NSString * const DGBaseURL           = @"http://danielgale.ecaptureinc.com/openhouse/rest";
static NSString * const DGBasePhotoURL      = @"https://dgapi.danielgale.com/";
static NSString * const DGLatestVersionURL  = @"http://danielgale.ecaptureinc.com/openhouse/latestversion/ios.json";
static NSString * const DGKillSwitchURL     = @"http://danielgale.ecaptureinc.com/openhouse/killswitch.json";
static NSString * const DGImageUrlZip       = @"http://dgapi.danielgale.com/images/brs/dgphotos.zip";

//Notifications
static NSString * const DGNetworkReachableNotification      = @"DGNetworkReachableNotification";
static NSString * const DGNetworkUnreachableNotification    = @"DGNetworkUnreachableNotification";
static NSString * const DGSyncCompleteNotification          = @"DGSyncCompleteNotification";
static NSString * const DGSafeAgentCheckNotification        = @"DGSafeAgentCheckNotification";

//Segues
static NSString * const ShowSafeAgentSegue = @"ShowSafeAgentSegue";

//Logging
static const DDLogLevel ddLogLevel = DDLogLevelVerbose; //DDLogLevelVerbose, DDLogLevelInfo, DDLogLevelWarning, DDLogLevelError, DDLogLevelOff

//Debug
static BOOL const debug = YES;
//static BOOL const debug = NO;
static BOOL const useCacheDirectory = NO;

static NSInteger const syncInterval = 240; //Seconds, default to 240 (4 minutes)
static NSInteger const slideshowInterval = 5; //Default is 5
static NSInteger const maxPhotos = 2;