//
//  PROPLocationCache.m
//  PROPBluetooth
//
//  Created by Jim Dabrowski on 12/7/15.
//  Copyright © 2015 Propeller Health. All rights reserved.
//

#import "PROPLocationCache.h"
#import "DGConstants.h"

// Local constant
static NSString * const PROPLocationCacheFileName = @"location.archive";

@interface PROPLocationCache ()

- (NSString*)cachePath;

@end

@implementation PROPLocationCache
#pragma mark - Lifecycle
+ (PROPLocationCache*)sharedCache
{
    static PROPLocationCache* sharedCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[self alloc] init];
    });
    return sharedCache;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lastKnownLocation = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cachePath]];
        if (!_lastKnownLocation) {
            _lastKnownLocation = nil;
        }
    }
    return self;
}

- (void)setLastKnownLocation:(CLLocation *)lastKnownLocation
{
    if (_lastKnownLocation != lastKnownLocation) {
        _lastKnownLocation = lastKnownLocation;
        if (![self saveLocationToCache]) {
            // Save to disk failed, so remove in-memory version as well.
            _lastKnownLocation = nil;
        }
    }
}

#pragma mark - Private methods
- (NSString*)cachePath
{
    NSArray* cachesDirectories = NSSearchPathForDirectoriesInDomains(useCacheDirectory ? NSCachesDirectory : NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* cachesDirectory = [cachesDirectories firstObject];

    return [cachesDirectory stringByAppendingPathComponent:PROPLocationCacheFileName];
}

- (BOOL)saveLocationToCache
{
    return [NSKeyedArchiver archiveRootObject:self.lastKnownLocation toFile:[self cachePath]];
}

@end
