//
//  SGURL.m
//  Safe Gale
//
//  Created by Chase Acton on 3/27/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "SGURL.h"
#import "SGConstants.h"

//API Paths
static NSString * const SGURLPathV1             = @"v1";
static NSString * const SGURLPathAlerts         = @"alerts";
static NSString * const SGURLPathLocations      = @"locations";
static NSString * const SGURLPathStatuses       = @"statuses";

//API Query Keys
static NSString * const SGURLQueryKeyUserKey    = @"user_key";

@implementation SGURL

#pragma mark - Helpers

+ (NSString *)pathWithComponents:(NSArray *)components{
    NSString *path = @"";
    
    for (NSString *component in components){
        path = [path stringByAppendingPathComponent:component];
    }
    
    return path;
}

+ (NSString *)queryStringForKey:(NSString *)key value:(NSString *)value{
    NSURLComponents *components = [[NSURLComponents alloc] init];
    NSURLQueryItem *item = [[NSURLQueryItem alloc] initWithName:key value:value];
    [components setQueryItems:@[item]];
    return components.string;
}

+ (NSString *)baseURL{
    if (SGAPISandbox){
        return @"https://sandbox.sendpolice.com/";
    } else{
        return @"https://api.sendpolice.com/";
    }
}

#pragma mark - Endpoints

+ (NSString *)signIn{
    return @"http://danielgale.ecaptureinc.com/openhouse/rest/session/login/";
}

+ (NSString *)createAlert{
    NSString *queryString = [self queryStringForKey:SGURLQueryKeyUserKey value:SGAPIClientKey];
    NSString *path = [self pathWithComponents:@[SGURLPathV1, SGURLPathAlerts, queryString]];
    
    return [NSString stringWithFormat:@"%@%@", [SGURL baseURL], path];
}

+ (NSString *)updateAlert:(NSString *)alertID{
    if (!alertID){
        return nil;
    }
    
    NSString *queryString = [self queryStringForKey:SGURLQueryKeyUserKey value:SGAPIClientKey];
    NSString *path = [self pathWithComponents:@[SGURLPathV1, SGURLPathAlerts, alertID, SGURLPathLocations, queryString]];
    
    return [NSString stringWithFormat:@"%@%@", [SGURL baseURL], path];
}

+ (NSString *)cancelAlert:(NSString *)alertID{
    if (!alertID){
        return nil;
    }
    
    NSString *queryString = [self queryStringForKey:SGURLQueryKeyUserKey value:SGAPIClientKey];
    NSString *path = [self pathWithComponents:@[SGURLPathV1, SGURLPathAlerts, alertID, SGURLPathStatuses, queryString]];
    
    return [NSString stringWithFormat:@"%@%@", [SGURL baseURL], path];
}

@end