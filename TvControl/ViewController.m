//
//  ViewController.m
//  TvControl
//
//  Created by Bruno Amorim on 16/04/24.
//

#import "ViewController.h"
#import "Source/ConnectionManager.h"
#import <ConnectSDK/ConnectSDK.h>

@interface ViewController ()
@property (nonatomic, strong) ConnectionManager *manager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [[ConnectionManager alloc] init];
    [self.manager discoverDevices];
}

@end
