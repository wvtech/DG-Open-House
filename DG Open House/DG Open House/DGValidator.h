//
//  DGValidator.h
//  DG Open House
//
//  Created by Chase Acton on 2/10/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DGValidator : NSObject

/** Returns 'True' if email address is valid */
+ (BOOL)validateEmail:(NSString *)input;

@end