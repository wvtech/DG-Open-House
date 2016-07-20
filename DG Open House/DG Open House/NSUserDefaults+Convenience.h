//
//  NSUserDefaults+Convenience.h
//  Asthmapolis
//
//  Created by David Hill on 8/24/13.
//  Copyright (c) 2013 Asthmapolis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Convenience)

+ (void)registerUserDefaults;

+ (BOOL)hasSignedInBefore;
+ (void)setHasSignedInBefore:(BOOL)value;

+ (BOOL)hasDownloadedAllData;
+ (void)setHasDownloadedAllData:(BOOL)value;

+ (BOOL)shouldEnableSafeAgent;
+ (void)setShouldEnableSafeAgent:(BOOL)value;

+ (BOOL)hasDownloadedImagesForListing:(NSString *)mls;
+ (void)setHasDownloadedImagesForListing:(NSString *)mls value:(BOOL)value;

//How soon are you looking to buy?

+ (BOOL)shouldAskBuyTimeQuestion;
+ (void)setShouldAskBuyTimeQuestion:(BOOL)value;

//How did you hear about this listing?

+ (BOOL)shouldAskReferralSourceQuestion;
+ (void)setShouldAskReferralSourceQuestion:(BOOL)value;

//Agent

//First name
+ (NSString *)firstNameForAgent:(NSString *)agentID;
+ (void)setFirstName:(NSString *)name forAgent:(NSString *)agentID;

//Last name
+ (NSString *)lastNameForAgent:(NSString *)agentID;
+ (void)setLastName:(NSString *)name forAgent:(NSString *)agentID;

//Phone
+ (NSString *)phoneForAgent:(NSString *)agentID;
+ (void)setPhone:(NSString *)phone forAgent:(NSString *)agentID;

//PIN
+ (NSString *)pinForAgent:(NSString *)agentID;
+ (void)setPin:(NSString *)pin forAgent:(NSString *)agentID;

@end