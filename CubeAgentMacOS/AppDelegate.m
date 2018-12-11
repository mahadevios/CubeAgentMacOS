//
//  AppDelegate.m
//  CubeAgentMacOS
//
//  Created by mac on 23/11/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self redirectConsoleLogToDocumentFolder];
}

-(void)applicationWillFinishLaunching:(NSNotification *)notification
{
    
}
- (void) redirectConsoleLogToDocumentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.txt"];
    
    NSError* error;
    if(![[NSFileManager defaultManager] fileExistsAtPath:logPath])
    {
       BOOL created = [[NSFileManager defaultManager] createFileAtPath:logPath contents:nil attributes:nil];
        
        NSLog(@"");
    }
    freopen([logPath fileSystemRepresentation],"a+",stderr);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
