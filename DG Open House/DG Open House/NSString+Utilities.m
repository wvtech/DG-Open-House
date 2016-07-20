//
//  NSString+Utilities.m
//  Propeller
//
//  Created by Chase Acton on 6/3/15.
//  Copyright (c) 2015 Chase Acton. All rights reserved.
//

#import "NSString+Utilities.h"

@implementation NSString (Utilities)

- (NSString *)trimWhitespace{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end