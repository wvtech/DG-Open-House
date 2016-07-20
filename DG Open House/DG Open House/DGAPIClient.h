//
//  DGAPIClient.h
//  DG Open House
//
//  Created by Chase Acton on 2/1/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DGAPIClient : NSObject

+ (void)POST:(NSURL *)url parameters:(id)parameters completion:(void (^)(BOOL success, NSError *error, id responseObject)) block;
+ (void)GET:(NSURL *)url parameters:(NSDictionary *)parameters image:(BOOL)image completion:(void (^)(BOOL success, NSError *error, id responseObject)) block;
+ (void)POSTImage:(NSURL *)url image:(UIImage *)image uuid:(NSString *)uuid parameters:(id)parameters completion:(void (^)(BOOL success, NSError *error, id responseObject)) block;
+ (void)downloadImage:(NSURL *)url filename:(NSString *)filename completion:(void (^)(BOOL success, NSError *error)) block;

@end