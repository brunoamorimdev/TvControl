//
//  ConnectionManager.h
//  TvControl
//
//  Created by Bruno Amorim on 17/04/24.
//
#import <ConnectSDK/ConnectSDK.h>

@interface ConnectionManager : NSObject
- (void)discoverDevices;
@end
