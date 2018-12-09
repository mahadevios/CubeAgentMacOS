//
//  AppPreferences.m
//  Communicator
//
//  Created by mac on 05/04/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "AppPreferences.h"
#include <sys/xattr.h>
#import "AppDelegate.h"


@implementation AppPreferences
@synthesize currentSelectedItem;
@synthesize alertDelegate;
@synthesize isReachable;

static AppPreferences *singleton = nil;

// Shared method
+(AppPreferences *) sharedAppPreferences
{
    if (singleton == nil)
    {
        singleton = [[AppPreferences alloc] init];
    }
    
    return singleton;
}


// Init method
-(id) init
{
    self = [super init];
    
    if (self)
    {
        self.currentSelectedItem = 0;
        self.totalUploadedCount = 1;
        self.audioUploadQueue = [[NSOperationQueue alloc] init];
        
        self.nextToBeUploadedPoolArray = [NSMutableArray new];
        //[self startReachabilityNotifier];
    }
    
    return self;
}


/*================================================================================================================================================*/


//-(void) startReachabilityNotifier
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(reachabilityChanged:)
//                                                 name:kReachabilityChangedNotification
//                                               object:nil];
//
//    Reachability * reach = [Reachability reachabilityWithHostname:@"www.google.com"];
//
//    reach.reachableBlock = ^(Reachability * reachability)
//    {
//        dispatch_async(dispatch_get_main_queue(), ^
//                       {
//                           //NSLog(@"Reachable");
//                           isReachable = YES;
//                       });
//    };
//
//    reach.unreachableBlock = ^(Reachability * reachability)
//    {
//        dispatch_async(dispatch_get_main_queue(), ^
//                       {
//                           //NSLog(@"Not Reachable");
//                           isReachable = NO;
//
//                       });
//    };
//
//    [reach startNotifier];
//}
//
///*================================================================================================================================================*/
//
//-(void)reachabilityChanged:(NSNotification*)note
//{
//    Reachability * reach = [note object];
//
//    if([reach isReachable])
//    {
//        //NSLog(@"Reachable");
//        isReachable = YES;
//    }
//    else
//    {
//        //NSLog(@"Not Reachable");
//        isReachable = NO;
//
//        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showNoInternetMessage) userInfo:nil repeats:NO];
//    }
//}


-(void) startReachabilityNotifier
{
    //    self.summaryLabel.hidden = YES;
    
    /*
     Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    //Change the host name here to change the server you want to monitor.
    NSString *remoteHostName = @"www.apple.com";
    NSString *remoteHostLabelFormatString = NSLocalizedString(@"Remote Host: %@", @"Remote host label format string");
    //    self.remoteHostLabel.text = [NSString stringWithFormat:remoteHostLabelFormatString, remoteHostName];
    
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
}

/*================================================================================================================================================*/

- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}


- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    if (reachability == self.hostReachability)
    {
        [self configureTextFieldreachability:reachability];
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        BOOL connectionRequired = [reachability connectionRequired];
        
        //        self.summaryLabel.hidden = (netStatus != ReachableViaWWAN);
        NSString* baseLabelText = @"";
        
        if (connectionRequired)
        {
            baseLabelText = NSLocalizedString(@"Cellular data network is available.\nInternet traffic will be routed through it after a connection is established.", @"Reachability text if a connection is required");
        }
        else
        {
            baseLabelText = NSLocalizedString(@"Cellular data network is active.\nInternet traffic will be routed through it.", @"Reachability text if a connection is not required");
        }
        //        self.summaryLabel.text = baseLabelText;
    }
    
    if (reachability == self.internetReachability)
    {
        [self configureTextFieldreachability:reachability];
    }
    
}


- (void)configureTextFieldreachability:(Reachability *)reachability
{
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    BOOL connectionRequired = [reachability connectionRequired];
    NSString* statusString = @"";
    
    switch (netStatus)
    {
        case NotReachable:        {
            statusString = NSLocalizedString(@"Access Not Available", @"Text field text for access is not available");
            //            imageView.image = [UIImage imageNamed:@"stop-32.png"] ;
            /*
             Minor interface detail- connectionRequired may return YES even when the host is unreachable. We cover that up here...
             */
            self.isReachable = NO;
            connectionRequired = NO;
            break;
        }
            
        case ReachableViaWWAN:        {
            statusString = NSLocalizedString(@"Reachable WWAN", @"");
            //            imageView.image = [UIImage imageNamed:@"WWAN5.png"];
            self.isReachable = YES;
            break;
        }
        case ReachableViaWiFi:        {
            statusString= NSLocalizedString(@"Reachable WiFi", @"");
            //            imageView.image = [UIImage imageNamed:@"Airport.png"];
            self.isReachable = YES;
            
            break;
        }
    }
    
    if (connectionRequired)
    {
        NSString *connectionRequiredFormatString = NSLocalizedString(@"%@, Connection Required", @"Concatenation of status string with connection requirement");
        statusString= [NSString stringWithFormat:connectionRequiredFormatString, statusString];
    }
    //    textField.text= statusString;
}
-(void) showNoInternetMessage
{
//    if (![self isReachable])
//    {
//        [self showAlertViewWithTitle:@"No internet connection" withMessage:@"Please turn on your inernet connection to access this feature" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
//    }
}

-(NSString*)getCubeFilesDirectoryPath
{
    NSString* documentsDirectoryPath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

    NSString *pathToCubeFiles = [NSString stringWithFormat:@"%@/CubeFiles", documentsDirectoryPath];
    
    NSError* error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToCubeFiles])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:pathToCubeFiles withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
            NSLog(@"");
        }
    
    return pathToCubeFiles;
}

-(NSString*)getCubeLogDirectoryPath
{
    NSString* documentsDirectoryPath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSString *pathToCubeFiles = [NSString stringWithFormat:@"%@/CubeFiles/CubeLog", documentsDirectoryPath];
  
    NSError* error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToCubeFiles])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:pathToCubeFiles withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        NSLog(@"");
    }
    
    return pathToCubeFiles;
}

-(NSString*)getCubeTempDirectoryPath
{
    NSString* documentsDirectoryPath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSString *pathToCubeFiles = [NSString stringWithFormat:@"%@/CubeFiles/CubeTemp", documentsDirectoryPath];
    
   
    NSError* error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToCubeFiles])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:pathToCubeFiles withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        NSLog(@"");
    }
    
    return pathToCubeFiles;
}

-(NSString*)getUsernameBacupAudioDirectoryPath
{
    
    NSString* documentsDirectoryPath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSString *pathToCubeFiles = [NSString stringWithFormat:@"%@/CubeFiles/%@/BackupAudio", documentsDirectoryPath,[AppPreferences sharedAppPreferences].loggedInUser.userName];
    
    NSError* error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToCubeFiles])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:pathToCubeFiles withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        NSLog(@"");
    }
    
    return pathToCubeFiles;
}

-(NSString*)getUsernameTranscriptionDirectoryPath
{
    NSString* documentsDirectoryPath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSString *pathToCubeFiles = [NSString stringWithFormat:@"%@/CubeFiles/%@/Transcription", documentsDirectoryPath,[AppPreferences sharedAppPreferences].loggedInUser.userName];
    
    
    NSError* error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToCubeFiles])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:pathToCubeFiles withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        NSLog(@"");
    }
    
    return pathToCubeFiles;
}

-(NSString*)getUsernameUploadAudioDirectoryPath
{
    NSString* documentsDirectoryPath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

    NSString *pathToCubeFiles = [NSString stringWithFormat:@"%@/CubeFiles/%@/UploadAudio", documentsDirectoryPath,[AppPreferences sharedAppPreferences].loggedInUser.userName];
    
//    NSString *pathToCubeFiles = [NSString stringWithFormat:@"/Users/%@/Documents/CubeFiles", NSUserName()];

    NSURL* url = [NSURL fileURLWithPath:pathToCubeFiles];
    NSError* error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:url.relativePath])
    {
       BOOL created =  [[NSFileManager defaultManager] createDirectoryAtPath:pathToCubeFiles withIntermediateDirectories:true attributes:nil error:&error]; //Create folder
        NSLog(@"");
    }
    
    return pathToCubeFiles;
}

-(NSString*)getUsernameInregrationDirectoryPath
{
    NSString* documentsDirectoryPath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSString *pathToCubeFiles = [NSString stringWithFormat:@"%@/CubeFiles/%@/Integration", documentsDirectoryPath,[AppPreferences sharedAppPreferences].loggedInUser.userName];
    
    NSError* error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToCubeFiles])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:pathToCubeFiles withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        NSLog(@"");
    }
    
    return pathToCubeFiles;
}

-(void)deleteFileAtPath:(NSString*)filePath
{
    NSString* documentsDirectoryPath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSString *pathToCubeFiles = [NSString stringWithFormat:@"%@/CubeFiles/CubeTemp", documentsDirectoryPath];
    
    NSString* fileName = [filePath lastPathComponent];
    
    pathToCubeFiles = [[pathToCubeFiles stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"fcfe"];
    
    NSError* error;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathToCubeFiles])
    {
        bool isRemoved = [[NSFileManager defaultManager] removeItemAtPath:pathToCubeFiles error:&error];
        
        NSLog(@"%d", isRemoved);
    }
    
}

-(void)moveAudioFileToBackup:(NSString*)filePath
{
    
    NSString* documentsDirectoryPath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSString* fileName = [filePath lastPathComponent];

    NSString *pathToBackUpFiles = [self getUsernameBacupAudioDirectoryPath];
    
     NSString *pathToCubeFiles = [self getUsernameUploadAudioDirectoryPath];
    
    pathToCubeFiles = [pathToCubeFiles stringByAppendingPathComponent:fileName];
    
    pathToBackUpFiles = [pathToBackUpFiles stringByAppendingPathComponent:fileName];

    NSError* error;

    if ([[NSFileManager defaultManager] fileExistsAtPath:pathToBackUpFiles])
    {
        bool isRemoved = [[NSFileManager defaultManager] removeItemAtPath:pathToBackUpFiles error:&error];

    }

   bool isMoved = [[NSFileManager defaultManager] moveItemAtPath:pathToCubeFiles toPath:pathToBackUpFiles error:&error];
    
    NSLog(@"ismoved"); 
    
}

-(uint64_t)getFileSize:(NSString*)filePath
{
    uint64_t totalSpace = 0;
    //    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath  error:&error];
    
    if (dictionary)
    {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSize];
        
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        
    }
    else
    {
        // NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalSpace;
}


/*=================================================================================================================================================*/

-(void) showHudWithTitle:(NSString*)title detailText:(NSString*)detailText
{
//    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:true];
//
//    hud.tag = 789;
//
//    hud.minSize = CGSizeMake(150.0, 100.0);
//
//    hud.label.text = title;
//
//    hud.detailsLabel.text = detailText;
}


//-(void) showAlertViewWithTitle:(NSString *) title withMessage:(NSString *) message withCancelText:(NSString *) cancelText withOkText:(NSString *) okText withAlertTag:(int) tag
//{
//    
//    dispatch_queue_t currentQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(currentQueue, ^
//                   {
//                       __block UIAlertView *alertView  = nil;
//                       
//                       dispatch_sync(currentQueue, ^
//                                     {
//                                         dispatch_async(dispatch_get_main_queue(), ^{
//                                             alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelText otherButtonTitles:okText, nil];
//                                             alertView.tag = tag;
//                                         });
//                                        
//                                         
//                                     });
//                       
//                       dispatch_sync(dispatch_get_main_queue(), ^
//                                     {
//                                         [alertView show];
//
//                                     });
//                   });
//}
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    [self.alertDelegate appPreferencesAlertButtonWithIndex:(int)buttonIndex withAlertTag:alertView.tag];
//}



- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}








@end
