//
//  DGEvent.m
//  DG Open House
//
//  Created by Chase Acton on 5/6/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGEvent.h"

@interface DGEvent ()

@property (nonatomic) NSString *serverDate;

@end

@implementation DGEvent

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"eventID",
                                                       @"ldapuser_id": @"agentID",
                                                       @"event_date": @"serverDate",
                                                       }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"needsSynced"]){
        return YES;
    }
    
    return NO;
}

- (BOOL)validate:(NSError *__autoreleasing *)error {
    BOOL valid = [super validate:error];
    
    //Date
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"]; //2016-04-30T21:51:12+00:00
    self.eventDate = [df dateFromString:self.serverDate];
    
    return valid;
}

@end