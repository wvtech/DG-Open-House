//
//  DGAttendee.h
//  DG Open House
//
//  Created by Chase Acton on 4/19/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONModel.h"

@class DGListing;
@class DGFile;
@class DGEvent;

@interface DGAttendee : JSONModel

@property (nonatomic) NSString *attendeeID;

@property (nonatomic) BOOL isBuyer;
@property (nonatomic) BOOL needsSynced;
@property (nonatomic) BOOL cardProcessNeeded;

@property (nonatomic) NSInteger rating;

@property (nonatomic) NSString <Optional> *firstName;
@property (nonatomic) NSString <Optional> *lastName;
@property (nonatomic) NSString <Optional> *email;
@property (nonatomic) NSString <Optional> *phone;
@property (nonatomic) NSString <Optional> *notes;
@property (nonatomic) NSDate <Ignore> *date;
@property (nonatomic) NSString <Optional> *cardFileID;

//Buyer
@property (nonatomic) NSString <Optional> *buyTime; //ASAP, 3 months, 6 months, 12 months
@property (nonatomic) NSString <Optional> *referralSourceMain; //Newspaper, Sign Outside, Broker, Email, Other
@property (nonatomic) NSString <Optional> *referralSourceOther; //NY Times, DanielGale.com, etc.

//Agent
@property (nonatomic) NSString <Optional> *brokerage;

@property (nonatomic) DGListing <Ignore> *listing;
@property (nonatomic) DGEvent <Ignore> *event;

@property (nonatomic) DGFile <Ignore> *file;
@property (nonatomic) NSString <Optional> *listingID;
@property (nonatomic) NSString <Optional> *eventID;

@property (nonatomic) NSString <Optional> *response_code_1;
@property (nonatomic) NSString <Optional> *response_code_2;
@property (nonatomic) NSString <Optional> *response_text_2;

@end