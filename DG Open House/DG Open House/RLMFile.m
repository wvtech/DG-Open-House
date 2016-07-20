//
//  RLMFile.m
//  DG Open House
//
//  Created by Chase Acton on 5/15/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "RLMFile.h"

@implementation RLMFile

- (id)initWithJSONModel:(DGFile *)file{
    self = [super init];
    if(!self) return nil;
    
    self.fileID     = file.fileID;
    self.type       = file.type;
    self.filename   = file.filename;
    self.agentID    = file.agentID;
    self.mimetype   = file.mimetype;
    self.date       = file.date;
    self.uploaded   = file.uploaded;
    
    return self;
}

- (NSDictionary *)serverData{
    NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
    
    output[@"id"] = self.fileID;
    output[@"user_file_type"] = self.type;
    output[@"ldapuser_id"] = self.agentID;
    output[@"filename"] = self.filename;
    output[@"mimetype"] = self.mimetype;
    
    //Date
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"]; //2016-04-30T21:51:12+00:00
    output[@"mob_created_at"] = [df stringFromDate:[NSDate date]];
    
    return [output copy];
}

@end