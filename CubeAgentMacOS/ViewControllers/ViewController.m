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

@implementation ViewController

- (void)viewDidLoad
{
    //changes from martina
    [super viewDidLoad];
 
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
    

    [[APIManager sharedManager] updateDeviceMacID:uuidOfMac password:@"d" username:@"SAN"];
    
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
    
   
    
    NSLog(@"home = %@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]);
    
    NSString* filePath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSURL* fileURL1 = [NSURL fileURLWithPath:filePath];
    
    NSArray *fileURLs = [NSArray arrayWithObjects:fileURL1 ,nil];
    
//    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
    
//    NSURL *fileURL = [NSURL fileURLWithPath: filePath];
//    NSURL *fileURL = [savePanel URL];
//    NSURL *folderURL = [fileURL URLByDeletingLastPathComponent];
    
    NSWorkspace * workSpace = [NSWorkspace sharedWorkspace];
    
    NSString* str;
    
//    [workSpace type:str conformsToType:@""];
    
        [workSpace activateFileViewerSelectingURLs:fileURLs];

//    [workSpace openURL: folderURL];
//    NSLog(@"home directory = %@", )
//    [self getDirectory];
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

-(void)validateMacIDResponse:(NSNotification*)dictObj
{
    NSDictionary* responseDict = dictObj.object;
    
    NSString* responseCodeString =  [responseDict valueForKey:RESPONSE_CODE];
    
    NSString* macIdValidString =  [responseDict valueForKey:RESPONSE_IS_MAC_ID_VALID];

    if ([responseCodeString  isEqualToString: @"200"] && [macIdValidString isEqualToString:SUCCESS])
    {
        [[APIManager sharedManager] authenticateUser:@"d" username:@"SAN"];

    }
}

-(void)validateAuthenticateUserResponse:(NSNotification*)dictObj
{
    NSDictionary* responseDict = dictObj.object;
    
    NSString* responseCodeString =  [responseDict valueForKey:RESPONSE_CODE];
    
    NSString* userIdString =  [responseDict valueForKey:@"userIdString"];
    
    if ([responseCodeString  isEqualToString: @"200"] && ![userIdString isEqualToString:@"0"])
    {
        User* user = [[User alloc] init];
        
        user.userId = [userIdString longLongValue];
        
        [AppPreferences sharedAppPreferences].loggedInUser = user;
        
        [[APIManager sharedManager] getCubeConfig:userIdString];
        
    }
}

-(void)validateCubeConfigResponse:(NSNotification*)dictObj
{
    NSDictionary* responseDict = dictObj.object;
    
//    NSString* responseCodeString =  [responseDict valueForKey:RESPONSE_CODE];
    
//    NSString* userIdString =  [responseDict valueForKey:@"userIdString"];
    
//    if ([responseCodeString  isEqualToString: @"200"])
//    {
    
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
        
        [[APIManager sharedManager] getAudioFileExtensions];
        
//    }
}

-(void)validateAudioFileExtResponse:(NSNotification*)dictObj
{
    NSString* responseString = dictObj.object;
    
    NSMutableArray* supportedAudioFormatArray = [responseString componentsSeparatedByString:@","];
    
    [supportedAudioFormatArray removeObject:@""];
    
    [AppPreferences sharedAppPreferences].supportedAudioFileExtensions = supportedAudioFormatArray;
    
    int parentCompanyId = [AppPreferences sharedAppPreferences].cubeConfig.ParentCompanyID;
    
    [[APIManager sharedManager] getTransCompanyName:[NSString stringWithFormat:@"%d",parentCompanyId]];
    
        
    
}

-(void)validateTransCompName:(NSNotification*)dictObj
{
    NSString* transCompanyName = dictObj.object;
    
    [AppPreferences sharedAppPreferences].transCompanyName = transCompanyName;
    
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


- (IBAction)autoModeCheckBoxClicked:(id)sender {
}
- (IBAction)rememberMeCheckBoxClicked:(id)sender {
}
- (IBAction)submitButtonClicked:(id)sender {
}

-(void)getDirectory
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    // changes promt to Select
    [panel setPrompt:@"Select"];
    
    // Enable the selection of files in the dialog.
    [panel setCanChooseFiles:YES];
    
    // Enable the selection of directories in the dialog.
    [panel setCanChooseDirectories:YES];
    
    //allows multi select
    [panel setAllowsMultipleSelection:NO];
    
    NSString *pathToDownloads = [NSString stringWithFormat:@"/Users/%@/Documents", NSUserName()];
    
    //    if(exists){
    [panel setDirectoryURL:[NSURL fileURLWithPath:pathToDownloads]];
    //    }
    
    [panel beginSheetModalForWindow:[NSApplication sharedApplication].mainWindow
                  completionHandler:^(NSInteger returnCode) {
                      if (returnCode == NSModalResponseOK)
                      {
                          NSURL *theURL = [[panel URLs] objectAtIndex:0];
                          
                          NSData* data  = [NSData dataWithContentsOfURL:theURL];
                          
                          //                          NSLog(@"%@",data);
                      }}];
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

