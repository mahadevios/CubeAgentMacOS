//
//  ViewController.m
//  CubeAgent
//
//  Created by mac on 20/11/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import "ViewController.h"
#import "Keychain.h"



@implementation ViewController

- (void)viewDidLoad
{
    //changes from martina
    [super viewDidLoad];
    
    NSString*  macId=[Keychain getStringForKey:@"udid"];
    
    
    //    NSLog(@"doKeyForPassword: %@",key);
    //    [[APIManager sharedManager] checkAPI];
    
    //    [[APIManager sharedManager] authenticateUserMacIDLocal:@"DDCF3B2D-362B-4C81-8AB3-DD56D49E5365" password:@"d" username:@"SAN"];
    
    [[APIManager sharedManager] updateDeviceMacID:@"DDCF3B2D-362B-4C81-8AB3-DD56D49E5365" password:@"d" username:@"SAN"];
    
    
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}


@end
