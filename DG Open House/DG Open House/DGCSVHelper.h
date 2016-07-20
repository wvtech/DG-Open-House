//
//  DGCSVHelper.h
//  DG Open House
//
//  Created by Chase Acton on 5/2/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DGCSVHelper : NSObject

+ (NSData *)csvFromAttendees:(NSArray *)attendees;
+ (NSData *)eventCsvFromAttendees:(NSArray *)attendees;

@end