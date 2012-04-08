//
//  LocationSingleton.h
//  Circle
//
//  Created by Joshua Conner on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationSingletonDelegate
@required
- (void)didRecieveLocationUpdate:(CLLocation *)location;
@end

@interface LocationSingleton: NSObject <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (weak, nonatomic) id delegate;

+ (LocationSingleton *)sharedInstance; //Singleton method
@end
