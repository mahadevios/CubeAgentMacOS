//
//  HomeViewController.m
//  CubeAgentMacOS
//
//  Created by Martina Makasare on 11/29/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import "HomeViewController.h"
#import "APIManager.h"
#import "Constants.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateEncDecrReponse:) name:NOTIFICATION_GET_ENCRYPT_DECRYPT_STRING_API
                                               object:nil];
    
    [[APIManager sharedManager] getEncryptDecryptString];
}

-(void)validateEncDecrReponse:(NSNotification*)notification
{
    NSString* responseString = notification.object;
    
    NSLog(@"");
}

@end

