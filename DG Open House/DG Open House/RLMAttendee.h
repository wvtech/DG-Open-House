//
//  RLMAttendee.h
//  DG Open House
//
//  Created by Chase Acton on 5/15/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <Realm/Realm.h>

#import "DGAttendee.h"

@class RLMListing;
@class RLMFile;

RLM_ARRAY_TYPE(RLMAttendee)

@interface RLMAttendee : RLMObject

- (id)initWithJSONModel:(DGAttendee *)attendee;

@property NSString *attendeeID;

@property BOOL isBuyer;
@property BOOL needsSynced;
@property BOOL cardProcessNeeded;

@property NSInteger rating;

@property NSString *firstName;
@property NSString *lastName;
@property (readonly) NSString *fullName;
@property NSString *email;
@property NSString *phone;
@property NSString *notes;
@property NSDate *date;
@property NSString *cardFileID;

//Buyer
@property NSString *buyTime; //ASAP, 3 months, 6 months, 12 months
@property NSString *referralSourceMain; //Newspaper, Sign Outside, Broker, Email, Other
@property NSString *referralSourceOther; //NY Times, DanielGale.com, etc.
@property (readonly) NSString *referralSourcePretty; //NY Times, DanielGale.com, etc.

//Agent
@property NSString *brokerage;

@property RLMFile *file;
@property NSString *listingID;
@property NSString *eventID;

@property NSString *response_code_1;
@property NSString *response_code_2;
@property NSString *response_text_2;

@property (readonly) RLMListing *listing;

- (NSDictionary *)tableViewDictionary;
- (NSDictionary *)serverData;

@end