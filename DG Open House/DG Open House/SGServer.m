//
//  SGServer.m
//  Safe Gale
//
//  Created by Chase Acton on 3/26/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "SGServer.h"
#import "SGConstants.h"
#import "SGURL.h"
#import "DGKeychain+StoredData.h"
#import "SGAlert.h"

static NSString * const PHAPIHeaderJSONContentType  = @"application/json";
static NSString * const PHAPIHeaderAccept           = @"Accept";
static NSString * const PHAPIHeaderContentType      = @"Content-Type";

static NSString * const SGServerHTTPMethodPOST      = @"POST";

static NSString * const DGAPIParamEmail         = @"ldapuser";
static NSString * const DGAPIParamPassword      = @"ldappassword";
static NSString * const DGAPIParamToken         = @"token";

@interface SGServer ()

@property (nonatomic) NSURLSession *sessionManager;

@end

@implementation SGServer

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static SGServer *sharedMyInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyInstance = [[self alloc] init];
    });
    return sharedMyInstance;
}

- (id)init{
    self = [super init];
    if (self != nil){
    }
    return self;
}

#pragma mark - SendPolice API

- (void)createAlert:(NSDictionary *)params callback:(void (^)(NSError *error, SGAlert *alert)) callback{
    NSString *urlString = [SGURL createAlert];
    
    NSLog(@"createAlert: %@", urlString);
    NSLog(@"Params: %@", params);
    
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = SGServerHTTPMethodPOST;
    request.HTTPBody = JSONData;
    [request setValue:PHAPIHeaderJSONContentType forHTTPHeaderField:PHAPIHeaderContentType];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                 completionHandler:^(NSData *data,
                                                                                     NSURLResponse *response,
                                                                                     NSError *error)
                                  {
                                      NSError *errorJson=nil;
                                      NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
                                      
                                      NSLog(@"responseDict=%@",responseDict);
                                      NSLog(@"Error: %@", error.localizedDescription);
                                      NSLog(@"errorJson: %@", errorJson.localizedDescription);

                                      if (!errorJson){
                                          
                                          NSError *alertError;
                                          SGAlert *alert = [[SGAlert alloc] initWithDictionary:responseDict error:&alertError];
                                          NSLog(@"alertError: %@", alertError.localizedDescription);

                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              callback(error, alert);
                                          });
                                          
                                      }else{
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              callback(error, nil);
                                          });
                                      }
                                  }];
    [task resume];
}

- (void)updateAlert:(NSString *)alertID params:(NSDictionary *)params callback:(void (^)(NSError *error, NSString *message)) callback{
    NSString *urlString = [SGURL updateAlert:alertID];
    
    NSLog(@"updateAlert: %@", urlString);
    NSLog(@"Params: %@", params);
    
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = SGServerHTTPMethodPOST;
    request.HTTPBody = JSONData;
    [request setValue:PHAPIHeaderJSONContentType forHTTPHeaderField:PHAPIHeaderContentType];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                 completionHandler:^(NSData *data,
                                                                                     NSURLResponse *response,
                                                                                     NSError *error)
                                  {
                                      NSString *messageString = nil;
                                      NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                                      
                                      if (strData){
                                          messageString = strData;
                                      }
                                      
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          callback(error, messageString);
                                      });
                                  }];
    [task resume];
}

- (void)cancelAlert:(NSString *)alertID callback:(void (^)(NSError *error, NSString *message)) callback{
    NSDictionary *params = @{SGAPIKeyStatus : SGAPIValueCancel};
    
    NSString *urlString = [SGURL cancelAlert:alertID];
    
    NSLog(@"cancelAlert: %@", urlString);
    
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = SGServerHTTPMethodPOST;
    request.HTTPBody = JSONData;
    [request setValue:PHAPIHeaderJSONContentType forHTTPHeaderField:PHAPIHeaderContentType];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                 completionHandler:^(NSData *data,
                                                                                     NSURLResponse *response,
                                                                                     NSError *error)
                                  {
                                      NSString *messageString = nil;
                                      NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                                      
                                      if (strData){
                                          messageString = strData;
                                      }
                                      
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          callback(error, messageString);
                                      });
                                  }];
    [task resume];
}

@end