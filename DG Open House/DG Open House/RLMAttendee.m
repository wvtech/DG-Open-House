//
//  RLMAttendee.m
//  DG Open House
//
//  Created by Chase Acton on 5/15/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "RLMAttendee.h"
#import "DGUserManager.h"
#import "SGFormatter.h"
#import "DGListingsManager.h"

@implementation RLMAttendee

- (id)initWithJSONModel:(DGAttendee *)attendee{
    self = [super init];
    if(!self) return nil;
    
    self.attendeeID             = attendee.attendeeID;
    self.isBuyer                = attendee.isBuyer;
    self.needsSynced            = attendee.needsSynced;
    self.cardProcessNeeded      = attendee.cardProcessNeeded;
    self.rating                 = attendee.rating;
    self.firstName              = attendee.firstName;
    self.lastName               = attendee.lastName;
    self.email                  = attendee.email;
    self.phone                  = attendee.phone;
    self.notes                  = attendee.notes;
    self.date                   = attendee.date;
    self.cardFileID             = attendee.cardFileID;
    self.buyTime                = attendee.buyTime;
    self.referralSourceMain     = attendee.referralSourceMain;
    self.referralSourceOther    = attendee.referralSourceOther;
    self.brokerage              = attendee.brokerage;
    self.listingID              = attendee.listingID;
    self.eventID                = attendee.eventID;
    self.response_code_1        = attendee.response_code_1;
    self.response_code_2        = attendee.response_code_2;
    self.response_text_2        = attendee.response_text_2;
    
    return self;
}

- (NSUInteger)hash{
    NSUInteger result = 1;
    NSUInteger prime = 31;
    
    result = prime * result + [self.notes hash];
    result = prime * result + self.rating;
    
    return result;
}

+ (NSString *)primaryKey {
    return @"attendeeID";
}

- (NSString *)referralSourcePretty{
    if (!self.referralSourceMain){
        return nil;
    }
    
    if (self.referralSourceOther){
        return [NSString stringWithFormat:@"%@: %@", self.referralSourceMain, self.referralSourceOther];
        
    }else{
        return self.referralSourceMain;
    }
}

- (NSString *)fullName{
    if (!self.firstName || !self.lastName){
        return @"(Not Available)";
        
    }else{
        return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    }
}

- (id)copyWithZone: (NSZone *)zone{
    RLMAttendee *copy = [[RLMAttendee allocWithZone:zone] init];
    
    copy.attendeeID             = self.attendeeID;
    copy.firstName              = self.firstName;
    copy.lastName               = self.lastName;
    copy.phone                  = self.phone;
    copy.email                  = self.email;
    copy.rating                 = self.rating;
    copy.isBuyer                = self.isBuyer;
    copy.notes                  = self.notes;
    copy.date                   = self.date;
    copy.buyTime                = self.buyTime;
    copy.brokerage              = self.brokerage;
    copy.cardFileID             = self.cardFileID;
    copy.needsSynced            = self.needsSynced;
    copy.cardProcessNeeded      = self.cardProcessNeeded;
    copy.listingID              = self.listingID;
    copy.file                   = self.file;
    copy.eventID                = self.eventID;
    copy.response_code_1        = self.response_code_1;
    copy.response_code_2        = self.response_code_2;
    copy.response_text_2        = self.response_text_2;
    copy.referralSourceMain     = self.referralSourceMain;
    copy.referralSourceOther    = self.referralSourceOther;
    
    return copy;
}

- (NSDictionary *)tableViewDictionary{
    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
    [dateFormat2 setDateFormat:@"M/d/yyyy"];
    NSString *visitedDateString = [dateFormat2 stringFromDate:self.date];
    
    NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
    
    //These fields are always displayed in the summary
    NSString *nameString;
    if (self.eventID){
        nameString = self.firstName ? [NSString stringWithFormat:@"%@ %@",self.firstName, self.lastName] : @"(Not Available)";
        
    }else{
        nameString = self.firstName ? [NSString stringWithFormat:@"%@ %@ (%@)",self.firstName, self.lastName, self.isBuyer ? @"Buyer" : @"Agent"] : [NSString stringWithFormat:@"(Not Available) (%@)", self.isBuyer ? @"Buyer" : @"Agent"];
    }
    
    output[@"0"] = @{
                     @"title": @"Name:  ",
                     @"value": nameString,
                     @"type": @"KeyValue",
                     };
    
    
    output[@"1"] = @{
                     @"title": @"Visited:",
                     @"value": visitedDateString,
                     @"type": @"KeyValue",
                     };
    
    output[@"2"] = @{
                     @"title": @"Email:  ",
                     @"value": self.email ? self.email : @"",
                     @"type": @"KeyValue",
                     };
    
    output[@"3"] = @{
                     @"title": @"Phone: ",
                     @"value": self.phone ? [SGFormatter formatPhoneNumber:self.phone deleteLastChar:NO] : @"",
                     @"type": @"KeyValue",
                     };
    
    NSInteger index = 4;
    
    if (self.buyTime){
        output[[NSString stringWithFormat:@"%@", @(index)]] = @{
                                                                @"title": @"How soon are you looking to buy?",
                                                                @"value": self.buyTime,
                                                                @"type": @"KeyValue",
                                                                };
        index++;
    }
    
    if (self.referralSourcePretty){
        output[[NSString stringWithFormat:@"%@", @(index)]] = @{
                                                                @"title": @"How did you hear about this listing?",
                                                                @"value": self.referralSourcePretty,
                                                                @"type": @"KeyValue",
                                                                };
        index++;
    }
    
    
    output[[NSString stringWithFormat:@"%@", @(index)]] = @{
                                                            @"title": @"Rating:",
                                                            @"value": [NSString stringWithFormat:@"%@", @(self.rating)],
                                                            @"type": @"Rating",
                                                            };
    index++;
    
    output[[NSString stringWithFormat:@"%@", @(index)]] = @{
                                                            @"title": @"Notes:",
                                                            @"value": self.notes ? self.notes : @"",
                                                            @"type": @"Notes",
                                                            };
    
    return [output copy];
}

- (NSDictionary *)serverData{
    NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
    
    output[@"attendee_type"] = self.isBuyer ? @"B" : @"A";
    output[@"email"] = self.email;
    output[@"first_name"] = self.firstName;
    output[@"last_name"] = self.lastName;
    output[@"phone"] = self.phone;
    
    if (self.listingID){
        output[@"property_id"] = self.listingID;
    }
    
    if (self.eventID){
        output[@"event_id"] = self.eventID;
    }
    
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"]; //2016-04-30T21:51:12+00:00
    output[@"mob_created_at"] = [df stringFromDate:[NSDate date]];
    
    RLMAgent *agent = [DGUserManager sharedInstance].currentAgent;
    output[@"ldapuser_id"] = agent.agentID; //Agent ID
    
    if (self.rating > 0){
        output[@"rating"] = [NSString stringWithFormat:@"%@", @(self.rating)];
    }
    
    if (self.notes){
        output[@"notes"] = self.notes;
    }
    
    if (self.attendeeID){
        output[@"id"] = self.attendeeID;
    }
    
    if (self.brokerage){
        output[@"brokerage"] = self.brokerage;
    }
    
    if (self.cardFileID){
        output[@"card_file_id"] = self.cardFileID;
    }
    
    output[@"sync_needed"] = self.needsSynced ? @"true" : @"false";
    
    if ([self buyTimeAnswer]){
        output[@"response_code_1"] = [self buyTimeAnswer];
    }
    
    if ([self referralSourceAnswer]){
        output[@"response_code_2"] = [self referralSourceAnswer];
    }
    
    if (self.referralSourceOther){
        output[@"response_text_2"] = self.referralSourceOther;
    }
    
    return [output copy];
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

- (NSString *)referralSourceAnswer{
    if (!self.referralSourceMain){
        return nil;
    }
    
    if ([self.referralSourceMain isEqualToString:@"Sign Outside"]){
        return @"SIGN";
        
    }else if ([self.referralSourceMain isEqualToString:@"Other"]){
        return @"OTHER";
        
    }else if ([self.referralSourceMain isEqualToString:@"Internet"]){
        return @"INTERNET";
        
    }else if ([self.referralSourceMain isEqualToString:@"Newspaper"]){
        return @"NEWSPAPER";
        
    }
    
    return nil;
}

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

- (RLMListing *)listing{
    RLMListing *listing = [[DGListingsManager sharedInstance] listingWithID:self.listingID];
    return listing;

}

@end