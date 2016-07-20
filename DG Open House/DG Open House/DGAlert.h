//
//  DGAlert.h
//  DG Open House
//
//  Created by Chase Acton on 2/9/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DGAlert : NSObject

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message sender:(id)sender;
+ (void)errorWithMessage:(NSString *)message sender:(id)sender;

@end