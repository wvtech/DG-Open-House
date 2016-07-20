//
//  SGURL.h
//  Safe Gale
//
//  Created by Chase Acton on 3/27/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGURL : NSObject

+ (NSString *)signIn;
+ (NSString *)createAlert;
+ (NSString *)updateAlert:(NSString *)alertID;
+ (NSString *)cancelAlert:(NSString *)alertID;

@end