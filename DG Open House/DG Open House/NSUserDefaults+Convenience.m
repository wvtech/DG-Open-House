//
//  NSUserDefaults+Convenience.m
//  Asthmapolis
//
//  Created by David Hill on 8/24/13.
//  Copyright (c) 2013 Asthmapolis. All rights reserved.
//

#import "NSUserDefaults+Convenience.h"

NSString * const PROPSignedInBefore         = @"PROPSignedInBefore";
NSString * const PROPBuyTimeQuestion        = @"PROPBuyTimeQuestion";
NSString * const PROPReferralSourceQuestion = @"PROPReferralSourceQuestion";
NSString * const DGHasDownloadedAllData     = @"DGHasDownloadedAllData";
NSString * const DGShouldEnableSafeAgent    = @"DGShouldEnableSafeAgent";

@implementation NSUserDefaults (Convenience)

+ (void)registerUserDefaults{
    NSDictionary *defaults = @{
                               PROPSignedInBefore:          [NSNumber numberWithBool:NO],
                               PROPBuyTimeQuestion:         [NSNumber numberWithBool:YES],
                               PROPReferralSourceQuestion:  [NSNumber numberWithBool:YES],
                               DGShouldEnableSafeAgent:     [NSNumber numberWithBool:NO],
                               };
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

+ (BOOL)hasSignedInBefore{
    return [[NSUserDefaults standardUserDefaults] boolForKey:PROPSignedInBefore];
}

+ (void)setHasSignedInBefore:(BOOL)value{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:PROPSignedInBefore];
}

+ (BOOL)hasDownloadedAllData{
    return [[NSUserDefaults standardUserDefaults] boolForKey:DGHasDownloadedAllData];
}

+ (void)setHasDownloadedAllData:(BOOL)value{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:DGHasDownloadedAllData];
}

+ (BOOL)shouldEnableSafeAgent{
    return [[NSUserDefaults standardUserDefaults] boolForKey:DGShouldEnableSafeAgent];
}

+ (void)setShouldEnableSafeAgent:(BOOL)value{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:DGShouldEnableSafeAgent];
}

+ (BOOL)hasDownloadedImagesForListing:(NSString *)mls{
    return [[NSUserDefaults standardUserDefaults] boolForKey:[self imagesKeyForListing:mls]];
}

+ (void)setHasDownloadedImagesForListing:(NSString *)mls value:(BOOL)value{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:[self imagesKeyForListing:mls]];
}

+ (NSString *)imagesKeyForListing:(NSString *)mls{
    return [NSString stringWithFormat:@"images-%@",mls];
}

//How soon are you looking to buy?

+ (BOOL)shouldAskBuyTimeQuestion{
    return [[NSUserDefaults standardUserDefaults] boolForKey:PROPBuyTimeQuestion];
}

+ (void)setShouldAskBuyTimeQuestion:(BOOL)value{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:PROPBuyTimeQuestion];
}

//How did you hear about this listing?

+ (BOOL)shouldAskReferralSourceQuestion{
    return [[NSUserDefaults standardUserDefaults] boolForKey:PROPReferralSourceQuestion];
}

+ (void)setShouldAskReferralSourceQuestion:(BOOL)value{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:PROPReferralSourceQuestion];
}

//Agent

//First name
+ (NSString *)firstNameKeyForAgent:(NSString *)agentID{
    return [NSString stringWithFormat:@"first-%@",agentID];
}

+ (NSString *)firstNameForAgent:(NSString *)agentID{
    return [[NSUserDefaults standardUserDefaults] objectForKey:[self firstNameKeyForAgent:agentID]];
}

+ (void)setFirstName:(NSString *)name forAgent:(NSString *)agentID{
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:[self firstNameKeyForAgent:agentID]];
}

//Last name
+ (NSString *)lastNameKeyForAgent:(NSString *)agentID{
    return [NSString stringWithFormat:@"last-%@",agentID];
}

+ (NSString *)lastNameForAgent:(NSString *)agentID{
    return [[NSUserDefaults standardUserDefaults] objectForKey:[self lastNameKeyForAgent:agentID]];
}

+ (void)setLastName:(NSString *)name forAgent:(NSString *)agentID{
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:[self lastNameKeyForAgent:agentID]];
}

//Phone
+ (NSString *)phoneKeyForAgent:(NSString *)agentID{
    return [NSString stringWithFormat:@"phone-%@",agentID];
}

+ (NSString *)phoneForAgent:(NSString *)agentID{
    return [[NSUserDefaults standardUserDefaults] objectForKey:[self phoneKeyForAgent:agentID]];
}

+ (void)setPhone:(NSString *)phone forAgent:(NSString *)agentID{
    [[NSUserDefaults standardUserDefaults] setObject:phone forKey:[self phoneKeyForAgent:agentID]];
}

//PIN

+ (NSString *)pinKeyForAgent:(NSString *)agentID{
    return [NSString stringWithFormat:@"pin-%@",agentID];
}

+ (NSString *)pinForAgent:(NSString *)agentID{
    return [[NSUserDefaults standardUserDefaults] objectForKey:[self pinKeyForAgent:agentID]];
}

+ (void)setPin:(NSString *)pin forAgent:(NSString *)agentID{
    [[NSUserDefaults standardUserDefaults] setObject:pin forKey:[self pinKeyForAgent:agentID]];
}

@end
