//
//  DGListing.m
//  DG Open House
//
//  Created by Chase Acton on 2/10/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGListing.h"
#import "UIImage+DGImage.h"

@interface DGListing ()

@property (nonatomic) NSString *photo_downloaded;

@end

@implementation DGListing

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"listingID",
                                                       @"Addr": @"address",
                                                       @"Ml_num": @"mlsNumber",
                                                       @"Photo_count" : @"numberOfPhotos",
                                                       @"Photo_ts" : @"listingDate",
                                                       @"Status" : @"status",
                                                       @"Agent_id" : @"agentID",
                                                       @"Co_lagt_id" : @"coAgentID",
                                                       @"List_timestamp" : @"listingTimestamp",
                                                       @"Ste": @"state",
                                                       @"Town": @"town",
                                                       @"photo_url": @"photoURL",
                                                       @"Zip": @"zip",
                                                       @"Apt_num": @"apartmentNumber",
                                                       @"Unit_num": @"unitNumber",
                                                       }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"needsSynced"] || [propertyName isEqualToString:@"manuallyAdded"] || [propertyName isEqualToString:@"hasPhotos"] || [propertyName isEqualToString:@"isActive"]){
        return YES;
    }
    
    return NO;
}

- (BOOL)validate:(NSError *__autoreleasing *)error {
    BOOL valid = [super validate:error];
    
    if ([self.status isEqualToString:@"A"]){
        self.isActive = YES;;
    }
    
    if ([self.photo_downloaded isEqualToString:@"1"]){
        self.hasPhotos = YES;
    }
    
    return valid;
}

- (NSMutableArray *)images{
    //Order images and add to listing
    
    if (!_images) {
        _images = [NSMutableArray new];
        
        for (int i = 0; i < self.numberOfPhotos; i++){
            UIImage *image = [UIImage imageForListing:self.mlsNumber atIndex:i];
            if (image){
                [_images addObject:image];
            }
        }
    }
    return _images;
}

@end