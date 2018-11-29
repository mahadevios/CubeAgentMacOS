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
    //setting background color for submit button
//    self.submitButton.layer.backgroundColor = NSColor.redColor.CGColor;

//    NSString*  macId=[Keychain getStringForKey:@"udid"];
    
    
    //    NSLog(@"doKeyForPassword: %@",key);
    //    [[APIManager sharedManager] checkAPI];
    
    //    [[APIManager sharedManager] authenticateUserMacIDLocal:@"DDCF3B2D-362B-4C81-8AB3-DD56D49E5365" password:@"d" username:@"SAN"];
    //6DBC967F-3C38-46C9-BE74-DF3588C77475
//    4DE5E8E1-4764-566D-8C35-AC3F7C5A447D --uuid
//    NSUUID* uid = [NSUUID UUID];
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
    
    NSError* error;
    
    NSString *pathToDesktop = [NSString stringWithFormat:@"/Users/%@/Documents/UploadFiles", NSUserName()];

    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToDesktop])
    {
        BOOL isCreated = [[NSFileManager defaultManager] createDirectoryAtPath:pathToDesktop withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        NSLog(@"");
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateMacIDResponse:) name:NOTIFICATION_UPDATE_MAC_ID_API
                                               object:nil];
    

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

- (NSString *)getMACUUID
{
    io_service_t    platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,

                                                                 IOServiceMatching("IOPlatformExpertDevice"));
    CFStringRef serialNumberAsCFString = NULL;

//    kIOPlatformUUIDKey
//    kIOPlatformSerialNumberKey
    if (platformExpert) {
        serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,
                                                                 CFSTR(kIOPlatformSerialNumberKey),
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


- (IBAction)autoModeCheckBoxClicked:(id)sender {
}
- (IBAction)rememberMeCheckBoxClicked:(id)sender {
}
- (IBAction)submitButtonClicked:(id)sender {
}
@end
