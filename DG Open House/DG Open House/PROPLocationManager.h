//
//  PROPLocationManager.h
//  PROPBluetooth
//
//  Created by Jim Dabrowski on 2/4/16.
//  Copyright © 2016 Propeller Health. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MapKit;

/**
 *  `PROPLocationManager` is a wrapper for a CLLocationManager. Its purpose is to begin monitoring for significant location updates and when those updates arrive, cache the last known location on the device. It will provide the last known location (or nil) upon request. If the user does not allow significant location updates or if significant location updates are turned off, requesting the last known location will return nil. If you want the application to be notified of significant location updates while in the background, you need to enable the location updates background mode in the Capabilities tab of the Xcode project. 
 */
@interface PROPLocationManager : NSObject

/**
 *  The shared singleton location manager object.
 *
 *  @return The shared singleton.
 */
+ (instancetype)sharedManager;

/**
 *  The most recent location provided by the last significant location update. This location may be a considerable time in the past if the user's iPhone has not moved. This does not necessarily mean the location does not reflect the user's current location. This method will return nil if the user has turned off or not allowed significant location updates.
 */
@property (nonatomic, readonly) CLLocation* lastKnownLocation;

/**
 *  A boolean indicating whether the location manager is currently allowed to receive significant location updates.
 */
@property (nonatomic, readonly) BOOL isMonitoringSignificantLocationUpdates;

/**
 *  Tells the location manager to begin receiving significant location updates.
 */
- (void)startRequestingSignificantLocationUpdates;

/**
 *  Tells the manager to stop receiving significant location updates. Calling this method will automatically set `lastKnownLocation` to nil and set `isMonitoringSignificantLocationUpdates` to NO. This is because once turned off we can no longer trust any location currently in the location cache.
 */
- (void)stopRequestingSignificantLocationUpdates; 

- (BOOL)hasLocation;

@end
