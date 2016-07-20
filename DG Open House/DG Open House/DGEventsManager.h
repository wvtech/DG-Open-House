//
//  DGEventsManager.h
//  DG Open House
//
//  Created by Chase Acton on 5/6/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLMEvent;

@interface DGEventsManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic) NSMutableArray *allEvents;
@property (nonatomic) NSArray *eventAttendees;

- (void)loadEventsFromDisk;
- (void)getEvents:(void (^)(BOOL success, NSError *error)) block;
- (void)getEventAttendees:(void (^)(BOOL success, NSError *error)) block;
- (RLMEvent *)eventWithID:(NSString *)eventID;

@end