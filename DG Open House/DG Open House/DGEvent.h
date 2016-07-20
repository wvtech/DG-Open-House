//
//  DGEvent.h
//  DG Open House
//
//  Created by Chase Acton on 5/6/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@class DGAttendee;

@interface DGEvent : JSONModel

@property (nonatomic) NSString *eventID;
@property (nonatomic) NSString *agentID;
@property (nonatomic) NSString *name;
@property (nonatomic) NSDate <Ignore> *eventDate;

//@property (nonatomic) NSMutableArray <DGAttendee *> <Ignore> *attendees;
@property (nonatomic) NSMutableArray <Ignore> *images;

@property (nonatomic) BOOL needsSynced;

@end

/*

 {
 "id": "dd33a644-9798-4e06-b710-4a6fb70eee7f",
 "ldapuser_id": "539639",
 "name": "Test event",
 "event_date": "2016-05-06T00:00:00+00:00",
 "mob_created_at": "2016-05-06T02:53:22+00:00",
 "created_at": "2016-05-06T16:57:24+00:00",
 "updated_at": "2016-05-06T16:57:24+00:00"
 }

*/