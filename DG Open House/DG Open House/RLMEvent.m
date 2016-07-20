//
//  RLMEvent.m
//  DG Open House
//
//  Created by Chase Acton on 5/14/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "RLMEvent.h"
#import "DGEvent.h"

@implementation RLMEvent

- (id)initWithJSONModel:(DGEvent *)event{
    self = [super init];
    if(!self) return nil;
    
    self.eventID      = event.eventID;
    self.agentID      = event.agentID;
    self.name         = event.name;
    self.eventDate    = event.eventDate;
    self.needsSynced  = event.needsSynced;
    
    return self;
}

- (NSString *)prettyDate{
    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
    [dateFormat2 setDateFormat:@"M/d/yyyy"];
    return [dateFormat2 stringFromDate:self.eventDate];
}

- (NSDictionary *)serverData{
    NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
    
    output[@"id"] = self.eventID;
    output[@"ldapuser_id"] = self.agentID;
    output[@"name"] = self.name;
    
    //Date
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"]; //2016-04-30T21:51:12+00:00
    output[@"mob_created_at"] = [df stringFromDate:[NSDate date]];
    
    if (self.eventDate){
        output[@"event_date"] = [df stringFromDate:self.eventDate];
    }
    
    return [output copy];
}

+ (NSString *)primaryKey {
    return @"eventID";
}

@end