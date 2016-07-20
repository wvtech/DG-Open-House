//
//  DGKeychain+StoredData.h
//  DG Open House
//
//  Created by Chase Acton on 2/1/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGKeychain+StoredData.h"

static NSString * const DGCredentialsEmail      = @"DGCredentialsEmailNew";
static NSString * const DGCredentialsPassword   = @"DGCredentialsPasswordNew";
static NSString * const DGToken                 = @"DGTokenNew";

@implementation DGKeychain (StoredData)

#pragma mark - User access

+ (void)setBackgroundValue:(NSString*)inValue orDeleteKey:(NSString*)inKey{
    if (inValue){
        [DGKeychain setString: inValue forBackgroundKey:inKey];
    }else if ([DGKeychain getStringForKey:inKey]){
        [DGKeychain deleteStringForKey: inKey];
    }
}

#pragma mark - User Info -

+ (NSString*)userEmail{
    return [DGKeychain getStringForKey: DGCredentialsEmail];
}

+ (void)setUserEmail:(NSString*)inUserEmail{
    [DGKeychain setBackgroundValue: inUserEmail orDeleteKey: DGCredentialsEmail];
}

+ (NSString*)userPassword{
    return [DGKeychain getStringForKey:DGCredentialsPassword];
}

+ (void)setUserPassword:(NSString*)inUserPassword{
    [DGKeychain setBackgroundValue:inUserPassword orDeleteKey:DGCredentialsPassword];
}

+ (NSString*)token{
    return [DGKeychain getStringForKey:DGToken];
}

+ (void)setToken:(NSString*)token{
    [DGKeychain setBackgroundValue:token orDeleteKey:DGToken];
}

@end