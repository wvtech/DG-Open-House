//
//  UIImage+DGImage.h
//  DG Open House
//
//  Created by Chase Acton on 5/9/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DGListing;

extern NSString * const DGImageKeyAgent;

@interface UIImage (DGImage)

+ (UIImage *)agentImage;
+ (UIImage *)imageForListing:(NSString *)mlsNumber atIndex:(NSInteger)index;
+ (NSString *)imageFilenameForListing:(NSString *)mlsNumber atIndex:(NSInteger)index;
+ (UIImage *)imageWithFilename:(NSString *)filename;

@end