//
//  DGServer.h
//  DG Open House
//
//  Created by Chase Acton on 2/1/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DGAgent.h"
#import "RLMFile.h"

@class RLMAttendee;

@interface DGServer : NSObject

+ (void)signInWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(BOOL success, NSError *error, DGAgent *agent)) block;
+ (void)getListings:(void (^)(BOOL success, NSError *error, NSArray *listings)) block;
+ (void)getListingAttendees:(void (^)(BOOL success, NSError *error, NSArray *attendees)) block;
+ (void)syncListingAttendee:(RLMAttendee *)attendee callback:(void (^)(BOOL success, NSError *error)) callback;
+ (void)syncEventAttendee:(RLMAttendee *)attendee callback:(void (^)(BOOL success, NSError *error)) callback;
+ (void)emailAttendees:(NSArray *)attendees date:(NSDate *)date start:(NSDate *)start end:(NSDate *)end callback:(void (^)(BOOL success, NSError *error)) callback;
+ (void)downloadFile:(DGFile *)file completion:(void (^)(BOOL success, NSError *error)) block;
+ (void)downloadImage:(NSURL *)url filename:(NSString *)filename completion:(void (^)(BOOL success, NSError *error)) block;
+ (void)uploadImage:(UIImage *)image uuid:(NSString *)uuid completion:(void (^)(BOOL success, NSError *error)) block;

+ (void)getFiles:(void (^)(BOOL success, NSError *error, NSArray *files)) block;
+ (void)uploadFile:(RLMFile *)file callback:(void (^)(BOOL success, NSError *error)) block;
+ (void)forgotPassword:(NSString *)email callback:(void (^)(BOOL success, NSError *error)) callback;

//Events
+ (void)getEvents:(void (^)(BOOL success, NSError *error, NSArray *events)) block;
+ (void)getEventAttendees:(void (^)(BOOL success, NSError *error, NSArray *attendees)) block;
+ (void)syncEvents:(NSArray *)events callback:(void (^)(BOOL success, NSError *error)) block;

@end