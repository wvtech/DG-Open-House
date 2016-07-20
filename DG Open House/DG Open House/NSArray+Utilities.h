//
//  NSArray+Utilities.h
//  Propeller
//
//  Created by Chase Acton on 7/1/15.
//  Copyright © 2015 Chase Acton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Utilities)

- (NSUInteger)indexOfCaseInsensitiveString:(NSString *)string;
- (NSString *)humanReadableListFromArrayWithOxfordStyle:(BOOL)oxford;
- (NSArray *)sortedByKey:(NSString *)key ascending:(BOOL)ascending;
- (NSString *)localizedComponentsJoinedByString:(NSString *)separator;

@end