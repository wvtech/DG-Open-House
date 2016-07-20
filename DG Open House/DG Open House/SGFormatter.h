//
//  SGFormatter.h
//  Safe Gale
//
//  Created by Chase Acton on 3/27/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGFormatter : NSObject

+ (NSString *)formatPhoneNumber:(NSString *)simpleNumber deleteLastChar:(BOOL)deleteLastChar;

@end