//
//  RLMAgent.h
//  DG Open House
//
//  Created by Chase Acton on 5/14/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <Realm/Realm.h>
#import "DGAgent.h"

@interface RLMAgent : RLMObject

@property NSString *agentID;
@property NSString *token;
@property NSString *email;
@property NSString *firstName;
@property NSString *lastName;
@property NSString *fullName;
@property NSString *liborNumber;
@property NSString *liborNumber2;
@property NSString *title;
@property NSString *phone;
@property NSString *officePhone;
@property NSString *photoURL;
@property NSString *officeAddress;

- (id)initWithJSONModel:(DGAgent *)agent;

@end