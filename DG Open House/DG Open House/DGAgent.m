//
//  DGAgent.m
//  DG Open House
//
//  Created by Chase Acton on 2/1/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGAgent.h"

@implementation DGAgent

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"agentID",
                                                       @"login_token": @"token",
                                                       @"mail": @"email",
                                                       @"displayname" : @"fullName",
                                                       @"web_libornumber" : @"liborNumber",
                                                       @"web_libornumber2": @"liborNumber2",
                                                       @"web_jobtittle": @"title",
                                                       @"web_mobilephone": @"phone",
                                                       @"web_homephone": @"officePhone",
                                                       @"web_agentphotourl": @"photoURL",
                                                       @"web_address1": @"officeAddress",
                                                       @"web_firstname": @"firstName",
                                                       @"web_lastname": @"lastName",
                                                       }];
}

@end