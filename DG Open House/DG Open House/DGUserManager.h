//
//  DGUserManager.h
//  DG Open House
//
//  Created by Chase Acton on 2/10/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLMAgent.h"

@interface DGUserManager : NSObject

@property (nonatomic) RLMAgent *currentAgent;
@property (nonatomic, readonly) BOOL signedIn;

+ (instancetype)sharedInstance;
- (void)signInWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(BOOL success, NSError *error)) block;
- (void)signOut;

@end