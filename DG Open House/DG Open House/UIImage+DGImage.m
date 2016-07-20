//
//  UIImage+DGImage.m
//  DG Open House
//
//  Created by Chase Acton on 5/9/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "UIImage+DGImage.h"
#import "DGListing.h"
#import "DGConstants.h"

NSString * const DGImageKeyAgent = @"AgentImage";

@implementation UIImage (DGImage)

+ (UIImage *)agentImage{
    return [self imageWithFilename:DGImageKeyAgent];
}

+ (UIImage *)imageForListing:(NSString *)mlsNumber atIndex:(NSInteger)index{
    NSString *filename = [NSString stringWithFormat:@"dgPhotos/dgfoto/%@_%@.jpg",mlsNumber, @(index)];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(useCacheDirectory ? NSCachesDirectory : NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"filePath = %@", filePath);
    if ([fileManager fileExistsAtPath:filePath]){
        return [UIImage imageWithContentsOfFile:filePath];
    }
    
    return nil;
}

+ (NSString *)imageFilenameForListing:(NSString *)mlsNumber atIndex:(NSInteger)index{
    NSString *filename = [NSString stringWithFormat:@"dgPhotos/dgfoto/%@_%@.jpg",mlsNumber, @(index)];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(useCacheDirectory ? NSCachesDirectory : NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filePath]){        
        return filename;
    }
    
    return nil;
}

#pragma mark - Utility

+ (UIImage *)imageWithFilename:(NSString *)filename{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(useCacheDirectory ? NSCachesDirectory : NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filePath]){
        return [UIImage imageWithContentsOfFile:filePath];
    }
    
    return nil;
}

@end