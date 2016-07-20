//
//  DGAttendee.m
//  DG Open House
//
//  Created by Chase Acton on 4/19/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGAttendee.h"
#import "SGFormatter.h"
#import "DGListing.h"
#import "DGUserManager.h"
#import "DGEvent.h"

@interface DGAttendee ()

@property (nonatomic) NSString <Optional> *serverPhone;
@property (nonatomic) NSString <Optional> *serverAttendeeType;
@property (nonatomic) NSString *serverCreatedAt;

@end

@implementation DGAttendee

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"attendeeID",
                                                       @"first_name": @"firstName",
                                                       @"last_name": @"lastName",
                                                       @"property_id": @"listingID",
                                                       @"phone": @"serverPhone",
                                                       @"attendee_type": @"serverAttendeeType", // A or B
                                                       @"created_at": @"serverCreatedAt",
                                                       @"card_file_id": @"cardFileID",
                                                       @"card_process_needed" : @"cardProcessNeeded",
                                                       @"event_id": @"eventID",
                                                       }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"rating"] || [propertyName isEqualToString:@"isBuyer"] || [propertyName isEqualToString:@"needsSynced"]){
        return YES;
    }
    
    return NO;
}

- (BOOL)validate:(NSError *__autoreleasing *)error {
    BOOL valid = [super validate:error];
    
    self.serverPhone = [self.serverPhone stringByReplacingOccurrencesOfString:@"+1" withString:@""];
    
    //Transform phone number
    NSCharacterSet *setToRemove = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    NSString *phoneString = [[self.serverPhone componentsSeparatedByCharactersInSet:setToRemove] componentsJoinedByString:@""];
    self.phone = phoneString;
    
    //Attendee type
    if (self.serverAttendeeType){
        if ([self.serverAttendeeType isEqualToString:@"A"]){
            self.isBuyer = NO;
        }else{
            self.isBuyer = YES;
        }
    }
    
    if (self.response_code_1){
        self.buyTime = [self buyTimeFromServer];
    }
    
    if (self.response_code_2){
        [self setResponseCode2];
    }
    
    //Date
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"]; //2016-04-30T21:51:12+00:00
    self.date = [df dateFromString:self.serverCreatedAt];
    
    return valid;
}

#pragma mark - Buy Time

//Convert pretty answer to server format
- (NSString *)buyTimeAnswer{
    if (!self.buyTime){
        return nil;
    }
    
    if ([self.buyTime isEqualToString:@"ASAP"]){
        return @"0";
        
    }else if ([self.buyTime isEqualToString:@"3 Months"]){
        return @"3";
        
    }else if ([self.buyTime isEqualToString:@"6 Months"]){
        return @"6";
        
    }else if ([self.buyTime isEqualToString:@"12 Months"]){
        return @"12";
    }
    
    return nil;
}

//Convert server format to pretty format for display
- (NSString *)buyTimeFromServer{
    if (!self.response_code_1){
        return nil;
    }
    
    if ([self.response_code_1 isEqualToString:@"0"]){
        return @"ASAP";
        
    }else if ([self.response_code_1 isEqualToString:@"3"]){
        return @"3 Months";
        
    }else if ([self.response_code_1 isEqualToString:@"6"]){
        return @"6 Months";
        
    }else if ([self.response_code_1 isEqualToString:@"12"]){
        return @"12 Months";
    }
    
    return nil;
}

#pragma mark - Referral Source

- (void)setResponseCode2{
    if (!self.response_code_2){
        return;
    }
    
    if (self.response_text_2){
        self.referralSourceOther = self.response_text_2;
    }
    
    if ([self.response_code_2 isEqualToString:@"SIGN"]){
        self.referralSourceMain = @"Sign Outside";
        
    }else if ([self.response_code_2 isEqualToString:@"OTHER"]){
        self.referralSourceMain = @"Other";
        
    }else if ([self.response_code_2 isEqualToString:@"INTERNET"]){
        self.referralSourceMain = @"Internet";
        
    }else if ([self.response_code_2 isEqualToString:@"NEWSPAPER"]){
        self.referralSourceMain = @"Newspaper";
    }
}

@end