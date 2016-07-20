//
//  DGListing.h
//  DG Open House
//
//  Created by Chase Acton on 2/10/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import <UIKit/UIKit.h>

@class DGAttendee;

@interface DGListing : JSONModel

@property (nonatomic) NSString *listingID;
@property (nonatomic) NSString *address;
@property (nonatomic) NSString *state;
@property (nonatomic) NSString *town;
@property (nonatomic) NSString *mlsNumber;
@property (nonatomic) NSString *listingDate;
@property (nonatomic) NSString *agentID;
@property (nonatomic) NSString *coAgentID;
@property (nonatomic) NSString *listingTimestamp;
@property (nonatomic) NSString *zip;
@property (nonatomic) NSString *photoURL;
@property (nonatomic) NSString <Optional> *apartmentNumber;
@property (nonatomic) NSString <Optional> *unitNumber;
@property (nonatomic) NSString *status;

@property (nonatomic) NSInteger numberOfPhotos;

@property (nonatomic) BOOL isActive;
@property (nonatomic) BOOL hasPhotos;

@property (nonatomic) NSMutableArray <DGAttendee *> <Ignore> *attendees;
@property (nonatomic) NSMutableArray <Ignore> *images;

@end