//
//  DGAPIClient+ErrorHandling.h
//  DG Open House
//
//  Created by Chase Acton on 2/1/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGAPIClient+ErrorHandling.h"
#import "DGServer.h"
#import "DGAPIClient.h"
#import "AFNetworking.h"

@interface DGAPIClient (ErrorHandling)

+ (void)handleError:(NSError *)error forOperation:(AFHTTPRequestOperation *)operation completion:(void (^)(BOOL success, NSError *error, id responseObject, BOOL shouldRetry)) block;

@end