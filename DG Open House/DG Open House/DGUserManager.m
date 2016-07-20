//
//  DGUserManager.m
//  DG Open House
//
//  Created by Chase Acton on 2/10/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGUserManager.h"
#import "DGServer.h"
#import "DGKeychain+StoredData.h"
#import "SGConstants.h"
#import "NSUserDefaults+Convenience.h"
#import "AFNetworking.h"
#import "UIImage+DGImage.h"
#import "DGConstants.h"
#import "DGFileManager.h"

@implementation DGUserManager

+ (instancetype)sharedInstance {
    static DGUserManager *sharedMyInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyInstance = [[self alloc] init];
    });
    return sharedMyInstance;
}

- (id)init{
    self = [super init];
    if (self != nil){
        [self loadSavedAgent];
    }
    return self;
}

- (BOOL)signedIn{
    if (self.currentAgent){
        return YES;
    }
    
    return NO;
}

- (void)loadSavedAgent{
    RLMRealm *realmMainThread = [RLMRealm defaultRealm];
    RLMResults *agents = [RLMAgent allObjectsInRealm:realmMainThread];
    if (agents.count > 0){
        self.currentAgent = agents.firstObject;
    }
}

- (void)signInWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(BOOL success, NSError *error)) block{
    [DGServer signInWithEmail:email password:password completion:^(BOOL success, NSError *error, DGAgent *agent) {
        if (success){
            
            RLMRealm *realm = [RLMRealm defaultRealm];

            //Delete old agent objects
            [realm beginWriteTransaction];
            [realm deleteObjects:[RLMAgent allObjects]];
            [realm commitWriteTransaction];
            
            //Save agent object
            RLMAgent *rlmAgent = [[RLMAgent alloc] initWithJSONModel:agent];
            [realm beginWriteTransaction];
            [realm addObject:rlmAgent];
            [realm commitWriteTransaction];
            
            RLMResults *agents = [RLMAgent allObjectsInRealm:realm];
            self.currentAgent = agents.firstObject;
            
            [DGKeychain setToken:self.currentAgent.token];
            NSLog(@"Token: %@",[DGKeychain token]);
            NSString *agentID = self.currentAgent.agentID;
            
            if (![NSUserDefaults firstNameForAgent:agentID]){
                [NSUserDefaults setFirstName:self.currentAgent.firstName forAgent:agentID];
            }
            
            if (![NSUserDefaults lastNameForAgent:agentID]){
                [NSUserDefaults setLastName:self.currentAgent.lastName forAgent:agentID];
            }
            
            if (![NSUserDefaults phoneForAgent:agentID]){
                [NSUserDefaults setPhone:self.currentAgent.phone forAgent:agentID];
            }
            
//            [realm beginWriteTransaction];
//            self.currentAgent.firstName = @"Jane";
//            self.currentAgent.lastName = @"Agent";
//            self.currentAgent.fullName = @"Jane Agent";
//            self.currentAgent.phone = @"4150231234";
//            self.currentAgent.title = @"Real Estate Agent";
//            self.currentAgent.email = @"JaneAgent@DanielGale.com";
//
//            [realm commitWriteTransaction];
            
            //Download user image
         //   [DGServer downloadImage:[NSURL URLWithString:[DGBasePhotoURL stringByAppendingString:self.currentAgent.photoURL]] filename:DGImageKeyAgent completion:^(BOOL success, NSError *error) {
                block(success,error);
           // }];
            
        }else{
            block(success,error);
        }
    }];
}

- (void)signOut{
    
    //Clear Keychain
    [DGKeychain setUserEmail:nil];
    [DGKeychain setUserPassword:nil];
    
    self.currentAgent = nil;
    
    [DGFileManager clearFiles];
    
    //User defaults
    [NSUserDefaults setHasDownloadedAllData:NO];
    
    //Clear Realm
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
}

@end