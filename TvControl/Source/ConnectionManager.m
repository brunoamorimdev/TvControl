//
//  ConnectionManager.m
//  TvControl
//
//  Created by Bruno Amorim on 17/04/24.
//
#import "ConnectionManager.h"
#import <CoreLocation/CoreLocation.h>
#import <ConnectSDK/ConnectSDK.h>

@interface ConnectionManager () <CLLocationManagerDelegate, DiscoveryManagerDelegate, ConnectableDeviceDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) DiscoveryManager *discoveryManager;
@property (nonatomic, strong) NSMutableArray<ConnectableDevice *> *allDevices;
@end

@implementation ConnectionManager

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.allDevices = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)discoverDevices {
    if ([self.locationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [self.locationManager authorizationStatus] == kCLAuthorizationStatusDenied || [self.locationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        [self.locationManager requestWhenInUseAuthorization];
    } else {
        [self locationManager:self.locationManager didChangeAuthorizationStatus:[self.locationManager authorizationStatus]];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        // Initialize and start DiscoveryManager here to ensure it's ready and authorized
        self.discoveryManager = [DiscoveryManager sharedManager];
        self.discoveryManager.delegate = self;
        [self.discoveryManager startDiscovery];
    } else {
        // Handle not authorized status
        NSLog(@"Location Authorization Denied");
    }
}

#pragma mark - DiscoveryManagerDelegate

- (void)discoveryManager:(DiscoveryManager *)manager didFindDevice:(ConnectableDevice *)device {
    NSLog(@"Found device: %@", device.friendlyName);
    [self.allDevices addObject:device];
    // Post notification or call delegate method to inform interested parties of new device
}

- (void)discoveryManager:(DiscoveryManager *)manager didLoseDevice:(ConnectableDevice *)device {
    NSLog(@"Lost device: %@", device.friendlyName);
    [self.allDevices removeObject:device];
    // Post notification or update UI accordingly
}

- (void)discoveryManager:(DiscoveryManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Discovery failed with error: %@", error);
}

- (void)discoveryManager:(DiscoveryManager *)manager didUpdateDevice:(ConnectableDevice *)device {
    // Handle device updates here. For example, you might want to update your stored device list.
    NSLog(@"Device updated: %@", device.friendlyName);
    
    // Find the device in your allDevices array and update it
    NSInteger existingIndex = [self.allDevices indexOfObjectPassingTest:^BOOL(ConnectableDevice* _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.id isEqualToString:device.id];
    }];
    
    if (existingIndex != NSNotFound) {
        // Update the device at the found index
        [self.allDevices replaceObjectAtIndex:existingIndex withObject:device];
        // Optionally, notify delegate or post a notification about the update
    } else {
        // This should not happen if all found devices are being correctly managed
        // Consider adding the device to the list as it seems to be new
        [self.allDevices addObject:device];
        // Optionally, notify delegate or post a notification about the new device
    }
}

#pragma mark - ConnectableDeviceDelegate

- (void)connectableDeviceDisconnected:(ConnectableDevice *)device withError:(NSError *)error {
    NSLog(@"Device disconnected: %@", device.friendlyName);
}

- (void)connectableDeviceReady:(ConnectableDevice *)device {
    NSLog(@"Device ready: %@", device.friendlyName);
    // Device is connected and ready to be used
}

@end
