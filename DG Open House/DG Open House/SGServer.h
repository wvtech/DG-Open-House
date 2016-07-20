//
//  SGServer.h
//  Safe Gale
//
//  Created by Chase Acton on 3/26/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DGAgent;
@class SGAlert;

@interface SGServer : NSObject

+ (instancetype)sharedInstance;

- (void)createAlert:(NSDictionary *)params callback:(void (^)(NSError *error, SGAlert *alert)) callback;
- (void)updateAlert:(NSString *)alertID params:(NSDictionary *)params callback:(void (^)(NSError *error, NSString *message)) callback;
- (void)cancelAlert:(NSString *)alertID callback:(void (^)(NSError *error, NSString *message)) callback;

@end