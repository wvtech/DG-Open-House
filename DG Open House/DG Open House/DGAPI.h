//
//  DGAPI.h
//  DG Open House
//
//  Created by Chase Acton on 2/1/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLMListing;
@class DGFile;

@interface DGAPI : NSObject

#pragma mark - User

+ (NSURL *)signInURL;
+ (NSURL *)forgotPasswordURL;

#pragma mark - Listings

+ (NSURL *)listingsURL;
+ (NSURL *)photoForListing:(RLMListing *)listing atIndex:(NSInteger)index;
+ (NSURL *)listingAttendeesURL;

#pragma mark - Files

+ (NSURL *)filesURL;
+ (NSURL *)downloadURLForFile:(DGFile *)file;
+ (NSURL *)uploadURLForFileUUID:(NSString *)uuid;
+ (NSURL*) downloadingZipUrl;

#pragma mark - Attendees

+ (NSURL *)promoteURL;

#pragma mark - Events

+ (NSURL *)eventsURL;
+ (NSURL *)eventAttendeesURL;

@end