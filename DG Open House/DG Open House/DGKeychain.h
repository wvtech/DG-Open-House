//
//  DGKeychain.h
//  DG Open House
//
//  Created by Chase Acton on 2/1/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DGKeychain : NSObject

+ (void)save:(NSString *)inputString forKey:(NSString *)account;

+ (NSString *)getStringForKey:(NSString *)account;

+ (void)deleteStringForKey:(NSString *)account;

//  store keys such that they are available in the background (slightly more security risk!)
+ (void)setString:(NSString*)inString forBackgroundKey:(NSString*)inKey;

@end