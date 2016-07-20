//
//  DGAPI.m
//  DG Open House
//
//  Created by Chase Acton on 2/1/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGAPI.h"
#import "DGListing.h"
#import "DGConstants.h"
#import "DGFile.h"
#import "RLMListing.h"

@implementation DGAPI

//API Endpoints
static NSString * const session             = @"/session";
static NSString * const login               = @"/login";
static NSString * const api                 = @"/api";
static NSString * const images              = @"/images";
static NSString * const brs                 = @"/brs";
static NSString * const property            = @"/property";
static NSString * const listingAttendees    = @"/property_attendee";
static NSString * const properties          = @"/properties";
static NSString * const syncURL             = @"/sync";
static NSString * const mailing             = @"/mailing";
static NSString * const promoteoh           = @"/promoteoh";
static NSString * const event               = @"/event";
static NSString * const userFile            = @"/user_file";
static NSString * const upload              = @"/upload";
static NSString * const download            = @"/download";
static NSString * const eventAttendees      = @"/event_attendee";
static NSString * const forgot              = @"/forgot";

#pragma mark - User

+ (NSURL *)signInURL{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@/",
                                 DGBaseURL, session, login]];
}

+ (NSURL *)forgotPasswordURL{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@/",
                                 DGBaseURL, session, forgot]];
}

#pragma mark - Listings

+ (NSURL *)listingsURL{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/",
                                 DGBaseURL, property]];
}

+ (NSURL*) downloadingZipUrl {
    return [NSURL URLWithString: [NSString stringWithFormat:@"%@", DGImageUrlZip]];
}

+ (NSURL *)photoForListing:(RLMListing *)listing atIndex:(NSInteger)index{
    
    if (!listing.photoURL){
        return nil;
    }
    
    NSString *dateString = listing.photoURL; ///var/www/html/images/brs/properties/2016/03/17/
    dateString = [dateString stringByReplacingOccurrencesOfString:@"/var/www/html/images/brs/properties/" withString:@""];
    dateString = [dateString substringToIndex:dateString.length];
    
    //https://dgapi.danielgale.com/images/brs/properties/2015/09/02/2793413_0.jpg
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@/%@%@_%@.jpg",
                                 DGBasePhotoURL, images, brs, properties, dateString, listing.mlsNumber, @(index)]];
}

+ (NSURL *)listingAttendeesURL{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@/",
                                 DGBaseURL, listingAttendees, syncURL]];
}

#pragma mark - Files

+ (NSURL *)filesURL{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@/",
                                 DGBaseURL, userFile, syncURL]];
}

+ (NSURL *)downloadURLForFile:(DGFile *)file{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@%@/",
                                 DGBaseURL, userFile, file.fileID, download]];
}

+ (NSURL *)uploadURLForFileUUID:(NSString *)uuid{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@%@/",
                                 DGBaseURL, userFile, uuid, upload]];
}

#pragma mark - Attendees

+ (NSURL *)promoteURL{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@/",
                                 DGBaseURL, mailing, promoteoh]];
}

#pragma mark - Events

+ (NSURL *)eventsURL{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@/",
                                 DGBaseURL, event, syncURL]];
}

+ (NSURL *)eventAttendeesURL{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@/",
                                 DGBaseURL, eventAttendees, syncURL]];
}

@end