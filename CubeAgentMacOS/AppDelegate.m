//
//  AppDelegate.m
//  CubeAgentMacOS
//
//  Created by mac on 23/11/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
//- (void)applicationDidBecomeActive:(NSNotification *)notification
//{
//    NSLog(@"automode is on2");
//    DDLogInfo(@"automode is on2");
//}
//
//-(void)applicationWillFinishLaunching:(NSNotification *)notification
//{    NSLog(@"automode is on");
//    DDLogInfo(@"automode is on");
//
//    bool isAutomode = [[NSUserDefaults standardUserDefaults] boolForKey:AUTOMODE];
//
//    if(isAutomode)
//    {
//        self.viewController = [[NSViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
//        [[NSApplication sharedApplication].keyWindow makeFirstResponder:self.viewController];
//    }
//}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
   
    
//    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil]; // get a reference to the storyboard
////
//    BOOL isAutoMode = [[NSUserDefaults standardUserDefaults] boolForKey:AUTOMODE];
//
//    isAutoMode = false;
//
//    if (isAutoMode)
//    {
//
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(validateAudioFileExtResponse:) name:NOTIFICATION_AUDIO_FILE_EXTENSIONS_API
//                                                   object:nil];
//
//        [[APIManager sharedManager] getAudioFileExtensions];
//
//    }
//    else
//    {
//        self.windowController = [storyBoard instantiateControllerWithIdentifier:@"MainWindow"]; // instantiate your window controller
//
//        self.viewController = [storyBoard instantiateControllerWithIdentifier:@"ViewController"]; // instantiate your window controller
//
//        //    controller.Window.MakeKeyAndOrderFront (this);
//        self.windowController.contentViewController = self.viewController;
//
//        [self.windowController showWindow:[NSApplication sharedApplication].keyWindow];
//
//    }
  
   

 
}


//-(void)showHomeView
//{
//    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil]; // get a reference to the storyboard
//
//    User* loggedInUser  = [User new];
//    
//    loggedInUser.userName= [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
//    
//    loggedInUser.password  = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
//    
//    loggedInUser.macId  = [[NSUserDefaults standardUserDefaults] objectForKey:@"macId"];
//    
//    loggedInUser.userId  = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] longLongValue];
//    
//    [AppPreferences sharedAppPreferences].loggedInUser = loggedInUser;
//    
//    self.windowController = [storyBoard instantiateControllerWithIdentifier:@"MainWindow"]; // instantiate your window controller
//    
//    self.homeViewController = [storyBoard instantiateControllerWithIdentifier:@"HomeViewController"]; // instantiate your window controller
//    
//    //    controller.Window.MakeKeyAndOrderFront (this);
//    self.windowController.contentViewController = self.homeViewController;
//    
//    [self.windowController.window makeKeyAndOrderFront:self.homeViewController];
//}
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}
@end
