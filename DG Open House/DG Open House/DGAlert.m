//
//  DGAlert.m
//  DG Open House
//
//  Created by Chase Acton on 2/9/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGAlert.h"
#import <UIKit/UIKit.h>

@implementation DGAlert

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message sender:(id)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertController *alert =   [UIAlertController
                                      alertControllerWithTitle:title
                                      message:message
                                      preferredStyle:UIAlertControllerStyleAlert];
                
        UIAlertAction *cancel = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"OK", nil)
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [alert addAction:cancel];
        
        [sender presentViewController:alert animated:YES completion:nil];
    });
}

+ (void)errorWithMessage:(NSString *)message sender:(id)sender{
    [self alertWithTitle:NSLocalizedString(@"Error", nil) message:message sender:sender];
}

@end