//
//  SGAlert.m
//  Safe Gale
//
//  Created by Chase Acton on 3/27/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "SGAlert.h"

static NSString * const alertIDKey = @"_id";

@implementation SGAlert

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       alertIDKey: @"alertID"
                                                       }];
}

@end