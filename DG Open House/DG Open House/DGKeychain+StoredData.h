//
//  DGKeychain+StoredData.h
//  DG Open House
//
//  Created by Chase Acton on 2/1/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGKeychain.h"

@interface DGKeychain (StoredData)

//User Info
+ (NSString*)userEmail;
+ (void)setUserEmail:(NSString*)inUserEmail;

+ (NSString*)userPassword;
+ (void)setUserPassword:(NSString*)inUserPassword;

+ (NSString*)token;
+ (void)setToken:(NSString*)token;

@end