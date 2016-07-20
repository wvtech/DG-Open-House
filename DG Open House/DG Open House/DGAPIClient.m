//
//  DGAPIClient.m
//  DG Open House
//
//  Created by Chase Acton on 2/1/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGAPIClient.h"
#import "AFNetworking.h"
#import "DGConstants.h"
#import "DGAPIClient+ErrorHandling.h"
#import "DGUserManager.h"
#import "DGAPI.h"
#import "DGKeychain+StoredData.h"

static NSString * const DGAPIHeaderJSONContentType  = @"application/json";
static NSString * const DGAPIHeaderContentType      = @"Content-Type";
static NSString * const DGAPIHeaderAuthorization    = @"X-Authorization";

@implementation DGAPIClient

+ (AFHTTPRequestOperationManager *)operationManager{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [manager.requestSerializer setValue:DGAPIHeaderJSONContentType forHTTPHeaderField:DGAPIHeaderContentType];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", DGAPIHeaderJSONContentType, @"image/jpeg", nil];
    
    NSString *tokenRaw = [DGKeychain token];
    if (tokenRaw){
        NSString *token = [NSString stringWithFormat:@"Token %@",tokenRaw];
        [manager.requestSerializer setValue:token forHTTPHeaderField:DGAPIHeaderAuthorization];
    }
    
    AFSecurityPolicy *securityPolicy = manager.securityPolicy;
    securityPolicy.allowInvalidCertificates = YES;
    
    return manager;
}

+ (AFHTTPRequestOperationManager *)operationManagerImage{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [manager.requestSerializer setValue:DGAPIHeaderJSONContentType forHTTPHeaderField:DGAPIHeaderContentType];
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", DGAPIHeaderJSONContentType, @"image/jpeg", nil];
    
    NSString *tokenRaw = [DGKeychain token];
    if (tokenRaw){
        NSString *token = [NSString stringWithFormat:@"Token %@",tokenRaw];
        [manager.requestSerializer setValue:token forHTTPHeaderField:DGAPIHeaderAuthorization];
    }
    
    AFSecurityPolicy *securityPolicy = manager.securityPolicy;
    securityPolicy.allowInvalidCertificates = YES;
    
    return manager;
}

+ (void)POST:(NSURL *)url parameters:(id)parameters completion:(void (^)(BOOL success, NSError *error, id responseObject)) block{
    NSString *urlString = [NSString stringWithFormat:@"%@",url];
    
    DDLogInfo(@"POST: %@",urlString);
    
    if (parameters){
        
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

        DDLogVerbose(@"POST Params: %@", jsonString);
    }
    
    AFHTTPRequestOperationManager *manager = [self operationManager];
    
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        DDLogVerbose(@"Response: %@", responseObject);
        block(YES, nil, responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogVerbose(@"DGA Error: %@", error.description);
        
        NSString *errorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        DDLogVerbose(@"DGA Error: %@", errorResponse);
        
        if (operation.response.statusCode == 401  || operation.response.statusCode == 410){
            //Token no longer valid
            [DGKeychain setToken:nil];
        }
        
        block(NO, error, nil);
    }];
}

+ (void)GET:(NSURL *)url parameters:(NSDictionary *)parameters image:(BOOL)image completion:(void (^)(BOOL success, NSError *error, id responseObject)) block{
    NSString *urlString = [NSString stringWithFormat:@"%@",url];
  //  DDLogInfo(@"GET: %@",url);
    
    if (parameters){
        DDLogVerbose(@"GET Params: %@", parameters);
    }
    
    AFHTTPRequestOperationManager *manager;
    if (image){
        manager = [self operationManagerImage];
        

    }else{
        manager = [self operationManager];

    }
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:@"" append:NO];

        if (url != [DGAPI listingsURL]){
//            DDLogVerbose(@"Response: %@", responseObject);
        }
        block(YES, nil, responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogVerbose(@"Error: %@", error.description);
        
        if (operation.response.statusCode == 401  || operation.response.statusCode == 410){
            //Token no longer valid
            [DGKeychain setToken:nil];
        }
        
        block(NO, error, nil);
    }];
}

+ (void)POSTImage:(NSURL *)url image:(UIImage *)image uuid:(NSString *)uuid parameters:(id)parameters completion:(void (^)(BOOL success, NSError *error, id responseObject)) block{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);

    AFHTTPRequestOperationManager *manager = [self operationManagerImage];
    
    NSString *urlString = [NSString stringWithFormat:@"%@",url];
    NSString *filename = [NSString stringWithFormat:@"%@.jpg",uuid];
    
    [manager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:filename mimeType:@"image/jpeg"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"Success: %@", responseObject);
        block(YES, nil, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        DDLogVerbose(@"Error: %@", error.description);
        
        NSString *errorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        DDLogVerbose(@"Error: %@", errorResponse);
        
        if (operation.response.statusCode == 401  || operation.response.statusCode == 410){
            //Token no longer valid
            [DGKeychain setToken:nil];
        }
        
        block(NO, error, nil);
    }];
}

+ (void)downloadImage:(NSURL *)url filename:(NSString *)filename completion:(void (^)(BOOL success, NSError *error)) block{
  
    DDLogInfo(@"GET img Url : %@",url);
    
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    // find Documents directory and append your local filename
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    documentsURL = [documentsURL URLByAppendingPathComponent:filename];
   // NSLog(@"DGAPI Client filePath = %@", documentsURL);
    // and finally save the file
    [data writeToURL:documentsURL atomically:YES];
    
}

@end