//
//  RLMListing.h
//  DG Open House
//
//  Created by Chase Acton on 5/14/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <Realm/Realm.h>
#import <UIKit/UIKit.h>

#import "DGAttendee.h"
#import "DGListing.h"
#import "RealmString.h"
#import "RLMAttendee.h"

RLM_ARRAY_TYPE(RLMAttendee)
RLM_ARRAY_TYPE(RealmString)

@interface RLMListing : RLMObject

- (id)initWithJSONModel:(DGListing *)listing;

@property NSString *listingID;
@property NSString *address;
@property NSString *state;
@property NSString *town;
@property NSString *mlsNumber;
@property NSString *listingDate;
@property NSString *agentID;
@property NSString *coAgentID;
@property NSString *listingTimestamp;
@property NSString *zip;
@property NSString *photoURL;
@property NSString *apartmentNumber;
@property NSString *unitNumber;
@property NSString *status;
@property NSInteger numberOfPhotos;

@property BOOL needsSynced;
@property BOOL manuallyAdded; //Added to listings manually
@property BOOL isActive;
@property BOOL hasPhotos;
@property BOOL userAdded; //Added to listings from pre-existing listing

@property RLMArray <RLMAttendee> *attendees;
@property RLMArray <RealmString> *images; //Array of filename stings

//Read only
@property (nonatomic, readonly) NSString *prettyFullAddress;
@property (nonatomic, readonly) NSString *prettyFullAddressNoMLS;
@property (nonatomic, readonly) NSString *prettyAddress;

@end