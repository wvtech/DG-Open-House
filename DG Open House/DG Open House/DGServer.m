//
//  DGServer.m
//  DG Open House
//
//  Created by Chase Acton on 2/1/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGServer.h"
#import "DGAPIClient.h"
#import "DGAPI.h"
#import "DGUserManager.h"
#import "DGListing.h"
#import "DGKeychain+StoredData.h"

#import <UIKit/UIKit.h>
#import "DGEvent.h"
#import "RLMAttendee.h"
#import "RLMEvent.h"
#import "DGConstants.h"

static NSString * const DGAPIParamEmail         = @"ldapuser";
static NSString * const DGAPIParamPassword      = @"ldappassword";
static NSString * const DGAPIParamToken         = @"token";

@implementation DGServer

+ (void)signInWithEmail:(NSString *)email password:(NSString *)password completion:(void (^)(BOOL success, NSError *error, DGAgent *agent)) block{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[DGAPIParamEmail] = email;
    params[DGAPIParamPassword] = password;
    
    [DGAPIClient POST:[DGAPI signInURL] parameters:params completion:^(BOOL success, NSError *error, id responseObject){
        if (success){
            NSError *userError;
            DGAgent *user = [[DGAgent alloc] initWithDictionary:responseObject error:&userError];
            if (!userError){
                [DGKeychain setUserEmail:email];
                [DGKeychain setUserPassword:password];
            }else{
                NSLog(@"Error creating DGAgent object");
            }
            block(success, error, user);
        }else{
            block(success, error, nil);
        }
    }];
}

+ (void)getListings:(void (^)(BOOL success, NSError *error, NSArray *listings)) block{
    [DGAPIClient GET:[DGAPI listingsURL] parameters:nil image:NO completion:^(BOOL success, NSError *error, id responseObject){
        if (success){
            NSMutableArray *listingsArray = [[NSMutableArray alloc] init];
            
            for (NSDictionary *listingDict in responseObject){
                NSError *listingError;
                DGListing *listing = [[DGListing alloc] initWithDictionary:listingDict error:&listingError];
                listing.attendees = [[NSMutableArray alloc] init];

                if (!listingError){
                    [listingsArray addObject:listing];
                }else{
                    NSLog(@"Error creating DGListing object");
                }
            }
            
           // if(KAppDelegate.flagIsLoginFirstTime) {
            
           /*
            if(listingsArray.count < 1000) {
                
                KAppDelegate.arrAlter = [[NSMutableArray alloc] init];
                KAppDelegate.arrAlter = listingsArray;
            } else if(listingsArray.count >= 1000){
                if(KAppDelegate.intPhaseNo == 1) { ///During login time
                    KAppDelegate.arrAlter = [[NSMutableArray alloc] init];
                    for (int i = 0; i< 1000; i++) {    //// Copying array into alter
                        [KAppDelegate.arrAlter addObject:listingsArray[i]];
                    }
                    
                    for (int i = 0; i< 1000; i++) { //// removing that arrdata and copied rest into a global array
                        [listingsArray removeObjectAtIndex:i];
                    }
                    
                    NSLog(@"listingsArray After = %d", (int)listingsArray.count);
                    
                    KAppDelegate.arrListingData = listingsArray;
                    
                    KAppDelegate.intPhaseNo ++;
                } else if(KAppDelegate.intPhaseNo == 2) { /// After login
                    
                    int intCounterValue = KAppDelegate.arrListingData.count/3;
//KAppDelegate.arrAlter = [[NSMutableArray alloc] init];
                    for (int i = 0; i < intCounterValue; i++) {
                        [KAppDelegate.arrAlter addObject:KAppDelegate.arrListingData[i]];
                    }
                    
                    for (int j = 0; j < intCounterValue; j++) {
                        [KAppDelegate.arrListingData removeObjectAtIndex:j];
                    }
                    
                    NSMutableArray * arrRestData = [[NSMutableArray alloc] init];
                    arrRestData = KAppDelegate.arrListingData;
                    
                    if(KAppDelegate.arrListingData.count > 0) {
                        [KAppDelegate.arrListingData removeAllObjects];
                        
                    }
                    KAppDelegate.arrListingData = arrRestData;
                    KAppDelegate.intPhaseNo++;
                } else if (KAppDelegate.intPhaseNo == 3) {
                    for (int i = 0; i < KAppDelegate.arrListingData.count; i++) {
                        [KAppDelegate.arrAlter addObject:KAppDelegate.arrListingData[i]];
                    }
                    KAppDelegate.intPhaseNo++;
                } else {
                    if(KAppDelegate.arrAlter.count > 0) {
                        [KAppDelegate.arrAlter removeAllObjects];
                    }
                    KAppDelegate.arrAlter = listingsArray;
                }
            }
                block(success, error, [KAppDelegate.arrAlter copy]);
         //  } else { */
          //    block(success, error, [listingsArray copy]);
           // }
            block(success, error, [listingsArray copy]);
            NSLog(@"listingsArray counts = %d", (int)listingsArray.count);
            NSLog(@"KAppDelegate.arrAlter counts = %d", (int) KAppDelegate.arrAlter.count);
            
        }else{
            block(success, error, nil);
        }
    }];
}

+ (void)getListingAttendees:(void (^)(BOOL success, NSError *error, NSArray *attendees)) block{
    [DGAPIClient POST:[DGAPI listingAttendeesURL] parameters:nil completion:^(BOOL success, NSError *error, id responseObject){
        if (success){
            NSMutableArray *attendeesArray = [[NSMutableArray alloc] init];
            
            for (NSDictionary *attendeeDict in [responseObject objectForKey:@"data"]){
                NSError *listingError;
                DGAttendee *attendee = [[DGAttendee alloc] initWithDictionary:attendeeDict error:&listingError];
                if (!listingError){
                    [attendeesArray addObject:attendee];
                }else{
                    NSLog(@"Error creating DGAttendee object: %@", listingError);
                }
            }
            block(success, error, [attendeesArray copy]);
        }else{
            block(success, error, nil);
        }
    }];
}

+ (void)getFiles:(void (^)(BOOL success, NSError *error, NSArray *files)) block{
    [DGAPIClient POST:[DGAPI filesURL] parameters:nil completion:^(BOOL success, NSError *error, id responseObject){
        if (success){
            NSMutableArray *filesArray = [[NSMutableArray alloc] init];
            
            for (NSDictionary *fileDict in [responseObject objectForKey:@"data"]){
                NSError *listingError;
                DGFile *attendee = [[DGFile alloc] initWithDictionary:fileDict error:&listingError];
                if (!listingError){
                    [filesArray addObject:attendee];
                }else{
                    NSLog(@"Error creating DGFile object: %@", listingError);
                }
            }
            
            dispatch_group_t group = dispatch_group_create();
            
            
            for (DGFile *file in filesArray){
                dispatch_group_enter(group);
                if (file.uploaded){
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(useCacheDirectory ? NSCachesDirectory : NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:file.filename];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    
                    if (![fileManager fileExistsAtPath:filePath]){
                        [self downloadFile:file completion:^(BOOL success, NSError *error) {
                            dispatch_group_leave(group); //Leave group when request completes
                        }];
                        
                    }else{
                        dispatch_group_leave(group); //Leave group when request completes
                    }
                    
                }else{
                    dispatch_group_leave(group); //Leave group when request completes
                }
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                block(success, error, [filesArray copy]);
            });
            
        }else{
            block(success, error, nil);
        }
    }];
}

+ (void)downloadFile:(DGFile *)file completion:(void (^)(BOOL success, NSError *error)) block{
    [DGAPIClient GET:[DGAPI downloadURLForFile:file] parameters:nil image:YES completion:^(BOOL success, NSError *error, id responseObject){
        if (success){
            // Create path.
            NSArray *paths = NSSearchPathForDirectoriesInDomains(useCacheDirectory ? NSCachesDirectory : NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:file.filename];
            
            // Save image.
            UIImage *image = (UIImage *)responseObject;
            
            [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
            
            NSError *error = nil;
            BOOL success = [[NSURL fileURLWithPath:filePath] setResourceValue:[NSNumber numberWithBool: YES]
                                                                     forKey: NSURLIsExcludedFromBackupKey error: &error];
            if(!success){
                NSLog(@"Error excluding %@ from backup %@", [[NSURL URLWithString:filePath] lastPathComponent], error);
            }
            
            block(success, error);
        }else{
            block(success, error);
        }
    }];
}

+ (void)downloadImage:(NSURL *)url filename:(NSString *)filename completion:(void (^)(BOOL success, NSError *error)) block{
  //  NSLog(@"downloadImage: %@", [url absoluteString]);
    @try {
        [DGAPIClient downloadImage:url filename:filename completion:^(BOOL success, NSError *error) {
            block(success, error);
        }];
    } @catch (NSException *exception) {
        NSLog(@"catching %@ reason %@", [exception name], [exception reason]);
    } @finally {
    }
}

+ (void)syncListingAttendee:(RLMAttendee *)attendee callback:(void (^)(BOOL success, NSError *error)) callback{
    [DGAPIClient POST:[DGAPI listingAttendeesURL] parameters:@[[attendee serverData]] completion:^(BOOL success, NSError *error, id responseObject){
        callback(success, error);
    }];
}

+ (void)syncEventAttendee:(RLMAttendee *)attendee callback:(void (^)(BOOL success, NSError *error)) callback{
    [DGAPIClient POST:[DGAPI eventAttendeesURL] parameters:@[[attendee serverData]] completion:^(BOOL success, NSError *error, id responseObject){
        callback(success, error);
    }];
}

+ (void)emailAttendees:(NSArray *)attendees date:(NSDate *)date start:(NSDate *)start end:(NSDate *)end callback:(void (^)(BOOL success, NSError *error)) callback{
    NSMutableArray *attendeeIDs = [[NSMutableArray alloc] init];
    
    //Build array of attendee IDs. Exclude any attendees that don't have IDs
    for (RLMAttendee *attendee in attendees){
        if (attendee.attendeeID.length > 0){
            [attendeeIDs addObject:attendee.attendeeID];
        }
    }
    
    if ([attendeeIDs count] == 0){
        NSLog(@"No attendees to promote");
        callback(NO, nil);
        return;
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm"];
    
    NSDictionary *params = @{
                             @"attendees":[attendeeIDs copy],
                             @"oh_date": [dateFormat stringFromDate:date],
                             @"oh_start_time": [timeFormat stringFromDate:start],
                             @"oh_end_time": [timeFormat stringFromDate:end]
                             };
    
    [DGAPIClient POST:[DGAPI promoteURL] parameters:params completion:^(BOOL success, NSError *error, id responseObject) {
        callback(success, error);
    }];
}

+ (void)uploadImage:(UIImage *)image uuid:(NSString *)uuid completion:(void (^)(BOOL success, NSError *error)) block{
    [DGAPIClient POSTImage:[DGAPI uploadURLForFileUUID:uuid] image:image uuid:uuid parameters:nil completion:^(BOOL success, NSError *error, id responseObject) {
        block(success, error);
    }];
}

+ (void)uploadFile:(RLMFile *)file callback:(void (^)(BOOL success, NSError *error)) block{
    [DGAPIClient POST:[DGAPI filesURL] parameters:@[[file serverData]] completion:^(BOOL success, NSError *error, id responseObject) {
        block(success, error);
    }];
}

#pragma mark - Events

+ (void)getEvents:(void (^)(BOOL success, NSError *error, NSArray *events)) block{
    [DGAPIClient POST:[DGAPI eventsURL] parameters:nil completion:^(BOOL success, NSError *error, id responseObject){
        if (success){
            NSMutableArray *eventsArray = [[NSMutableArray alloc] init];
            
            for (NSDictionary *listingDict in [responseObject objectForKey:@"data"]){
                NSError *eventError;
                DGEvent *event = [[DGEvent alloc] initWithDictionary:listingDict error:&eventError];
//                event.attendees = [[NSMutableArray alloc] init];
                event.images = [[NSMutableArray alloc] init];
                 
                if (!eventError){
                    [eventsArray addObject:event];
                }else{
                    NSLog(@"Error creating DGEvent object");
                }
            }
            block(success, error, [eventsArray copy]);
        }else{
            block(success, error, nil);
        }
    }];
}

+ (void)syncEvents:(NSArray *)events callback:(void (^)(BOOL success, NSError *error)) block{
    //Convert into JSON array
    NSMutableArray *params = [[NSMutableArray alloc] init];
    for (RLMEvent *event in events){
        [params addObject:[event serverData]];
    }
    
    [DGAPIClient POST:[DGAPI eventsURL] parameters:params completion:^(BOOL success, NSError *error, id responseObject){
        if (success){
            NSLog(@"Sync events success");
        }
        block(success, error);
    }];
}

+ (void)getEventAttendees:(void (^)(BOOL success, NSError *error, NSArray *attendees)) block{
    [DGAPIClient POST:[DGAPI eventAttendeesURL] parameters:nil completion:^(BOOL success, NSError *error, id responseObject){
        if (success){
            NSMutableArray *attendeesArray = [[NSMutableArray alloc] init];
            
            for (NSDictionary *attendeeDict in [responseObject objectForKey:@"data"]){
                NSError *listingError;
                DGAttendee *attendee = [[DGAttendee alloc] initWithDictionary:attendeeDict error:&listingError];
                if (!listingError){
                    [attendeesArray addObject:attendee];
                }else{
                    NSLog(@"Error creating DGAttendee object: %@", listingError);
                }
            }
            block(success, error, [attendeesArray copy]);
        }else{
            block(success, error, nil);
        }
    }];
}

+ (void)forgotPassword:(NSString *)email callback:(void (^)(BOOL success, NSError *error)) callback{
    [DGAPIClient POST:[DGAPI forgotPasswordURL] parameters:@{@"ldapuser": email} completion:^(BOOL success, NSError *error, id responseObject){
        callback(success, error);
    }];
}

@end