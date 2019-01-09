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

- (IBAction)aboutCubeAgentButtonClicked:(id)sender
{
     NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil]; // get a reference to the storyboard
    
//    self.windowController = [storyBoard instantiateControllerWithIdentifier:@"AboutCubeAgent"]; // instantiate your window controller
    
//    self.viewController = [storyBoard instantiateControllerWithIdentifier:@"ViewController"]; // instantiate your window controller
    
            //    controller.Window.MakeKeyAndOrderFront (this);
    if (vc == nil)
    {
        vc = [storyBoard instantiateControllerWithIdentifier:@"Window"];

    }
    if (self.windowController == nil)
    {
        self.windowController =  [NSWindowController new];

    }
    
    [vc.window standardWindowButton:NSWindowZoomButton].enabled = false;
    
    [vc.window standardWindowButton:NSWindowMiniaturizeButton].enabled = false;

    [vc.window standardWindowButton:NSWindowFullScreenButton].enabled = false;

//    [vc.window standardWindowButton:NSWindowTitleHidden].enabled = false;
//    [vc.window standardWindowButton:NSWindowStyleMaskResizable].enabled = false;

//    [vc.window setStyleMask:NSWindowStyleMaskResizable];
    vc.window.title = @"";
    
//    self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);

//    [self.windowController showWindow:[NSApplication sharedApplication].keyWindow];
    
//    [self.windowController.contentViewController presentViewControllerAsModalWindow:vc];
//    [[NSApplication sharedApplication].keyWindow.contentViewController presentViewControllerAsModalWindow:vc];
    
//    BOOL isVisible = [vc.window isVisible];
//    if (!isVisible)
//    {
//    [vc.window setStyleMask:!NSWindowStyleMaskResizable];
//    [vc.window setStyleMask:!NSWindowStyleMaskMiniaturizable];
//    [vc.window setStyleMask:!NSWindowStyleMaskTitled];
//    [vc.window setStyleMask:!NSWindowStyleMaskFullScreen];



         [vc showWindow:vc.window];
//    }
    
   
    
//    [NSApplication sharedApplication].keyWindow p
    
//    NSRect rect = [NSApplication sharedApplication].keyWindow.frame;   //this is full screen size, but still with the status bar like time, battery, etc.
//    CGFloat menuBarHeight = [[[NSApplication sharedApplication] mainMenu] menuBarHeight];
//
//    
//    NSRect rect1 = NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - menuBarHeight);
//    
//    overlayWindow = [[NSWindow alloc]initWithContentRect:rect1
//                                                         styleMask:NSBorderlessWindowMask
//                                                           backing:NSBackingStoreBuffered
//                                                             defer:NO];
//    
//    [overlayWindow setLevel:NSPopUpMenuWindowLevel];
//    
//    [overlayWindow setAlphaValue:.5];
//    
//    overlayWindow.backgroundColor = [NSColor grayColor];
//    
//    NSView* contenetView = [[NSView alloc] initWithFrame:rect1];
//    
//    NSButton* crossButton = [[NSButton alloc] initWithFrame:NSMakeRect(110, 750 , 50, 50)];
//    
//    [crossButton setWantsLayer:YES];
//
//    [crossButton.layer setBackgroundColor:[NSColor blueColor].CGColor];
//    
//    [contenetView addSubview:crossButton];
//    
//    [overlayWindow setContentView:contenetView];
//    
//    [[NSApplication sharedApplication].keyWindow addChildWindow:overlayWindow ordered:NSWindowAbove];
//    
    
}

-(void)tapped:(id)sender
{
    [[NSApplication sharedApplication].keyWindow removeChildWindow:overlayWindow];
}

- (IBAction)quitCubeAgentButtonClicked:(id)sender
{
    [[NSApplication sharedApplication] terminate:self];
}
@end
