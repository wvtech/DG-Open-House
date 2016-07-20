//
//  RLMFile.h
//  DG Open House
//
//  Created by Chase Acton on 5/15/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <Realm/Realm.h>
#import "DGFile.h"

@interface RLMFile : RLMObject

- (id)initWithJSONModel:(DGFile *)file;

@property NSString *fileID;
@property NSString *type;
@property NSString *filename;
@property NSString *agentID;
@property NSString *mimetype;
@property NSDate *date;
@property BOOL uploaded;

- (NSDictionary *)serverData;

@end