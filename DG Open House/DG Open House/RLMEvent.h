//
//  RLMEvent.h
//  DG Open House
//
//  Created by Chase Acton on 5/14/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <Realm/Realm.h>
//#import "RLMAttendee.h"
//#import "RealmString.h"

@class RLMAttendee;
@class RealmString;
@class DGEvent;

RLM_ARRAY_TYPE(RLMAttendee)
RLM_ARRAY_TYPE(RealmString)

@interface RLMEvent : RLMObject

- (id)initWithJSONModel:(DGEvent *)event;

@property NSString *eventID;
@property NSString *agentID;
@property NSString *name;
@property NSDate *eventDate;
@property (readonly) NSString *prettyDate;
@property RLMArray <RLMAttendee> *attendees;
@property RLMArray <RealmString> *images; //Array of filename stings

@property BOOL needsSynced;

- (NSDictionary *)serverData;

@end