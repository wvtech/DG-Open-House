//
//  CAUpdateChecker.h
//  Elli
//
//  Created by Chase Acton on 3/14/16.
//  Copyright © 2016 Amnesiapps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAUpdateChecker : NSObject

+ (void)checkForUpdate;
+ (void)checkForSafeAgent;

@end