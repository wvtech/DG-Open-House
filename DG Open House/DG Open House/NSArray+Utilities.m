//
//  NSArray+Utilities.m
//  Propeller
//
//  Created by Chase Acton on 7/1/15.
//  Copyright © 2015 Chase Acton. All rights reserved.
//

#import "NSArray+Utilities.h"

@implementation NSArray (Utilities)

- (NSUInteger)indexOfCaseInsensitiveString:(NSString *)string{
    NSUInteger index = 0;
    for (NSString *object in self) {
        if ([object caseInsensitiveCompare:string] == NSOrderedSame) {
            return index;
        }
        index++;
    }
    return NSNotFound;
}

- (NSString *)humanReadableListFromArrayWithOxfordStyle:(BOOL)oxford{
    if ([self count] == 0) return @"";
    if ([self count] == 1) return self[0];
    if ([self count] == 2) return [self componentsJoinedByString:@" and "];
    
    NSArray *firstItems = [self subarrayWithRange:NSMakeRange(0, [self count]-1)];
    NSString *lastItem = [self lastObject];
    
    NSString *lastDelimiter = (oxford)?
    [NSString stringWithFormat:@", %@ ",NSLocalizedString(@"and", nil)] :
    [NSString stringWithFormat:@" %@ ",NSLocalizedString(@"and", nil)];
    
    return [NSString stringWithFormat:@"%@%@%@",
            [firstItems componentsJoinedByString:@", "], lastDelimiter, lastItem];
}

- (NSArray *)sortedByKey:(NSString *)key ascending:(BOOL)ascending{
    NSMutableArray *mutableArray = [self mutableCopy];
    NSSortDescriptor *sortByKey = [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending];
    [mutableArray sortUsingDescriptors:[NSArray arrayWithObject:sortByKey]];
    return [mutableArray copy];
}

- (NSString *)localizedComponentsJoinedByString:(NSString *)separator{
    //Create a localized string of localized array components for presentation purpose only.
    //The underlying array is what will actually be sent to the server.
    NSMutableArray *localizedArray = [[NSMutableArray alloc] init];    
    for (NSString *string in self){
        [localizedArray addObject:NSLocalizedString(string, nil)];
    }
    return [localizedArray componentsJoinedByString:separator];
}

@end