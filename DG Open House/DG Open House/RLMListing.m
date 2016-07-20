//
//  RLMListing.m
//  DG Open House
//
//  Created by Chase Acton on 5/14/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "RLMListing.h"
#import "UIImage+DGImage.h"

@implementation RLMListing

- (id)initWithJSONModel:(DGListing *)listing{
    self = [super init];
    if(!self) return nil;
    
    self.listingID          = listing.listingID;
    self.address            = listing.address;
    self.state              = listing.state;
    self.town               = listing.town;
    self.mlsNumber          = listing.mlsNumber;
    self.listingDate        = listing.listingDate;
    self.agentID            = listing.agentID;
    self.coAgentID          = listing.coAgentID;
    self.listingTimestamp   = listing.listingTimestamp;
    self.zip                = listing.zip;
    self.photoURL           = listing.photoURL;
    self.apartmentNumber    = listing.apartmentNumber;
    self.unitNumber         = listing.unitNumber;
    self.status             = listing.status;
    self.numberOfPhotos     = listing.numberOfPhotos;
    self.isActive           = listing.isActive;
    self.hasPhotos          = listing.hasPhotos;
    
    return self;
}

+ (NSString *)primaryKey {
    return @"listingID";
}

+ (NSDictionary *)defaultPropertyValues {
    return @{
             @"manuallyAdded" : [NSNumber numberWithBool:NO],
             @"userAdded" : [NSNumber numberWithBool:NO],
             @"needsSynced" : [NSNumber numberWithBool:NO],
             };
}

- (NSString *)prettyFullAddress{
    return [NSString stringWithFormat:@"%@, %@, %@, %@ MLS# %@",
            self.prettyAddress,
            self.town,
            self.state,
            self.zip,
            self.mlsNumber];
}

- (NSString *)prettyFullAddressNoMLS{
    return [NSString stringWithFormat:@"%@, %@, %@, %@",
            self.prettyAddress,
            self.town,
            self.state,
            self.zip];
}

- (NSString *)prettyAddress{
    NSString *addressString = self.address;
    
    if (self.unitNumber.length > 0){
        return [addressString stringByAppendingString:[NSString stringWithFormat:@" - %@", self.unitNumber]];
        
    }else if (self.apartmentNumber.length > 0){
        return [addressString stringByAppendingString:[NSString stringWithFormat:@" - Apt %@", self.apartmentNumber]];
        
    }else{
        return self.address;
    }
}

@end