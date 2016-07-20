//
//  DGEventsManager.m
//  DG Open House
//
//  Created by Chase Acton on 5/6/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGEventsManager.h"
#import "DGServer.h"
#import "DGEvent.h"
#import "DGAttendee.h"
#import "RLMEvent.h"
#import "RLMListing.h"

@implementation DGEventsManager

+ (instancetype)sharedInstance {
    static DGEventsManager *sharedMyInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyInstance = [[self alloc] init];
    });
    return sharedMyInstance;
}

- (id)init{
    self = [super init];
    if (self != nil){
        self.allEvents = [[NSMutableArray alloc] init];
        [self loadEventsFromDisk];
    }
    return self;
}

- (void)loadEventsFromDisk{
    RLMRealm *realmMainThread = [RLMRealm defaultRealm];
    RLMResults *events = [RLMEvent allObjectsInRealm:realmMainThread];
    
    NSMutableArray *eventsTemp = [[NSMutableArray alloc] init];
    for (RLMEvent *event in events){
        [eventsTemp addObject:event];
    }
    
    self.allEvents = [[NSMutableArray alloc] initWithArray:[eventsTemp copy]];
}

- (void)getEvents:(void (^)(BOOL success, NSError *error)) block{
    [DGServer getEvents:^(BOOL success, NSError *error, NSArray *events) {
        if (success){
            RLMRealm *realm = [RLMRealm defaultRealm];
            
            [realm beginWriteTransaction];
            for (DGEvent *event in events){
                RLMEvent *rlmListing = [[RLMEvent alloc] initWithJSONModel:event];
                [RLMEvent createOrUpdateInDefaultRealmWithValue:rlmListing];
            }
            [realm commitWriteTransaction];
            
            RLMResults *realmEvents = [RLMEvent allObjectsInRealm:realm];
            
            NSMutableArray *eventsTemp = [[NSMutableArray alloc] init];
            for (RLMListing *listing in realmEvents){
                [eventsTemp addObject:listing];
            }
            
            self.allEvents = [[NSMutableArray alloc] initWithArray:[eventsTemp copy]];
        }
        block(success, error);
    }];
}

- (void)getEventAttendees:(void (^)(BOOL success, NSError *error)) block{
    [DGServer getEventAttendees:^(BOOL success, NSError *error, NSArray *attendees) {
        if (success){
            
            RLMRealm *realm = [RLMRealm defaultRealm];
            for (DGAttendee *attendee in attendees){
                [realm beginWriteTransaction];
                
                RLMAttendee *realmAttendee = [[RLMAttendee alloc] initWithJSONModel:attendee];
                [RLMAttendee createOrUpdateInDefaultRealmWithValue:realmAttendee];
                [realm commitWriteTransaction];
            }
            
            RLMResults *attendees = [RLMAttendee allObjectsInRealm:realm];
            
            NSMutableArray *attendeesTemp = [[NSMutableArray alloc] init];
            for (RLMListing *listing in attendees){
                [attendeesTemp addObject:listing];
            }
            
            self.eventAttendees = [[NSArray alloc] initWithArray:[attendeesTemp copy]];
            
            //Now we need to add attendees to their respective events
            for (RLMEvent *event in self.allEvents){
                for (RLMAttendee *attendee in self.eventAttendees){
                    if ([attendee.eventID isEqualToString:event.eventID]){
                        [realm beginWriteTransaction];
                        
                        attendee.eventID = event.eventID;
                        [event.attendees addObject:attendee];
                        
                        [realm commitWriteTransaction];
                    }
                }
            }
            block(success, error);
        }else{
            block(success, error);
        }
    }];
}

- (RLMEvent *)eventWithID:(NSString *)eventID{
    for (RLMEvent *event in self.allEvents){
        if ([event.eventID isEqualToString:eventID]){
            return event;
            break;
        }
    }
    return nil;
}

@end