//
//  DGFileManager.h
//  DG Open House
//
//  Created by Chase Acton on 5/12/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>

@interface DGFileManager : NSObject

+ (void)clearFiles;
+ (void)saveImage:(UIImage *)image withFilename:(NSString *)filename;

@end