//
//  UIButton+BackgroundColor.m
//  Whyd
//
//  Created by Damien Romito on 22/01/15.
//  Copyright (c) 2015 Damien Romito. All rights reserved.
//

#import "UIButton+BackgroundColor.h"

@implementation UIButton (BackgroundColor)

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state{
    [self setBackgroundImage:[self imageWithColor:color] forState:state];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)makeDGButton{
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithRed:0.1725 green:0.4549 blue:0.7765 alpha:1.0].CGColor;
    
    [self setStates];
}

- (void)makeDGButtonWithIcon{
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithRed:0.1725 green:0.4549 blue:0.7765 alpha:1.0].CGColor;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.contentEdgeInsets = UIEdgeInsetsMake(0, 68, 0, 0);
    
    [self setStates];
}

- (void)setStates{
    //Highlighted state
    [self setBackgroundColor:[UIColor colorWithRed:0.1725 green:0.4549 blue:0.7765 alpha:1.0] forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    //Disabled state
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self setBackgroundColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
}

@end