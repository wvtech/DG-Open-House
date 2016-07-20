//
//  DGFileManager.m
//  DG Open House
//
//  Created by Chase Acton on 5/12/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGFileManager.h"
#import "DGConstants.h"

@implementation DGFileManager

+ (void)clearFiles{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(useCacheDirectory ? NSCachesDirectory : NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:filePath error:nil];
    
    for(NSString *filename in files){
        NSError *deleteError;
        [[NSFileManager defaultManager] removeItemAtPath:filename error:&deleteError];        
    }
}

+ (void)saveImage:(UIImage *)image withFilename:(NSString *)filename{
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(useCacheDirectory ? NSCachesDirectory : NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    
    // Save image.
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
    
    NSError *error = nil;
    BOOL success = [[NSURL fileURLWithPath:filePath] setResourceValue:[NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [[NSURL URLWithString:filePath] lastPathComponent], error);
    }
}

@end