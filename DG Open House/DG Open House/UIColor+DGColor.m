//
//  UIColor+DGColor.m
//  DG Open House
//
//  Created by Chase Acton on 2/10/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "UIColor+DGColor.h"

@implementation UIColor (DGColor)

+ (UIColor *)menuBarBlue{
    return [UIColor colorWithRed:0.0/255.0 green:22.0/255.0 blue:27.0/255.0 alpha:1.0];
}

+ (UIColor *)topBarBlue{
    return [UIColor colorWithRed:0.0/255.0 green:35.0/255.0 blue:73.0/255.0 alpha:1.0];
}

+ (UIColor *)buttonBlue{
    return [UIColor colorWithRed:44.0/255.0 green:116.0/255.0 blue:198.0/255.0 alpha:1.0];
}

+ (UIColor *)greenStatusColor{
    return [UIColor colorWithRed:0.0/255.0 green:195.0/255.0 blue:0.0/255.0 alpha:1.0];
}

+ (UIColor *)redStatusColor{
    return [UIColor colorWithRed:195.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
}

@end