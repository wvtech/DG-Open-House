//
//  DGKeychain.m
//  DG Open House
//
//  Created by Chase Acton on 2/1/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGKeychain.h"
#import "DGConstants.h"

@import Security;

@implementation DGKeychain

+ (void)save:(NSString *)inputString forKey:(NSString *)account withAccessLevel:(id)inAccessLevel
{
    if ( !inputString )
    {
        DDLogError(@"Keychain: nil input string for key: %@", account );
        return;
    }
    
    if ( !account )
    {
        DDLogError( @"Keychain: nil account for input string: %@", inputString );
        return;
    }
    
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    [query setObject:account forKey:(__bridge id)kSecAttrAccount];
    
    [query setObject:inAccessLevel forKey:(__bridge id)kSecAttrAccessible];
    
    OSStatus error = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
//    DDLogError(@"SecItemCopyMatching Result: %@",@(error));
    
	if (error == errSecSuccess)
    {
        NSDictionary *attributesToUpdate = @{
                                             (__bridge id)kSecValueData:        [inputString dataUsingEncoding:NSUTF8StringEncoding],
                                             (__bridge id)kSecAttrAccessible:   inAccessLevel
                                             };
        
		error = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributesToUpdate);
        if ( error != errSecSuccess )
        {
            DDLogError( @"Keychain: error %@ updating existing string %@ for key: %@", @(error), inputString, account );
        }
    }
    else if (error == errSecItemNotFound)
    {
        if ([inputString isKindOfClass:[NSNull class]])
        {
            DDLogError(@"Error - Trying to insert null value for keychain key: %@", account);
        }
        else
        {
            [query setObject:[inputString dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
            [query setObject:inAccessLevel forKey:(__bridge id)kSecAttrAccessible];

            error = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
            if ( error != errSecSuccess )
            {
                DDLogError( @"Keychain: error %@ adding new string %@ for key: %@", @(error), inputString, account );
            }
        }
    }
}

+ (void)save:(NSString *)inputString forKey:(NSString *)account
{
    [DGKeychain save: inputString forKey: account withAccessLevel: (__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly];
}

+ (NSString *)getStringForKey:(NSString *)account
{
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    
    [query setObject:(__bridge id)kSecClassGenericPassword
              forKey:(__bridge id)kSecClass];
    
    [query setObject:account
              forKey:(__bridge id)kSecAttrAccount];
    
    [query setObject:(__bridge id)kCFBooleanTrue
              forKey:(__bridge id)kSecReturnData];
    
    CFDataRef attributes = NULL;
	OSStatus  error = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&attributes);
//    DDLogError(@"SecItemCopyMatching Result: %@",@(error));

	NSData *dataFromKeychain = (__bridge_transfer NSData *) attributes;
    
    NSString *credential = nil;
    
    if (error == errSecSuccess)
    {
        credential = [[NSString alloc] initWithData:dataFromKeychain encoding:NSUTF8StringEncoding];
    }
    else if ( error != errSecItemNotFound )
    {
        DDLogError( @"Keychain: error %@ retrieving string for key: %@", @(error), account );
    }
    else
    {
        DDLogError( @"Keychain: could not find key: %@", account );
    }
    
    return credential;
}


+ (void)deleteStringForKey:(NSString *)account
{
    NSAssert(account != nil, @"Invalid account");
    
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [query setObject:account forKey:(__bridge id)kSecAttrAccount];
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (status != errSecSuccess)
    {
        DDLogError( @"Keychain: error %@ deleting key: %@", @(status), account );
    }
}


+ (void)setString:(NSString*)inString forBackgroundKey:(NSString*)inKey
{
    [DGKeychain save: inString forKey: inKey withAccessLevel:(__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly];
}

@end