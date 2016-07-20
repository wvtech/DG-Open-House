//
//  PROPLocationCache.h
//  PROPBluetooth
//
//  Created by Jim Dabrowski on 12/7/15.
//  Copyright © 2015 Propeller Health. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MapKit;

/**
 *  `PROPLocationCache` provides a mechanism to store a `CLLocation` object in ~/Library/Caches for use when storing event record data. Users will not typically need to access this cache directly but should do so through the `PROPLocationManager` instead. 
 */
@interface PROPLocationCache : NSObject

/**
 *  A shared cache of the most recent location.
 *
 *  @return The shared location cache instance.
 */
+ (instancetype)sharedCache;

/**
 *  The last known location. Whenever iOS notifies the location manager of a significant location update, that location is stored in the shared cache and returned as this property. 
 */
@property (nonatomic) CLLocation* lastKnownLocation;

@end