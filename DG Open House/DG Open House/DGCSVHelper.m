//
//  DGCSVHelper.m
//  DG Open House
//
//  Created by Chase Acton on 5/2/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGCSVHelper.h"
#import "SGFormatter.h"
#import "RLMAttendee.h"
#import "DGListingsManager.h"
#import "RLMListing.h"

@implementation DGCSVHelper

+ (NSData *)csvFromAttendees:(NSArray *)attendees{
    NSArray *keys = @[@"Property", @"Attendee", @"Type", @"Visited", @"Email", @"Phone", @"Brokerage", @"Rating", @"Notes", @"How soon are you looking to buy?", @"How did you hear about this listing?"];
    NSMutableArray *data = [NSMutableArray arrayWithObjects:keys, nil];
    
    for (RLMAttendee *attendee in attendees){
        NSMutableArray *attendeeArray = [[NSMutableArray alloc] init];
        
        RLMListing *listing = [[DGListingsManager sharedInstance] listingWithID:attendee.listingID];
        [attendeeArray addObject:listing.prettyFullAddress];
        
        if (!attendee.firstName || !attendee.lastName){
            [attendeeArray addObject:@"(Not Available)"];
        }else{
            [attendeeArray addObject:attendee.fullName];
        }
        
        [attendeeArray addObject:attendee.isBuyer ? @"Buyer" : @"Agent"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"M/d/yyyy";
        NSString *date = [dateFormatter stringFromDate:attendee.date];
        [attendeeArray addObject:date];
        
        [attendeeArray addObject:attendee.email ? attendee.email : @""];
        [attendeeArray addObject:attendee.phone ? [SGFormatter formatPhoneNumber:attendee.phone deleteLastChar:NO] : @""];
        [attendeeArray addObject:attendee.brokerage ? attendee.brokerage : @""];
        
        if (attendee.rating > 0){
            [attendeeArray addObject:[NSString stringWithFormat:@"%@", @(attendee.rating)]];
        }else{
            [attendeeArray addObject:@""];
        }
        
        if (attendee.notes.length > 0){
            [attendeeArray addObject:attendee.notes];
        }else{
            [attendeeArray addObject:@""];
        }
        
        if (attendee.buyTime.length > 0){
            [attendeeArray addObject:attendee.buyTime];
        }else{
            [attendeeArray addObject:@""];
        }
        
        if (attendee.referralSourcePretty){
            [attendeeArray addObject:attendee.referralSourcePretty];
        }else{
            [attendeeArray addObject:@""];
        }
        
        //Add to export
        [data addObject:[attendeeArray copy]];
    }

    return [self csvFromData:[data copy]];
}

+ (NSData *)eventCsvFromAttendees:(NSArray *)attendees{
    NSArray *keys = @[@"Attendee", @"Visited", @"Email", @"Phone", @"Rating", @"Notes"];
    NSMutableArray *data = [NSMutableArray arrayWithObjects:keys, nil];
    
    for (RLMAttendee *attendee in attendees){
        NSMutableArray *attendeeArray = [[NSMutableArray alloc] init];
        
        [attendeeArray addObject:attendee.fullName];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"M/d/yyyy";
        NSString *date = [dateFormatter stringFromDate:attendee.date];
        [attendeeArray addObject:date];
        
        [attendeeArray addObject:attendee.email];
        [attendeeArray addObject:[SGFormatter formatPhoneNumber:attendee.phone deleteLastChar:NO]];
        
        if (attendee.rating > 0){
            [attendeeArray addObject:[NSString stringWithFormat:@"%@", @(attendee.rating)]];
        }else{
            [attendeeArray addObject:@""];
        }
        
        if (attendee.notes.length > 0){
            [attendeeArray addObject:attendee.notes];
        }else{
            [attendeeArray addObject:@""];
        }
        
        //Add to export
        [data addObject:[attendeeArray copy]];
    }
    
    return [self csvFromData:[data copy]];
}

+ (NSData *)csvFromData:(NSArray *)data{
    NSMutableString *csv = [NSMutableString string];
    
    for (NSArray *line in data){
        
        NSMutableArray * formattedLine = [NSMutableArray array];
        for (NSString *fieldValue in line) {
            
            NSString *field = fieldValue;
            NSRange r = [field rangeOfString:@","];
            BOOL shouldQuote = NO;
            
            //Fields that contain a , must be quoted
            if (r.location != NSNotFound) {
                shouldQuote = YES;
            }
            r = [field rangeOfString:@"\""];
            
            //Fields that contain a " must have them escaped to "" and be quoted
            if (r.location != NSNotFound) {
                field = [field stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
                shouldQuote = YES;
            }
            
            if (shouldQuote == YES) {
                [formattedLine addObject:[NSString stringWithFormat:@"\"%@\"", field]];
            } else {
                [formattedLine addObject:field];
            }
        }
        
        NSString *combinedLine = [formattedLine componentsJoinedByString:@","];
        [csv appendFormat:@"%@\n", combinedLine];
    }
    
    return [csv dataUsingEncoding:NSUTF8StringEncoding];
}

@end