//
//  AppDelegate.h
//  CubeAgentMacOS
//
//  Created by mac on 23/11/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViewController.h"
#import "HomeViewController.h"
#import "User.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSWindow *overlayWindow ;
    NSWindowController* vc;
}
@property (nonatomic,strong) ViewController *viewController;
@property (nonatomic,strong) HomeViewController *homeViewController;

@property (nonatomic,strong) NSWindowController *windowController;

@end

