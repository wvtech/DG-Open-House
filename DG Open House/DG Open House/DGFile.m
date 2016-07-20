//
//  DGFile.m
//  DG Open House
//
//  Created by Chase Acton on 5/4/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGFile.h"

NSString * const DGFileTypeListing   = @"PROPATT_CARD";
NSString * const DGFileTypeEvent     = @"EVATT_CARD";

@implementation DGFile

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"fileID",
                                                       @"user_file_type": @"type",
                                                       @"ldapuser_id" : @"agentID",
                                                       }];
}

@end