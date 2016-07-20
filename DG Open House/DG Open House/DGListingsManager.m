//
//  DGListingsManager.m
//  DG Open House
//
//  Created by Chase Acton on 2/10/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGListingsManager.h"
#import "DGServer.h"
#import "DGListing.h"
#import "DGUserManager.h"
#import "NSArray+Utilities.h"
#import "DGAttendee.h"
#import "DGAPI.h"
#import "DGFile.h"
#import "DGEventsManager.h"
#import "DGEvent.h"
#import "DGConstants.h"
#import "AFNetworkReachabilityManager.h"
#import "UIImage+DGImage.h"
#import "DGConstants.h"
#import "DGSyncService.h"
#import "RLMListing.h"
#import "RealmString.h"
#import "RLMAttendee.h"
#import "RLMFile.h"
#import "RLMEvent.h"
#import "NSUserDefaults+Convenience.h"

@interface DGListingsManager ()

@property (nonatomic) NSArray *listingAttendees;
@property (nonatomic) NSArray *allListings;

@end

@implementation DGListingsManager

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static DGListingsManager *sharedMyInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyInstance = [[self alloc] init];
    });
    return sharedMyInstance;
}

- (id)init{
    self = [super init];
    if (self != nil){
        self.activeListings     = [[NSMutableArray alloc] init];
        self.inactiveListings   = [[NSArray alloc] init];
        self.allListings        = [[NSArray alloc] init];
        self.listingAttendees   = [[NSArray alloc] init];
        self.listingsToAdd      = [[NSArray alloc] init];
        
        [self loadListingsFromDisk];
    }
    return self;
}

- (void)loadListingsFromDisk{
    RLMRealm *realmMainThread = [RLMRealm defaultRealm];
    RLMResults *listings = [RLMListing allObjectsInRealm:realmMainThread];
    
    NSMutableArray *listingsTemp = [[NSMutableArray alloc] init];
    for (RLMListing *listing in listings){
        [listingsTemp addObject:listing];
    }
    
    self.allListings = [[NSArray alloc] initWithArray:[listingsTemp copy]];
    
    [self buildListingArrays];
}

- (RLMListing *)listingWithID:(NSString *)listingID{
    for (RLMListing *listing in self.activeListings){
        if ([listing.listingID isEqualToString:listingID]){
            return listing;
            break;
        }
    }
    
    for (RLMListing *listing in self.inactiveListings){
        if ([listing.listingID isEqualToString:listingID]){
            return listing;
            break;
        }
    }
    
    return nil;
}

#pragma mark - Sync

- (void)startSyncTimer{
    NSLog(@"syncInterval = %ld", (long)syncInterval);
    [self performSelector:@selector(syncTimer) withObject:nil afterDelay:syncInterval];
}

- (void)syncTimer{
    //Don't sync if no network
    NSLog(@"syncInterval Timer = %ld", (long)syncInterval);
    if (![[AFNetworkReachabilityManager sharedManager] isReachable] || self.syncInProgress || ![DGUserManager sharedInstance].signedIn){
        [self performSelector:@selector(syncTimer) withObject:nil afterDelay:syncInterval];
        return;
    }
    
    self.syncInProgress = YES;
    
    //    //Upload all pending data
    [self sync:^(BOOL success) {
        if (success){
            
            //Download all data
            //[DGSyncService downloadAllDataWithHUD:NO callback:^(BOOL success, NSError *error) {
              [DGSyncService downloadAllDataInBackGroundWithHUD:NO callback:^(BOOL success, NSError *error) {
                if (success){
                    //Notify listeners that sync finished
                    [[NSNotificationCenter defaultCenter] postNotificationName:DGSyncCompleteNotification object:nil];
                    
                    self.syncInProgress = NO;
                    
                    //Repeat
                    [self performSelector:@selector(syncTimer) withObject:nil afterDelay:syncInterval];
                }else{
                    self.syncInProgress = NO;
                    [self performSelector:@selector(syncTimer) withObject:nil afterDelay:syncInterval];
                }
            }];
        }else{
            self.syncInProgress = NO;
            [self performSelector:@selector(syncTimer) withObject:nil afterDelay:syncInterval];
        }
    }];
}

#pragma mark - Main Methods

- (void)getListings:(void (^)(BOOL success, NSError *error)) block{
    NSLog(@"LISTINGS - Starting");

    [DGServer getListings:^(BOOL success, NSError *error, NSArray *listings) {
        if (success){
            

            RLMRealm *realm = [RLMRealm defaultRealm];
            
            [realm beginWriteTransaction];
            for (DGListing *listing in listings){
                RLMListing *rlmListing = [[RLMListing alloc] initWithJSONModel:listing];
                
                NSDictionary *fieldsToUpdate = @{
                                                 @"listingID": rlmListing.listingID,
                                                 @"address": rlmListing.address,
                                                 @"state": rlmListing.state,
                                                 @"town": rlmListing.town,
                                                 @"mlsNumber": rlmListing.mlsNumber,
                                                 @"agentID": rlmListing.agentID,
                                                 @"coAgentID": rlmListing.coAgentID,
                                                 @"listingTimestamp": rlmListing.listingTimestamp,
                                                 @"zip": rlmListing.zip,
                                                 @"photoURL": rlmListing.photoURL,
                                                 @"status": rlmListing.status,
                                                 @"numberOfPhotos": @(rlmListing.numberOfPhotos),
                                                 @"isActive": @(rlmListing.isActive),
                                                 @"hasPhotos": @(rlmListing.hasPhotos),
                                                 @"attendees": rlmListing.attendees,
                                                 @"images": rlmListing.images,
                                                 };
          //      NSLog(@"fieldsToUpdate = %@", fieldsToUpdate[@"mlsNumber"]);
                
                [RLMListing createOrUpdateInDefaultRealmWithValue:fieldsToUpdate];
            }
            
            [realm commitWriteTransaction];
            
            RLMResults *rlmListings = [RLMListing allObjectsInRealm:realm];
            
            NSMutableArray *listingsTemp = [[NSMutableArray alloc] init];
            for (RLMListing *listing in rlmListings){
                [listingsTemp addObject:listing];
            }
            
            self.allListings = [[NSArray alloc] initWithArray:[listingsTemp copy]];
        }
        NSLog(@"LISTINGS - Finished");
        block(success, error);
    }];
}

- (void)getListingAttendees:(void (^)(BOOL success, NSError *error)) block{
    NSLog(@"ATTENDEES - Starting");

    [DGServer getListingAttendees:^(BOOL success, NSError *error, NSArray *listings) {
        if (success){
            
            RLMRealm *realm = [RLMRealm defaultRealm];
            for (DGAttendee *attendee in listings){
                [realm beginWriteTransaction];

                RLMAttendee *realmAttendee = [[RLMAttendee alloc] initWithJSONModel:attendee];
                [RLMAttendee createOrUpdateInDefaultRealmWithValue:realmAttendee];
                [realm commitWriteTransaction];
            }
            
            RLMResults *attendees = [RLMAttendee allObjectsInRealm:realm];
            
            NSMutableArray *listingsTemp = [[NSMutableArray alloc] init];
            for (RLMListing *listing in attendees){
                [listingsTemp addObject:listing];
            }
            
            NSLog(@"Total Attendees = %d", (int) listingsTemp.count);
            self.listingAttendees = [[NSArray alloc] initWithArray:[listingsTemp copy]];
                        
            //Now we need to add attendees to their respective listings
            for (RLMListing *listing in self.allListings){
                for (RLMAttendee *attendee in self.listingAttendees){
                    if ([attendee.listingID isEqualToString:listing.listingID]){
                        [realm beginWriteTransaction];

                        attendee.listingID = listing.listingID;
                        [listing.attendees addObject:attendee];
                        
                        [realm commitWriteTransaction];
                    }
                }
            }
            
            //Now break up attendees into active and inactive arrays
            [self buildListingArrays];
            
            NSLog(@"ATTENDEES - Finished");
            block(YES, error);
            
        }else{
            block(YES, error);
        }
    }];
}

- (void)buildListingArrays{
    NSMutableArray *activeTemp = [[NSMutableArray alloc] init];
    NSMutableArray *inactiveTemp = [[NSMutableArray alloc] init];
    
    for (RLMListing *listing in self.allListings){
        
        if (([self listingBelongsToAgent:listing] && listing.hasPhotos) || listing.userAdded || listing.manuallyAdded){
            if (listing.isActive || listing.manuallyAdded || listing.userAdded){
                [activeTemp addObject:listing];
            }else{
                [inactiveTemp addObject:listing];
            }
        }
    }
    
    self.activeListings = [[[activeTemp copy] sortedByKey:@"listingTimestamp" ascending:NO] mutableCopy];
    self.inactiveListings = [[inactiveTemp copy] sortedByKey:@"listingTimestamp" ascending:NO];
    
    //Only active listings that have not previously been added can be added
    NSMutableArray *addTemp = [[NSMutableArray alloc] init];
    
    for (RLMListing *listing in self.allListings){
        
        //Can only add active listings
        if (listing.isActive && ![self.activeListings containsObject:listing]){
            [addTemp addObject:listing];
        }
    }
    
    self.listingsToAdd = [[addTemp copy] sortedByKey:@"listingTimestamp" ascending:NO];
}

- (BOOL)listingBelongsToAgent:(RLMListing *)listing{
    RLMAgent *agent = [DGUserManager sharedInstance].currentAgent;
    
    BOOL shouldAdd = NO;
    
    if ([listing.agentID isEqualToString:agent.liborNumber]){
        shouldAdd = YES;
    }
    
    if ((listing.coAgentID.length > 0 && agent.liborNumber.length > 0)
        &&
        ([listing.coAgentID isEqualToString:agent.liborNumber])){
        
        shouldAdd = YES;
    }
    
    if ((listing.agentID.length > 0 && agent.liborNumber2.length > 0)
        &&
        ([listing.agentID isEqualToString:agent.liborNumber2])){
        
        shouldAdd = YES;
    }
    
    if ((listing.coAgentID.length > 0 && agent.liborNumber2.length > 0)
        &&
        ([listing.coAgentID isEqualToString:agent.liborNumber2])){
        
        shouldAdd = YES;
    }
    
    return shouldAdd;
}


- (void)downloadListingImages:(void (^)(BOOL success, NSError *error)) block{
    
        dispatch_group_t group = dispatch_group_create();
        for (RLMListing *listing in self.allListings){
            
            if ([NSUserDefaults hasDownloadedImagesForListing:listing.listingID]){
                NSLog(@"Already downloaded images for this listing");
                continue;
            }
            
            for (int i = 0; i < listing.numberOfPhotos; i++){
                
                //Debug: Only load first photo
                if (i > (maxPhotos - 1)){ // -1 becasue we start at 0
                    break;
                }
                
                //Only download first image for non-agent listings
                if (![self listingBelongsToAgent:listing ] && i > 0){
                    break;
                }
                
                //Only download the first image for inactive listings
                if (!listing.isActive && i > 0){
                    break;
                }
                
                //[NSThread sleepForTimeInterval:.03];
                
                dispatch_group_enter(group);
                
               
                NSString *filename = [NSString stringWithFormat:@"dgPhotos/dgfoto/%@_%@.jpg",listing.mlsNumber, @(i)]; //TODO: move to DGAPI
              //  NSLog(@"filename = %@", filename);
                NSArray *paths = NSSearchPathForDirectoriesInDomains(useCacheDirectory ? NSCachesDirectory : NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSLog(@"filePath on downloading = %@", filePath);
                
               
                if (![fileManager fileExistsAtPath:filePath]){
                    NSLog(@"File doesn't exist");
                //    [NSThread sleepForTimeInterval:0.3]; //TODO: If crashing, move this back where it was in last commit
                //    DGServer downloadImage:photoURL filename:filename completion:^(BOOL success, NSError *error) {
                        dispatch_group_leave(group); //Leave group when request completes
                  //  }];
                    
                }else{
                    NSLog(@"File already exists");
                    dispatch_group_leave(group); //Leave group when request completes
                }
            }
        }

        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Perform Task back in the main thread
            // Here we wait for all the requests to finish
                NSLog(@"Images request finished");
                
                for (RLMListing *listing in self.allListings){
                    NSMutableArray *images = [NSMutableArray new];
                    
                    for (int i = 0; i < listing.numberOfPhotos; i++){
                        NSString *image = [UIImage imageFilenameForListing:listing.mlsNumber atIndex:i];
                        if (image){
                            RealmString *string = [[RealmString alloc] init];
                            string.stringValue = image;
                            [images addObject:string];
                        }
                    }
                    
                    //            dispatch_async(dispatch_queue_create("background", 0), ^{
                    RLMRealm *realm = [RLMRealm defaultRealm];
                    [realm beginWriteTransaction];
                    listing.images = [images copy];
                    [realm commitWriteTransaction];
                    
                    //            });
                    [NSUserDefaults setHasDownloadedImagesForListing:listing.listingID value:YES];
                }
              //  */
                block(YES, nil);

        });
   // });

}

- (void)downloadFiles:(void (^)(BOOL success, NSError *error)) block{
    NSLog(@"FILES - Starting");

    [DGServer getFiles:^(BOOL success, NSError *error, NSArray *files) {
        @try {

        
        if (success && files){
            
            RLMRealm *realm = [RLMRealm defaultRealm];

            for (DGFile *file in files){
                for (RLMAttendee *attendee in self.listingAttendees){
                    if ([attendee.cardFileID isEqualToString:file.fileID]){
                        
                        RLMFile *realmFile = [[RLMFile alloc] initWithJSONModel:file];
                        [realm beginWriteTransaction];
                        attendee.file = realmFile;
                        [realm commitWriteTransaction];
                    }
                }
                
                for (RLMAttendee *attendee in [DGEventsManager sharedInstance].eventAttendees){
                    if ([attendee.cardFileID isEqualToString:file.fileID]){
                        RLMFile *realmFile = [[RLMFile alloc] initWithJSONModel:file];
                        [realm beginWriteTransaction];
                        attendee.file = realmFile;
                        [realm commitWriteTransaction];
                    }
                }
            }
            
            NSLog(@"FILES - Finished");
            block(YES, nil);
            
        }else{
            block(NO, error);
        }
        } @catch (NSException *exception) {
            block(YES, nil);
            NSLog(@"exception in file downloading = %@", exception.reason);
        }
    }];
}

- (void)sync:(void (^)(BOOL success)) block{
    
    //Don't sync if no network
    if (![[AFNetworkReachabilityManager sharedManager] isReachable]){
        block(NO);
        return;
    }
    
    __block BOOL allSuccess = YES;
    dispatch_group_t group = dispatch_group_create();
    
    //Sync attendees
    NSLog(@"SYNC - Starting");
    
    //Listings
    NSMutableArray *listingAttendees = [[NSMutableArray alloc] init];
    
    for (RLMListing *listing in self.activeListings){
        if (listing.attendees.count > 0){
            for (RLMAttendee *attendee in listing.attendees){
                [listingAttendees addObject:attendee];
            }
        }
    }
    
    for (RLMListing *listing in self.inactiveListings){
        for (RLMAttendee *attendee in listing.attendees){
            [listingAttendees addObject:attendee];
        }
    }
    
    for (RLMAttendee *attendee in listingAttendees){
        if (attendee.needsSynced){
            //Send to server
            
            // Enter the group for each request we create
            dispatch_group_enter(group);
            
            [DGServer syncListingAttendee:attendee callback:^(BOOL success, NSError *error) {
                if (!success){
                    allSuccess = NO;
                }else{
                    RLMRealm *realm = [RLMRealm defaultRealm];
                    [realm beginWriteTransaction];
                    attendee.needsSynced = NO;
                    [realm commitWriteTransaction];
                }
                dispatch_group_leave(group); //Leave group when request completes
            }];
        }
    }
    
    //Events
    NSMutableArray *events = [[NSMutableArray alloc] init];
    
    for (RLMEvent *event in [DGEventsManager sharedInstance].allEvents){
        if (event.needsSynced && event.attendees.count > 0){
            [events addObject:event];
        }
    }
    
    dispatch_group_enter(group);
    [DGServer syncEvents:events callback:^(BOOL success, NSError *error) {
        if (!success){
            allSuccess = NO;
        }
        dispatch_group_leave(group); //Leave group when request completes
    }];
    
    //Event attendees
    NSMutableArray *eventAttendees = [[NSMutableArray alloc] init];
    
    for (RLMEvent *event in [DGEventsManager sharedInstance].allEvents){
        for (RLMAttendee *attendee in event.attendees){
            [listingAttendees addObject:attendee];
        }
    }
    
    for (RLMAttendee *attendee in eventAttendees){
        if (attendee.needsSynced){
            //Send to server
            
            // Enter the group for each request we create
            dispatch_group_enter(group);
            
            [DGServer syncEventAttendee:attendee callback:^(BOOL success, NSError *error) {
                if (!success){
                    allSuccess = NO;
                }else{
                    RLMRealm *realm = [RLMRealm defaultRealm];
                    [realm beginWriteTransaction];
                    attendee.needsSynced = NO;
                    [realm commitWriteTransaction];
                }
                dispatch_group_leave(group); //Leave group when request completes
            }];
        }
    }
    
    // Here we wait for all the requests to finish
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"SYNC - Finished");
        block(allSuccess);
    });
}

@end