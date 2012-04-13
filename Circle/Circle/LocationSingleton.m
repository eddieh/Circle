//
//  LocationSingleton.m
//  Circle
//
//  Created by Joshua Conner on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationSingleton.h"

//timeout searching for best-accuracy location after 60 seconds to save battery
#define LOCATION_TIMEOUT 60.0


@interface LocationSingleton ()
@property (strong, nonatomic) NSTimer *locationTimer;
@end

@implementation LocationSingleton
@synthesize locationManager = _locationManager;
@synthesize currentLocation = _currentLocation;
@synthesize locationTimer = _locationTimer;
@synthesize delegate = _delegate;

+ (LocationSingleton *)sharedInstance {
    static LocationSingleton *_sharedInstance = nil;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (id) init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self startUpdatingLocationWithTimer];
    }

    return self;
}

/**
 * start and stop timer methods
 *
 * starts trying to get location, and then cancels after 60 seconds or once a "good enough" location 
 * is found.
 */
- (void)startUpdatingLocationWithTimer {
    [self.locationManager startUpdatingLocation];
    self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:LOCATION_TIMEOUT target:self selector:@selector(stopUpdatingLocationWithTimer) userInfo:nil repeats:NO];
}

- (void)stopUpdatingLocationWithTimer {
    [self.locationManager stopUpdatingLocation];
    [self.locationTimer invalidate];
}


#pragma mark - CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.currentLocation = newLocation;
    [self.delegate didRecieveLocationUpdate:self.currentLocation];
    
    //stop updating location when it gets 100m accuracy
    if (newLocation.horizontalAccuracy <= 100.0f) { 
        [self.locationManager stopUpdatingLocation]; 
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if(error.code == kCLErrorDenied) {
        [self.locationManager stopUpdatingLocation];
    } else if (error.code == kCLErrorLocationUnknown) {
        // ignore and retry
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
                                                        message:[error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}


@end
