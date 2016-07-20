//
//  PROPLocationManager.m
//  PROPBluetooth
//
//  Created by Jim Dabrowski on 2/4/16.
//  Copyright © 2016 Propeller Health. All rights reserved.
//

#import "PROPLocationManager.h"
#import "PROPLocationCache.h"

@interface PROPLocationManager () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager* locationManager;
@property (nonatomic, assign) BOOL isMonitoringSignificantLocationUpdates;
@property (nonatomic) CLLocation* lastKnownLocation;

@end

@implementation PROPLocationManager
#pragma mark - Lifecycle
+ (instancetype)sharedManager
{
    static PROPLocationManager* sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isMonitoringSignificantLocationUpdates = NO;
        _lastKnownLocation = [[PROPLocationCache sharedCache] lastKnownLocation];
    }
    return self;
}

- (void)startRequestingSignificantLocationUpdates
{
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted) {
        // Location is not denied or restricted, so we can proceed
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            // We don't know if we can use location services
            [self.locationManager requestAlwaysAuthorization];
        }
        
        if ([CLLocationManager significantLocationChangeMonitoringAvailable] && [CLLocationManager locationServicesEnabled]) {
            [self.locationManager startMonitoringSignificantLocationChanges];
            self.isMonitoringSignificantLocationUpdates = YES;
        }
    }
}

- (void)stopRequestingSignificantLocationUpdates
{
    [self.locationManager stopMonitoringSignificantLocationChanges];
    self.isMonitoringSignificantLocationUpdates = NO;
    self.lastKnownLocation = nil;
}

- (BOOL)hasLocation
{
    if (CLLocationCoordinate2DIsValid(self.lastKnownLocation.coordinate) && self.lastKnownLocation.coordinate.latitude != 0 && self.lastKnownLocation.coordinate.longitude != 0){
        return YES;
    }
    return NO;
}

#pragma mark - CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            // Changed to denied or restricted.
            // Stop monitoring.
            [self.locationManager stopMonitoringSignificantLocationChanges];
            self.isMonitoringSignificantLocationUpdates = NO;
            self.lastKnownLocation = nil;
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            // Authorized so start monitoring
            [self.locationManager startMonitoringSignificantLocationChanges];
            self.isMonitoringSignificantLocationUpdates = YES;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    // When we get an updated location, the most recent update is always last according to Apple.
    [PROPLocationCache sharedCache].lastKnownLocation = locations.lastObject;
    self.lastKnownLocation = [[PROPLocationCache sharedCache] lastKnownLocation];    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager did fail with error: %@", error);
}

@end
