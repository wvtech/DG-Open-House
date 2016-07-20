//
//  DGListingsManager.h
//  DG Open House
//
//  Created by Chase Acton on 2/10/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLMListing;

@interface DGListingsManager : NSObject

+ (instancetype)sharedInstance;

- (void)startSyncTimer;

- (void)loadListingsFromDisk;
- (void)getListings:(void (^)(BOOL success, NSError *error)) block;
- (void)getListingAttendees:(void (^)(BOOL success, NSError *error)) block;
- (void)downloadListingImages:(void (^)(BOOL success, NSError *error)) block;
- (void)sync:(void (^)(BOOL success)) block;
- (void)downloadFiles:(void (^)(BOOL success, NSError *error)) block;
- (RLMListing *)listingWithID:(NSString *)listingID;

@property (nonatomic) NSArray *inactiveListings;
@property (nonatomic) NSMutableArray *activeListings;
@property (nonatomic) NSArray *listingsToAdd;

@property (nonatomic) BOOL syncInProgress;

@end