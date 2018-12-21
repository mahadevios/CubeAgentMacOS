//
//  ViewController.m
//  CubeAgent
//
//  Created by mac on 20/11/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import "ViewController.h"
#import "Keychain.h"
#import "Constants.h"
#import "HomeViewController.h"
#import "BaseLogFileManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation ViewController

- (void)viewDidLoad
{
    //changes from martina
    [super viewDidLoad];
    
   // [[NSApplication sharedApplication].keyWindow setRepresentedFilename:<#(NSString * _Nonnull)#>];
    
    [self.submitButton setBordered:NO];
    
    [self.submitButton setWantsLayer:YES];
    
    self.submitButton.layer.backgroundColor = [NSColor colorWithCalibratedRed:0.220f green:0.514f blue:0.827f alpha:1.0f].CGColor;

    self.submitButton.layer.cornerRadius = 5;

    [self.backgroundView setWantsLayer:YES];
    
    //    self.submitButton.layer.cornerRadius = 8;
    self.backgroundView.layer.backgroundColor = [NSColor colorWithCalibratedRed:255.0f green:255.0f blue:255.0f alpha:1.0f].CGColor;
    
    [[AppPreferences sharedAppPreferences] startReachabilityNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateMacIDResponse:) name:NOTIFICATION_UPDATE_MAC_ID_API
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateAuthenticateUserResponse:) name:NOTIFICATION_AUTHENTICATE_API
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateCubeConfigResponse:) name:NOTIFICATION_CUBE_CONFIG_API
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateAudioFileExtResponse:) name:NOTIFICATION_AUDIO_FILE_EXTENSIONS_API
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateTransCompName:) name:NOTIFICATION_TC_NAME_API
                                               object:nil];
    
    
    CGSize size =  CGSizeMake(580, 269);
    self.preferredContentSize = size;
    
//    NSString* logDirectoryPath = [[AppPreferences sharedAppPreferences] getCubeLogDirectoryPath];
//    
//    DDLogFileManagerDefault *logManager = [[BaseLogFileManager alloc] initWithLogsDirectory:logDirectoryPath];
//    
//    DDFileLogger * file = [[DDFileLogger alloc] initWithLogFileManager:logManager];
//    
//    [DDLog addLogger:file];
    
    DDLogInfo(@"In LoginView");
    
//    NSError* error;
//
//    NSString *pathToDesktop = [NSString stringWithFormat:@"/Users/%@/Documents/UploadFiles", NSUserName()];
//
//    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToDesktop])
//    {
//        [[NSFileManager defaultManager] createDirectoryAtPath:pathToDesktop withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
//        NSLog(@"");
//    }
//
    
   
    // Do any additional setup after loading the view.
//    [self redirectConsoleLogToDocumentFolder];
}

-(void)viewWillAppear
{
    NSString* macId = [self getFinalMacId];
    
    [self.macIdLabel setStringValue:[@"MACID : "stringByAppendingString:macId]];
    
    bool isRemember = [[NSUserDefaults standardUserDefaults] boolForKey:REMEMBER_ME];
    
    if (isRemember)
    {
        NSString* username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
        
        NSString* password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
        
        self.loginTextField.stringValue = username;
        
        self.paswordTextField.stringValue = password;
        
        [self.rememberMeCheckBox setState:NSOnState];

    }
    else
    {
        self.loginTextField.stringValue = @"";
        
        self.paswordTextField.stringValue = @"";
        
        [self.rememberMeCheckBox setState:NSOffState];
        
    }
    

}
//- (void) redirectConsoleLogToDocumentFolder
//{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                         NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.txt"];
//
//    NSError* error;
//    if(![[NSFileManager defaultManager] fileExistsAtPath:logPath])
//    {
//        BOOL created = [[NSFileManager defaultManager] createFileAtPath:logPath contents:nil attributes:nil];
//
//        NSLog(@"");
//    }
//    freopen([logPath fileSystemRepresentation],"a+",stderr);
//}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

-(void)validateMacIDResponse:(NSNotification*)dictObj
{
    DDLogInfo(@"Finished Updating Mac Id");
    
    NSDictionary* responseDict = dictObj.object;
    
    NSString* responseCodeString =  [responseDict valueForKey:RESPONSE_CODE];
    
    NSString* macIdValidString =  [responseDict valueForKey:RESPONSE_IS_MAC_ID_VALID];

    if ([responseCodeString  isEqualToString: @"200"] && [macIdValidString isEqualToString:SUCCESS])
    {
        DDLogInfo(@"Authenticating User");

        [[APIManager sharedManager] authenticateUser:self.paswordTextField.stringValue username:self.loginTextField.stringValue];

    }
    else
    if ([responseCodeString  isEqualToString: @"200"] && [macIdValidString isEqualToString:FAILURE])
    {
        [hud removeFromSuperview];
        
        [[AppPreferences sharedAppPreferences] showAlertWithTitle:@"Alert" subTitle:@"Username or Password is invalid"];
        
        [self.loginTextField setStringValue:@""];
        
        [self.paswordTextField setStringValue:@""];
        
        [self.loginTextField becomeFirstResponder];
        
    }
}

-(void)validateAuthenticateUserResponse:(NSNotification*)dictObj
{
    NSDictionary* responseDict = dictObj.object;
    
    NSString* responseCodeString =  [responseDict valueForKey:RESPONSE_CODE];
    
    NSString* userIdString =  [responseDict valueForKey:@"userIdString"];
    
    if ([responseCodeString  isEqualToString: @"200"] && ![userIdString isEqualToString:@"0"])
    {
        DDLogInfo(@"User authenticated successfully");

        User* user = [[User alloc] init];
        
        user.userId = [userIdString longLongValue];
        
        user.userName = self.loginTextField.stringValue;
        
        user.macId = [self getFinalMacId];
        
        [AppPreferences sharedAppPreferences].loggedInUser = user;
        
        DDLogInfo(@"Getting configuration info.");

        [[APIManager sharedManager] getCubeConfig:userIdString];
        
        if (self.rememberMeCheckBox.state == NSOnState)
        {
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:REMEMBER_ME];
            
            [[NSUserDefaults standardUserDefaults] setObject:self.loginTextField.stringValue forKey:@"username"];
            
            [[NSUserDefaults standardUserDefaults] setObject:self.paswordTextField.stringValue forKey:@"password"];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setBool:false forKey:REMEMBER_ME];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"username"];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"password"];
        }
       

    }
    else
        
        {
            [hud removeFromSuperview];
            
            [[AppPreferences sharedAppPreferences] showAlertWithTitle:@"Alert" subTitle:@"Username or Password is invalid"];
            
            [self.loginTextField setStringValue:@""];
            
            [self.paswordTextField setStringValue:@""];
            
            [self.loginTextField becomeFirstResponder];
        }
}

-(void)validateCubeConfigResponse:(NSNotification*)dictObj
{
    NSDictionary* responseDict = dictObj.object;
    
//    NSString* responseCodeString =  [responseDict valueForKey:RESPONSE_CODE];
    
//    NSString* userIdString =  [responseDict valueForKey:@"userIdString"];
    
//    if ([responseCodeString  isEqualToString: @"200"])
//    {
        DDLogInfo(@"Configuration info received");

        CubeConfig* cubeConfig = [[CubeConfig alloc] init];
        
        cubeConfig.hashAlgorithm =  [responseDict valueForKey:@"Alg"];
        cubeConfig.EncPassWord =  [responseDict valueForKey:@"EncPassWord"];
        cubeConfig.FTPAudioDirectory =  [responseDict valueForKey:@"FTPAudioDirectory"];
        cubeConfig.FTPDocDirectory =  [responseDict valueForKey:@"FTPDocDirectory"];
        cubeConfig.FTPIP =  [responseDict valueForKey:@"FTPIP"];
        cubeConfig.FTPPassword =  [responseDict valueForKey:@"FTPPassword"];
        cubeConfig.FTPUser =  [responseDict valueForKey:@"FTPUser"];
        cubeConfig.GroupID =  [responseDict valueForKey:@"GroupID"];
        cubeConfig.ParentCompanyID =  [[responseDict valueForKey:@"ParentCompanyID"] intValue];
        cubeConfig.SQLIP =  [responseDict valueForKey:@"SQLIP"];
        cubeConfig.SQLPassword =  [responseDict valueForKey:@"SQLPassword"];
        cubeConfig.SQLUser =  [responseDict valueForKey:@"SQLUser"];
        cubeConfig.SchedularTime =  [[responseDict valueForKey:@"SchedularTime"] longLongValue];
        cubeConfig.ServerCubeDirectory =  [responseDict valueForKey:@"ServerCubeDirectory"];
        
        [AppPreferences sharedAppPreferences].cubeConfig = cubeConfig;
    
        DDLogInfo(@"Getting supported audio file extensions");

        [[APIManager sharedManager] getAudioFileExtensions];
        
//    }
}

-(void)validateAudioFileExtResponse:(NSNotification*)dictObj
{
    DDLogInfo(@"Audio file extensions received");

    NSString* responseString = dictObj.object;
    
    NSMutableArray* supportedAudioFormatArray = [[responseString componentsSeparatedByString:@","] mutableCopy];
    
    [supportedAudioFormatArray removeObject:@""];
    
    [AppPreferences sharedAppPreferences].supportedAudioFileExtensions = supportedAudioFormatArray;
    
    int parentCompanyId = [AppPreferences sharedAppPreferences].cubeConfig.ParentCompanyID;
    
    DDLogInfo(@"Getting Trans company info.");

    [[APIManager sharedManager] getTransCompanyName:[NSString stringWithFormat:@"%d",parentCompanyId]];
    
        
    
}

-(void)validateTransCompName:(NSNotification*)dictObj
{
    DDLogInfo(@"Trans company info received");

    DDLogInfo(@"Login process completed");

    NSString* transCompanyName = dictObj.object;
    
    [AppPreferences sharedAppPreferences].transCompanyName = transCompanyName;
    
    HomeViewController* hvc = [self.storyboard instantiateControllerWithIdentifier:@"HomeViewController"];
    
    [hud removeFromSuperview];
//    [self.view.window setContentView:hvc.view];
    if (self.autoModeCheckBox.state == NSOnState)
    {
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:AUTOMODE];

        [[NSUserDefaults standardUserDefaults] setObject:self.loginTextField.stringValue forKey:@"username"];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.paswordTextField.stringValue forKey:@"password"];
        
        long userId = [AppPreferences sharedAppPreferences].loggedInUser.userId;
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",userId] forKey:@"userId"];

        NSString* macId = [self getFinalMacId];
        
        [[NSUserDefaults standardUserDefaults] setObject:macId forKey:@"macId"];

    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:AUTOMODE];

    }
//    NSWindowController* wc = [self.storyboard instantiateControllerWithIdentifier:@"MainWindow"];
    NSWindowController* wc = [[NSWindowController alloc] initWithWindow:self.view.window];
    
    wc.contentViewController = hvc;
    
    [wc showWindow:[NSApplication sharedApplication].keyWindow];

}

-(NSString*)getFinalMacId
{
    NSString* macId = [[NSUserDefaults standardUserDefaults] objectForKey:MAC_ID];
    
    NSString* uuidOfMac;
    
    if (macId == nil)
    {
        uuidOfMac = [self getMACUUID];
        
        [[NSUserDefaults standardUserDefaults] setObject:uuidOfMac forKey:MAC_ID];
    }
    else
    {
        uuidOfMac = macId;
    }
    return uuidOfMac;
}

- (NSString *)getMACUUID
{
    io_service_t    platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,

                                                                 IOServiceMatching("IOPlatformExpertDevice"));
    CFStringRef serialNumberAsCFString = NULL;

//    kIOPlatformUUIDKey
//    kIOPlatformSerialNumberKey
    if (platformExpert) {
        serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,
                                                                 CFSTR(kIOPlatformUUIDKey),
                                                                 kCFAllocatorDefault, 0);
        IOObjectRelease(platformExpert);
    }

    NSString *serialNumberAsNSString = nil;
    if (serialNumberAsCFString) {
        serialNumberAsNSString = [NSString stringWithString:(__bridge NSString *)serialNumberAsCFString];
        CFRelease(serialNumberAsCFString);
    }


//    get_platform_uuid(str, strlen(str));
    return serialNumberAsNSString;



//SYS_gethostuuid
}


- (IBAction)autoModeCheckBoxClicked:(id)sender
{
    if ([sender state] == NSOnState)
    {
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:AUTOMODE];
        
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:AUTOMODE];
        
    }
    
}
- (IBAction)rememberMeCheckBoxClicked:(NSButton*)sender
{
    if ([sender state] == NSOnState)
    {
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:REMEMBER_ME];

    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:REMEMBER_ME];

    }
}
- (IBAction)submitButtonClicked:(id)sender
{
    NSRange whiteSpaceInUsername = [self.loginTextField.stringValue rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    
     NSRange whiteSpaceInPassword = [self.paswordTextField.stringValue rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
        if([self.loginTextField.stringValue length] == 0 || whiteSpaceInUsername.location != NSNotFound)
        {
            [[AppPreferences sharedAppPreferences] showAlertWithTitle:@"Alert" subTitle:@"Please enter Username."];
            
            [self.loginTextField setStringValue:@""];
            
            [self.loginTextField becomeFirstResponder];

        }
        else if([self.paswordTextField.stringValue length] == 0 || whiteSpaceInPassword.location != NSNotFound)
        {
            [[AppPreferences sharedAppPreferences] showAlertWithTitle:@"Alert" subTitle:@"Please enter Password."];
            
            [self.paswordTextField setStringValue:@""];
            
            [self.paswordTextField becomeFirstResponder];
        }
        else
        {
            NSString* macId = [self getFinalMacId];
            
            NSLog(@"macId is %@",macId);
            if ([[AppPreferences sharedAppPreferences] isReachable])
            {
                [[APIManager sharedManager] updateDeviceMacID:macId password:self.paswordTextField.stringValue username:self.loginTextField.stringValue];
                
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:true];
                
                [hud setDetailsLabelText:@"Logging In, please wait"];
            }
            else
            {
                [[AppPreferences sharedAppPreferences] showAlertWithTitle:@"Alert" subTitle:@"Please check your internet connection."];
            }
           
        }



}

//-(void)getDirectory
//{
//    NSOpenPanel *panel = [NSOpenPanel openPanel];
//    
//    // changes promt to Select
//    [panel setPrompt:@"Select"];
//    
//    // Enable the selection of files in the dialog.
//    [panel setCanChooseFiles:YES];
//    
//    // Enable the selection of directories in the dialog.
//    [panel setCanChooseDirectories:YES];
//    
//    //allows multi select
//    [panel setAllowsMultipleSelection:NO];
//    
//    NSString *pathToDownloads = [NSString stringWithFormat:@"/Users/%@/Documents", NSUserName()];
//    
//    //    if(exists){
//    [panel setDirectoryURL:[NSURL fileURLWithPath:pathToDownloads]];
//    //    }
//    
//    [panel beginSheetModalForWindow:[NSApplication sharedApplication].mainWindow
//                  completionHandler:^(NSInteger returnCode) {
//                      if (returnCode == NSModalResponseOK)
//                      {
//                          NSURL *theURL = [[panel URLs] objectAtIndex:0];
//                          
//                          NSData* data  = [NSData dataWithContentsOfURL:theURL];
//                          
//                          //                          NSLog(@"%@",data);
//                      }}];
//}


- (void)saveFile:(NSString *)path extension:(NSString *)extension
{
    // Build a save dialog
    self.savePanel = [NSSavePanel savePanel];
    self.savePanel.allowedFileTypes = @[ extension ];
    self.savePanel.allowsOtherFileTypes = NO;
    
    // Hide this window
    //    [[NSApplication sharedApplication].keyWindow orderOut:self];
    
    [self.savePanel setDirectoryURL:[NSURL URLWithString:@"/Users/user/desktop"]];
    
    // Run the save dialog
    NSInteger result = [self.savePanel runModal];
    if (result == NSModalResponseOK) {
        // Build the URLs
        NSURL *sourceURL = [NSURL fileURLWithPath:path];
        NSURL *destinationURL = self.savePanel.URL;
        
        // Delete any existing file
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        
        if ([fileManager fileExistsAtPath:destinationURL.path]) {
            [fileManager removeItemAtURL:destinationURL error:&error];
            
            if (error != nil) {
                [[NSAlert alertWithError:error] runModal];
            }
        }
        
        // Bail on error
        if (error != nil) {
            return;
        }
        
        // Copy the file
        [[NSFileManager defaultManager] copyItemAtURL:sourceURL toURL:destinationURL error:&error];
        
        if (error != nil) {
            [[NSAlert alertWithError:error] runModal];
        }
    }
    
    // Cleanup
    self.savePanel = nil;
}

-(void)changeStatusOfDocFiles
{
//    653052
//    653051
//    653050
//    653049
//    653048
//    653047
//    653046
    NSArray * array = [[NSArray alloc] initWithObjects:@"653052",@"653051",@"653050",@"653049",@"653048",@"653047",@"653046", nil];
    
    for (int i = 0; i < array.count; i++)
    {
        [[APIManager sharedManager] updateDownloadFileStatus:@"9" dictationId:[array objectAtIndex:i]];
    }
//    [APIManager sharedManager] updateDownloadFileStatus:@"9" dictationId:<#(NSString *)#>
}

- (IBAction)changeStatusButtonClicked:(id)sender
{
    [self changeStatusOfDocFiles];
}

@end
//setting background color for submit button
//    self.submitButton.layer.backgroundColor = NSColor.redColor.CGColor;

//    NSString*  macId=[Keychain getStringForKey:@"udid"];


//    NSLog(@"doKeyForPassword: %@",key);
//    [[APIManager sharedManager] checkAPI];

//    [[APIManager sharedManager] authenticateUserMacIDLocal:@"DDCF3B2D-362B-4C81-8AB3-DD56D49E5365" password:@"d" username:@"SAN"];
//6DBC967F-3C38-46C9-BE74-DF3588C77475
//    4DE5E8E1-4764-566D-8C35-AC3F7C5A447D --uuid
//    NSUUID* uid = [NSUUID UUID];
//- (NSString*) getMACAddress: (BOOL)stripColons {
//    NSMutableString         *macAddress         = nil;
//    NSArray                 *allInterfaces      = SCNetworkInterfaceCopyAll();
//    NSEnumerator            *interfaceWalker    = [allInterfaces objectEnumerator];
//    SCNetworkInterfaceRef   curInterface        = nil;
//
//    while ( curInterface = (SCNetworkInterfaceRef)[interfaceWalker nextObject] ) {
//        if ( [(NSString*)SCNetworkInterfaceGetBSDName(curInterface) isEqualToString:@"en0"] ) {
//            macAddress = [[(NSString*)SCNetworkInterfaceGetHardwareAddressString(curInterface) mutableCopy] autorelease];
//
//            if ( stripColons == YES ) {
//                [macAddress replaceOccurrencesOfString: @":" withString: @"" options: NSLiteralSearch range: NSMakeRange(0, [macAddress length])];
//            }
//
//            break;
//        }
//    }
//
//    return [macAddress copy]];
//}
//void get_platform_uuid(char * buf, int bufSize) {
//    io_registry_entry_t ioRegistryRoot = IORegistryEntryFromPath(kIOMasterPortDefault, "IOService:/");
//    CFStringRef uuidCf = (CFStringRef) IORegistryEntryCreateCFProperty(ioRegistryRoot, CFSTR(kIOPlatformUUIDKey), kCFAllocatorDefault, 0);
//    IOObjectRelease(ioRegistryRoot);
//    bool c =  CFStringGetCString(uuidCf, buf, bufSize, kCFStringEncodingMacRoman);
//    CFRelease(uuidCf);
//}

