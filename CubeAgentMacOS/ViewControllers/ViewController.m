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
#import "AppDelegate.h"

@implementation ViewController

- (void)viewDidLoad
{
    //changes from martina
    [super viewDidLoad];
    
    [[AppPreferences sharedAppPreferences] startReachabilityNotifier];

    NSError *error;
//    NSURL *appSupportDir = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    
//    NSLog(@"%@", appSupportDir);
    // file://localhost/Users/abhi/Library/Application%20Support/
//    NSLog(@"%@", NSHomeDirectory());
    
//    [[NSUserDefaults standardUserDefaults] setObject:@"/Users/admin/Library/Containers/com.xanadutec.CubeAgentMacOS/Data/Downloads" forKey:DOWNLOAD_FOLDER_BOOKMARK_PATH];
    
//    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSMusicDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
//    NSArray *libraryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:libraryPath error:nil];
    
//    [self.autoModeCheckBox setWantsLayer:YES];
//    [self.autoModeCheckBox.layer setBorderWidth:3.0];
//    [self.autoModeCheckBox.layer setBorderColor:[NSColor redColor].CGColor];

//    [[NSApplication sharedApplication].keyWindow setRepresentedFilename:(NSString * _Nonnull)];
    
//    [[[NSApplication sharedApplication].keyWindow standardWindowButton:NSWindowDocumentIconButton]
//     setImage:[NSApp applicationIconImage]];
    // Add the custom button to the title bar.
  //  NSTitlebarAccessoryViewController * access = [[NSTitlebarAccessoryViewController alloc] init];
//
//    access.view = self.view;
//
//    access.layoutAttribute = NSLayoutAttributeRight;
//
  // [[NSApplication sharedApplication].keyWindow addTitlebarAccessoryViewController:access];
//    [[NSApplication sharedApplication].keyWindow  setTitleWithRepresentedFilename:[NSURL URLWithString:@"16x16.png"].absoluteString];
//    // Set out custom icon
//    [[[NSApplication sharedApplication].keyWindow  standardWindowButton:NSWindowDocumentIconButton] setImage:[NSImage imageNamed:@"16x16.png"]];
    [[NSApplication sharedApplication].keyWindow  setRepresentedURL:[NSURL URLWithString:@"WindowTitle"]];
    // Set our custom icon
    [[[NSApplication sharedApplication].keyWindow  standardWindowButton:NSWindowDocumentIconButton] setImage:[NSImage imageNamed:@"Home_logo"]];
    
    [self adjustViewAppearance];
//    [self.rememberMeCheckBox setWantsLayer:YES];
//    [self.rememberMeCheckBox.layer setShadowOffset:CGSizeMake(5, 5)];
//    [self.rememberMeCheckBox.layer setShadowColor:[[NSColor blackColor] CGColor]];

//
//    [self.rememberMeCheckBox.layer setBackgroundColor:[NSColor clearColor].CGColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateNoInternet:) name:NOTIFICATION_NO_INTERNET
                                               object:nil];
    
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

    NSString* existingVersion = [[NSUserDefaults standardUserDefaults] objectForKey:APP_CURRENT_VERSION];

    [[AppPreferences sharedAppPreferences] addLoggerOnce];

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
  
//    [[NSUserDefaults standardUserDefaults] setObject:@"1.0.2" forKey:APP_CURRENT_VERSION];
//
//    [[NSUserDefaults standardUserDefaults] setBool:false forKey:DOWNLOAD_FOLDER_BOOKMARK_GENERATED];
//    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults removeObjectForKey:DOWNLOAD_FOLDER_BOOKMARK_PATH];
//    [userDefaults synchronize];
    if(![majorVersion isEqualToString:existingVersion]){
        
        [[NSUserDefaults standardUserDefaults] setObject:majorVersion forKey:APP_CURRENT_VERSION];

        [[NSUserDefaults standardUserDefaults] setBool:false forKey:DOWNLOAD_FOLDER_BOOKMARK_GENERATED];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:DOWNLOAD_FOLDER_BOOKMARK_PATH];
        [userDefaults synchronize];
        
    }
    
    
    DDLogInfo(@"In LoginView");
    
}

-(void)viewWillAppear
{
    
    NSString* macId = [self getFinalMacId];
    
    [self.macIdLabel setStringValue:[@"MACID : "stringByAppendingString:macId]];
    
    BOOL isAutoMode = [[NSUserDefaults standardUserDefaults] boolForKey:AUTOMODE];
    
    bool isRemember = [[NSUserDefaults standardUserDefaults] boolForKey:REMEMBER_ME];
    
    //isAutoMode = false;
    
    if (isAutoMode)
    {
        NSString* username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
        
        NSString* password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
        
        if (username != nil && password != nil)
        {
            self.loginTextField.stringValue = username;
            
            self.paswordTextField.stringValue = password;
        }
       
        
        [self.autoModeCheckBox setState:NSOnState];
        
        //        [self performSelector:@selector(submitUserValidate) withObject:nil afterDelay:2.0];
        [self submitUserValidate];
        
    }
    else
    {
        [self.autoModeCheckBox setState:NSOffState];
        
    }
    
    if (isRemember)
    {
        NSString* username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
        
        NSString* password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
        
        if (username != nil && password != nil)
        {
            self.loginTextField.stringValue = username;
            
            self.paswordTextField.stringValue = password;
        }
        
        [self.rememberMeCheckBox setState:NSOnState];
        
    }
    else
    {
        [self.rememberMeCheckBox setState:NSOffState];
        
    }
    //    else
    //    {
    //        self.loginTextField.stringValue = @"";
    //
    //        self.paswordTextField.stringValue = @"";
    //
    //        [self.rememberMeCheckBox setState:NSOffState];
    //
    //    }
    
    
}
- (NSURL*)applicationDataDirectory
{
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSArray* possibleURLs = [sharedFM URLsForDirectory:NSApplicationSupportDirectory
                                             inDomains:NSLocalDomainMask];
    NSURL* appSupportDir = nil;
    NSURL* appDirectory = nil;
    
    if ([possibleURLs count] >= 1) {
        // Use the first directory (if multiple are returned)
        appSupportDir = [possibleURLs objectAtIndex:0];
    }
    
    // If a valid app support directory exists, add the
    // app's bundle ID to it to specify the final directory.
    if (appSupportDir) {
        NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
        appDirectory = [appSupportDir URLByAppendingPathComponent:appBundleID];
    }
    
    return appDirectory;
}

-(void)adjustViewAppearance
{
    [self.loginTextField setWantsLayer:YES];
    
    [self.loginTextField.layer setBorderWidth:1.0];
    
    [self.loginTextField.layer setBorderColor:[NSColor lightGrayColor].CGColor];
    
    [self.loginTextField.layer setCornerRadius:4.0];
    
    [self.paswordTextField setWantsLayer:YES];
    
    [self.paswordTextField.layer setBorderWidth:1.0];
    
    [self.paswordTextField.layer setBorderColor:[NSColor lightGrayColor].CGColor];
    
    [self.paswordTextField.layer setCornerRadius:4.0];
    
    [self.submitButton setBordered:NO];
    
    [self.submitButton setWantsLayer:YES];
    
    self.submitButton.layer.backgroundColor = [NSColor colorWithCalibratedRed:0.220f green:0.514f blue:0.827f alpha:1.0f].CGColor;
    
    self.submitButton.layer.cornerRadius = 5;
    
    [self.backgroundView setWantsLayer:YES];
    
    //    self.submitButton.layer.cornerRadius = 8;
    self.backgroundView.layer.backgroundColor = [NSColor colorWithCalibratedRed:255.0f green:255.0f blue:255.0f alpha:1.0f].CGColor;
    
    
    NSMutableAttributedString *attrTitle =
    [[NSMutableAttributedString alloc] initWithString:@"Remember Me"];
    NSUInteger len = [attrTitle length];
    NSRange range = NSMakeRange(0, len);
    [attrTitle addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:range];
    [attrTitle fixAttributesInRange:range];
    [self.rememberMeCheckBox setAttributedTitle:attrTitle];
    
    NSMutableAttributedString *attrTitle1 =
    [[NSMutableAttributedString alloc] initWithString:@"Auto-Mode"];
    NSUInteger len1 = [attrTitle1 length];
    NSRange range1 = NSMakeRange(0, len1);
    [attrTitle1 addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:range1];
    
    [attrTitle1 fixAttributesInRange:range1];
    [self.autoModeCheckBox setAttributedTitle:attrTitle1];
    
}
-(void)viewWillDisappear
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_NO_INTERNET object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)validateNoInternet:(NSNotification*)noti
{
    if (hud != nil)
    {
        [hud removeFromSuperview];

    }
    [[AppPreferences sharedAppPreferences] showAlertWithTitle:@"Alert" subTitle:@"Unable to reach the server. Please try again."];
    
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

    if ([responseCodeString  isEqualToString: @"-1009"])
    {
        [hud removeFromSuperview];
        
        [[AppPreferences sharedAppPreferences] showAlertWithTitle:@"Alert" subTitle:macIdValidString];
        
        return;
    }
    if ([responseCodeString  isEqualToString: @"200"] && [macIdValidString isEqualToString:SUCCESS])
    {
        // ---> adding username in log
        DDLogInfo(@"Authenticating User : %@",self.loginTextField.stringValue);

        [[APIManager sharedManager] authenticateUser:self.paswordTextField.stringValue username:self.loginTextField.stringValue];

    }
    else
    if ([responseCodeString  isEqualToString: @"200"] && [macIdValidString isEqualToString:FAILURE])
    {
        [hud removeFromSuperview];
        
        [[AppPreferences sharedAppPreferences] showAlertWithTitle:@"Alert" subTitle:@"Login Id or Password is invalid"];
        
        [self.loginTextField setStringValue:@""];
        
        [self.paswordTextField setStringValue:@""];
        
        [self.loginTextField becomeFirstResponder];
        
    }
    else
    {
        [hud removeFromSuperview];

    }
}

-(void)validateAuthenticateUserResponse:(NSNotification*)dictObj
{
    NSDictionary* responseDict = dictObj.object;
    
    NSString* responseCodeString =  [responseDict valueForKey:RESPONSE_CODE];
    
    NSString* userIdString =  [responseDict valueForKey:@"userIdString"];
    
    if ([responseCodeString  isEqualToString: @"200"] && ![userIdString isEqualToString:@"0"])
    {
        DDLogInfo(@"%@ User authenticated successfully",self.loginTextField.stringValue);

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
    
    if (self.rememberMeCheckBox.state == NSOnState)
    {
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:REMEMBER_ME];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.loginTextField.stringValue forKey:@"username"];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.paswordTextField.stringValue forKey:@"password"];
        
        long userId = [AppPreferences sharedAppPreferences].loggedInUser.userId;
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",userId] forKey:@"userId"];
        
        NSString* macId = [self getFinalMacId];
        
        [[NSUserDefaults standardUserDefaults] setObject:macId forKey:@"macId"];
        
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:REMEMBER_ME];
        
    }
//    NSWindowController* wc = [self.storyboard instantiateControllerWithIdentifier:@"MainWindow"];
    
    NSWindowController* wc = [[NSWindowController alloc] initWithWindow:self.view.window];
    
    
    
//    AppDelegate* appDelegate = (AppDelegate*)[NSApplication sharedApplication].delegate;

//    NSWindowController* wc = appDelegate.windowController;

    wc.contentViewController = hvc;

//    [wc.window makeKeyAndOrderFront:hvc];

//    [wc showWindow:[NSApplication sharedApplication].keyWindow];
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

//     [self bookmark];
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
    [self submitUserValidate];

}

-(void)submitUserValidate
{
    NSRange whiteSpaceInUsername = [self.loginTextField.stringValue rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSRange whiteSpaceInPassword = [self.paswordTextField.stringValue rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if([self.loginTextField.stringValue length] == 0 || whiteSpaceInUsername.location != NSNotFound)
    {
        [[AppPreferences sharedAppPreferences] showAlertWithTitle:@"Alert" subTitle:@"Please enter Login Id."];
        
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
        
//        NSLog(@"macId is %@",macId);
        if ([[AppPreferences sharedAppPreferences] isReachable])
        {
      
            hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            // ---> hud text is shown
            hud.frame = CGRectMake(0, 0, 120, 143);
            
            [hud setDetailsLabelText:@"Logging In, please wait"];

//            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
                 [[APIManager sharedManager] updateDeviceMacID:macId password:self.paswordTextField.stringValue username:self.loginTextField.stringValue];
                
//            });

          
            
           
        }
        else
        {
                
            [[AppPreferences sharedAppPreferences] showAlertWithTitle:@"Alert" subTitle:@"Please check your internet connection."];
            
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NO_INTERNET object:nil];

        }
        
    }
    

}

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

//-(void)changeStatusOfDocFiles
//{
////    653052
////    653051
////    653050
////    653049
////    653048
////    653047
////    653046
//    NSArray * array = [[NSArray alloc] initWithObjects:@"653052",@"653051",@"653050",@"653049",@"653048",@"653047",@"653046", nil];
//
//    for (int i = 0; i < array.count; i++)
//    {
//        [[APIManager sharedManager] updateDownloadFileStatus:@"9" dictationId:[array objectAtIndex:i]];
//    }
////    [APIManager sharedManager] updateDownloadFileStatus:@"9" dictationId:<#(NSString *)#>
//}

//- (IBAction)changeStatusButtonClicked:(id)sender
//{
//    [self changeStatusOfDocFiles];
//}
- (BOOL)window:(NSWindow *)window shouldPopUpDocumentPathMenu:(NSMenu *)menu
{
    return NO;
}

//-(void)bookmark
//{
//    openDlg = [NSOpenPanel openPanel];
//    [openDlg setCanChooseDirectories:YES];
//    [openDlg setCanCreateDirectories:YES];
//    [openDlg setAllowsMultipleSelection:FALSE];
//    if ( [openDlg runModal] == NSModalResponseOK )
//    {
//        NSURL *url = openDlg.URL;
//        
//        NSError *error = nil;
//        NSData *bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope
//                         includingResourceValuesForKeys:nil
//                                          relativeToURL:nil
//                                                  error:&error];
//        if (bookmark != nil)
//        {
//            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//            [userDefaults setObject:bookmark forKey:@"bookmark"];
//            [userDefaults synchronize];
//            
//           NSData* bookmarkData = [userDefaults objectForKey:@"bookmark"];
//            NSURL* urlFromBookmark = [NSURL URLByResolvingBookmarkData:bookmarkData
//                                                        options:NSURLBookmarkResolutionWithSecurityScope
//                                                  relativeToURL:nil
//                                            bookmarkDataIsStale:nil
//                                                          error:&error];
//            
//            NSLog(@"url = %@", urlFromBookmark);
//        }
//        else
//        {
//            //check the error
//        }
//    
//        
//    }
//}
@end

