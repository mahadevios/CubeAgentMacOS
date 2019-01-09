//
//  AboutCubeAgentViewController.m
//  Cube Agent
//
//  Created by mac on 09/01/19.
//  Copyright © 2019 Xanadutec. All rights reserved.
//

#import "AboutCubeAgentViewController.h"

@interface AboutCubeAgentViewController ()

@end

@implementation AboutCubeAgentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];

    self.versionLabel.stringValue = [NSString stringWithFormat:@"%@(%@)",majorVersion,minorVersion];
}

@end
