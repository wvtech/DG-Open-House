//
//  RLMAgent.m
//  DG Open House
//
//  Created by Chase Acton on 5/14/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "RLMAgent.h"

@implementation RLMAgent

- (id)initWithJSONModel:(DGAgent *)agent{
    self = [super init];
    if(!self) return nil;
    
    self.agentID        = agent.agentID;
    self.token          = agent.token;
    self.email          = agent.email;
    self.firstName      = agent.firstName;
    self.lastName       = agent.lastName;
    self.fullName       = agent.fullName;
    self.agentID        = agent.agentID;
    self.liborNumber    = agent.liborNumber;
    self.liborNumber2   = agent.liborNumber2;
    self.title          = agent.title;
    self.phone          = agent.phone;
    self.officePhone    = agent.officePhone;
    self.photoURL       = agent.photoURL;
    self.officeAddress  = agent.officeAddress;
    
    return self;
}

+ (NSString *)primaryKey {
    return @"agentID";
}

@end