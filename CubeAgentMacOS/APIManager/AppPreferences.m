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
#import "Constants.h"


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
        self.totalUploadedCount = 0;
        self.audioUploadQueue = [[NSOperationQueue alloc] init];
        self.docDownloadQueue = [[NSOperationQueue alloc] init];

        self.nextBlockToBeUploadPoolArray = [NSMutableArray new];
        self.progressCountFileNameDict = [NSMutableDictionary new];
        
        self.nextBlockToBeDownloadPoolArray = [NSMutableArray new];

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

//-(NSString*)getCubeFilesDirectoryPath
//{
//    NSString* documentsDirectoryPath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//
//    NSString *pathToCubeFiles = [NSString stringWithFormat:@"%@/CubeFiles", documentsDirectoryPath];
//    
//    NSError* error;
//    
//    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToCubeFiles])
//        {
//            [[NSFileManager defaultManager] createDirectoryAtPath:pathToCubeFiles withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
//            NSLog(@"");
//        }
//    
//    return pathToCubeFiles;
//}

-(NSString*)getCubeLogDirectoryPath
{
    NSString* documentsDirectoryPath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

    NSString *pathToCubeLogFiles = [NSString stringWithFormat:@"%@/CubeFiles/CubeLog", documentsDirectoryPath];
  
//      [self startScope];
    
//    NSString* cubeFilesFolderPath = [self getCubeFilesFolderPathUsingBookmark];
//
//    NSString *pathToCubeLogFiles = [NSString stringWithFormat:@"%@/CubeLog", cubeFilesFolderPath];

    NSError* error;
    
//    NSURL* downloadsFolderUrl = [[NSFileManager defaultManager] URLForDirectory:NSDownloadsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:false error:&error];
//
//    NSURL* url = [downloadsFolderUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"CubeFiles/CubeLog"]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToCubeLogFiles])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:pathToCubeLogFiles withIntermediateDirectories:YES attributes:nil error:&error]; //Create folder
        NSLog(@"");
    }
    
//     [self stopScope];
    
    return pathToCubeLogFiles;
}

-(NSString*)getCubeTempDirectoryPath
{
//    NSString* documentsDirectoryPath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//
//    NSString *pathToCubeFiles = [NSString stringWithFormat:@"%@/CubeFiles/CubeTemp", documentsDirectoryPath];
//      [self startScope];
//
    NSString* cubeFilesFolderPath = [self getCubeFilesFolderPathUsingBookmark];

    NSString *pathToCubeTempFiles = [NSString stringWithFormat:@"%@/CubeTemp", cubeFilesFolderPath];

    NSError* error;
    
    [self startScope];
//    NSURL* downloadsFolderUrl = [[NSFileManager defaultManager] URLForDirectory:NSDownloadsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:false error:&error];
//
//    NSURL* url = [downloadsFolderUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"CubeFiles/CubeTemp"]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToCubeTempFiles])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:pathToCubeTempFiles withIntermediateDirectories:YES attributes:nil error:&error]; //Create folder
        NSLog(@"");
    }
    
     [self stopScope];
    
    return pathToCubeTempFiles;
}

-(NSString*)getUsernameBacupAudioDirectoryPath
{
      [self startScope];
    
    NSString* cubeFilesFolderPath = [self getCubeFilesFolderPathUsingBookmark];

//    NSString* documentsDirectoryPath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
//    NSString *pathToCubeFiles = [NSString stringWithFormat:@"%@/CubeFiles/%@/BackupAudio", documentsDirectoryPath,[AppPreferences sharedAppPreferences].loggedInUser.userName];
    NSString *pathToCubeBackUpFiles = [NSString stringWithFormat:@"%@/%@/BackupAudio", cubeFilesFolderPath,[AppPreferences sharedAppPreferences].loggedInUser.userName];

    NSError* error;
    
    
//    NSURL* downloadsFolderUrl = [[NSFileManager defaultManager] URLForDirectory:NSDownloadsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:false error:&error];
    
//    NSURL* url = [downloadsFolderUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"CubeFiles/%@/BackupAudio",[AppPreferences sharedAppPreferences].loggedInUser.userName]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToCubeBackUpFiles])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:pathToCubeBackUpFiles withIntermediateDirectories:YES attributes:nil error:&error]; //Create folder
        NSLog(@"");
    }
    
     [self stopScope];
    return pathToCubeBackUpFiles;
}

-(NSString*)getUsernameTranscriptionDirectoryPath
{
     [self startScope];
    
    NSString* cubeFilesFolderPath = [self getCubeFilesFolderPathUsingBookmark];

//    NSString* documentsDirectoryPath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//
//    NSString *pathToCubeFiles = [NSString stringWithFormat:@"%@/CubeFiles/%@/Transcription", documentsDirectoryPath,[AppPreferences sharedAppPreferences].loggedInUser.userName];
    
    NSString *pathToCubeTransFiles = [NSString stringWithFormat:@"%@/%@/Transcription", cubeFilesFolderPath,[AppPreferences sharedAppPreferences].loggedInUser.userName];
    NSError* error;

//    NSURL* downloadsFolderUrl = [[NSFileManager defaultManager] URLForDirectory:NSDownloadsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:false error:&error];
//
//    NSURL* url = [downloadsFolderUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"CubeFiles/%@/Transcription",[AppPreferences sharedAppPreferences].loggedInUser.userName]];
//
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToCubeTransFiles])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:pathToCubeTransFiles withIntermediateDirectories:YES attributes:nil error:&error]; //Create folder
        NSLog(@"");
    }
    
     [self stopScope];
    
    return pathToCubeTransFiles;
}

-(void)createAllFolderOnce
{
    [self getCubeLogDirectoryPath];
    
    [self getCubeTempDirectoryPath];
    
    [self getUsernameUploadAudioDirectoryPath];
    
    [self getUsernameBacupAudioDirectoryPath];
    
    [self getUsernameTranscriptionDirectoryPath];
    
}
-(NSString*)getUsernameUploadAudioDirectoryPath
{
    [self startScope];
    NSError* error;

    NSString* cubeFilesFolderPath = [self getCubeFilesFolderPathUsingBookmark];

    NSString *pathToCubeFiles = [NSString stringWithFormat:@"%@/%@/UploadAudio", cubeFilesFolderPath,[AppPreferences sharedAppPreferences].loggedInUser.userName];

//    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
//    NSURL* downloadsFolderUrl = [[NSFileManager defaultManager] URLForDirectory:NSDownloadsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:false error:&error];
//
//    NSURL* url = [downloadsFolderUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"CubeFiles/%@/UploadAudio",[AppPreferences sharedAppPreferences].loggedInUser.userName]];
    //    NSString* documentsDirectoryPath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    //    NSString *pathToCubeFiles = [NSString stringWithFormat:@"%@/CubeFiles/%@/UploadAudio", documentsDirectoryPath,[AppPreferences sharedAppPreferences].loggedInUser.userName];
    
//    NSString *pathToCubeFiles = [NSString stringWithFormat:@"/Users/%@/Documents/CubeFiles", NSUserName()];

//    NSURL* url = [NSURL fileURLWithPath:pathToCubeFiles];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToCubeFiles])
    {
       BOOL created =  [[NSFileManager defaultManager] createDirectoryAtPath:pathToCubeFiles withIntermediateDirectories:true attributes:nil error:&error]; //Create folder
        NSLog(@"");
    }
    
     [self stopScope];
    
    return pathToCubeFiles;
}

//-(NSString*)getUsernameInregrationDirectoryPath
//{
//    NSString* documentsDirectoryPath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//
//    NSString *pathToCubeFiles = [NSString stringWithFormat:@"%@/CubeFiles/%@/Integration", documentsDirectoryPath,[AppPreferences sharedAppPreferences].loggedInUser.userName];
//
//    NSError* error;
//    
//    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToCubeFiles])
//    {
//        [[NSFileManager defaultManager] createDirectoryAtPath:pathToCubeFiles withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
//        NSLog(@"");
//    }
//    
//    return pathToCubeFiles;
//}

-(void)deleteFileAtPath:(NSString*)filePath
{
    
//    NSString* documentsDirectoryPath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//
//    NSString *pathToCubeFiles = [NSString stringWithFormat:@"%@/CubeFiles/CubeTemp", documentsDirectoryPath];
      [self startScope];
    
    NSError* error;

    NSString* cubeFilesFolderPath = [self getCubeFilesFolderPathUsingBookmark];
//    NSURL* downloadsFolderUrl = [[NSFileManager defaultManager] URLForDirectory:NSDownloadsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:false error:&error];
//
//    NSURL* url = [downloadsFolderUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"CubeFiles/CubeTemp"]];
    
    NSString *pathToCubeTempFiles = [NSString stringWithFormat:@"%@/CubeTemp", cubeFilesFolderPath];
    
//    NSString *pathToCubeTempFiles = url.path;
    
    NSString* fileName = [filePath lastPathComponent];
    
    pathToCubeTempFiles = [[pathToCubeTempFiles stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"fcfe"];
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathToCubeTempFiles])
    {
        bool isRemoved = [[NSFileManager defaultManager] removeItemAtPath:pathToCubeTempFiles error:&error];
        
        NSLog(@"%d", isRemoved);
    }
    
      [self stopScope];
}

-(void)moveAudioFileToBackup:(NSString*)filePath
{
   
    
    NSString *pathToBackUpFiles = [self getDateWiseBackUpAudioFolderPath];
    
     [self startScope];
    
    pathToBackUpFiles = [pathToBackUpFiles stringByAppendingPathComponent:[filePath lastPathComponent]];

    NSError* error;

    if ([[NSFileManager defaultManager] fileExistsAtPath:pathToBackUpFiles])
    {
        bool isRemoved = [[NSFileManager defaultManager] removeItemAtPath:pathToBackUpFiles error:&error];

    }

   bool isMoved = [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:pathToBackUpFiles error:&error];
    
    if(isMoved)
    {
        DDLogInfo(@"Audio file moved to BackupAudio folder");
    }
    NSLog(@"ismoved"); 
    
     [self stopScope];
}

-(void)moveDuplicateAudioFileToGivenDateBackup:(NSString*)dateFolderName filePath:(NSString*)filePath
{
    
    
    NSString *pathToBackUpFiles = [self getGivenDateBackUpAudioFolderPath:dateFolderName];
   
//    [self startScope];
    
    pathToBackUpFiles = [pathToBackUpFiles stringByAppendingPathComponent:[filePath lastPathComponent]];
    
   
    NSError* error;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathToBackUpFiles])
    {
        NSString* pathExtension = [pathToBackUpFiles pathExtension];
        
        pathToBackUpFiles = [pathToBackUpFiles stringByDeletingPathExtension];
        
//        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        // NSTimeInterval is defined as double
//        NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
       NSString* timeStampObj = [self getTimestampForFileName];
        
        pathToBackUpFiles = [pathToBackUpFiles stringByAppendingString:[NSString stringWithFormat:@"_CopiedOn_%@",timeStampObj]];
        
        pathToBackUpFiles = [pathToBackUpFiles stringByAppendingPathExtension:pathExtension];
//        bool isRemoved = [[NSFileManager defaultManager] removeItemAtPath:pathToBackUpFiles error:&error];
        
    }
    
    bool isMoved = [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:pathToBackUpFiles error:&error];
    
    if(isMoved)
    {
        DDLogInfo(@"Audio file moved to BackupAudio folder");
    }
    NSLog(@"ismoved");
    
//     [self stopScope];
    
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

-(NSString *)getTimestamp
{
    static dispatch_once_t onceToken;
    static NSDateFormatter *dateFormatter;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        // ---> setting date format as ddmmyy for BackupAudio date folder.
         [dateFormatter setDateFormat:@"ddMMyy"];
        
        //        [dateFormatter setDateFormat:@"YYYY.MM.dd-HH.mm.ss"];
    });

    return [dateFormatter stringFromDate:NSDate.date];
}

-(NSString*)getDateWiseBackUpAudioFolderPath
{

    
    NSString* todaysDate = [self getTimestamp];
    
    NSString* backDirectoryPath = [self getUsernameBacupAudioDirectoryPath];
    
        [self startScope];
    
    NSString* backUpDatewiseFolderPath = [backDirectoryPath stringByAppendingPathComponent:todaysDate];
    
    NSError* error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:backUpDatewiseFolderPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:backUpDatewiseFolderPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        NSLog(@"");
    }
    
     [self stopScope];
    return backUpDatewiseFolderPath;
}

-(NSString*)getGivenDateBackUpAudioFolderPath:(NSString*)uploadedAudioDate
{
//    NSString* todaysDate = [self getTimestamp];
   
    
    NSString* backDirectoryPath = [self getUsernameBacupAudioDirectoryPath];
    
     [self startScope];
    
    NSString* backUpDatewiseFolderPath = [backDirectoryPath stringByAppendingPathComponent:uploadedAudioDate];
    
    NSError* error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:backUpDatewiseFolderPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:backUpDatewiseFolderPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        NSLog(@"");
    }
    
    [self stopScope];
    
    return backUpDatewiseFolderPath;
}

-(NSString*)getGivenDateTranscriptionFolderPath:(NSString*)uploadedAudioDate
{
//    NSString* todaysDate = [self getTimestamp];
    
     [self startScope];
    NSString* transDirectoryPath = [self getUsernameTranscriptionDirectoryPath];
    
    NSString* transDatewiseFolderPath = [transDirectoryPath stringByAppendingPathComponent:uploadedAudioDate];
    
    NSError* error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:transDatewiseFolderPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:transDatewiseFolderPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        NSLog(@"");
    }
    
     [self stopScope];
    return transDatewiseFolderPath;
}
/*=================================================================================================================================================*/


- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

-(void)showAlertWithTitle:(NSString*)title subTitle:(NSString*)subTitle
{
   
    if (alert != nil)
    {
        [NSApp endSheet:[alert window]];

    }
    
    alert   = [[NSAlert alloc] init];
    [alert setMessageText:title];
    [alert setInformativeText:subTitle];
    [alert addButtonWithTitle:@"OK"];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertSecondButtonReturn) {
            return;
        }
    }];
//
//    [alert runModal];
}


-(void)addLoggerOnce
{
    BOOL isCubeFilesFolderGenerated = [[NSUserDefaults standardUserDefaults] boolForKey:DOWNLOAD_FOLDER_BOOKMARK_GENERATED];

    if (isCubeFilesFolderGenerated)
    {
        NSString* cubeFilesFolderPath = [self getCubeFilesFolderPathUsingBookmark];
        
        
        NSString *pathToCubeLogFiles = [NSString stringWithFormat:@"%@/CubeLog", cubeFilesFolderPath];
        
        // && ![[NSFileManager defaultManager] fileExistsAtPath:pathToCubeLogFiles]
        if (!self.isLoggerAdded)
        {
            [DDLog addLogger:[DDTTYLogger sharedInstance]];
            
            NSString* logDirectoryPath = [[AppPreferences sharedAppPreferences] getCubeLogDirectoryPath];
            
            [[AppPreferences sharedAppPreferences] startScope];

            DDLogFileManagerDefault* logManager = [[BaseLogFileManager alloc] initWithLogsDirectory:logDirectoryPath];
            
            DDFileLogger * file = [[DDFileLogger alloc] initWithLogFileManager:logManager];
            
            [DDLog addLogger:file];
            
            self.isLoggerAdded = true;
            
            [[AppPreferences sharedAppPreferences] stopScope];

        }
     
    }
  
}

-(NSString *)getTimestampForFileName
{
//    static dispatch_once_t onceToken;
    static NSDateFormatter *dateFormatter;
//    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        // ---> setting date format as ddmmyy for BackupAudio date folder.
        [dateFormatter setDateFormat:@"dd-MM-yy HH-mm-ss"];
        
        //        [dateFormatter setDateFormat:@"YYYY.MM.dd-HH.mm.ss"];
//    });
    
    return [dateFormatter stringFromDate:NSDate.date];
}

-(NSString*)getCubeFilesFolderPathUsingBookmark
{
    NSData* bookmarkData = [[NSUserDefaults standardUserDefaults] objectForKey:DOWNLOAD_FOLDER_BOOKMARK_PATH];
    NSURL* urlFromBookmark = [NSURL URLByResolvingBookmarkData:bookmarkData
                                                       options:NSURLBookmarkResolutionWithSecurityScope
                                                 relativeToURL:nil
                                           bookmarkDataIsStale:nil
                                                         error:nil];
    
//     NSString* documentsDirectoryPath = @"/Users/admin/Library/Containers/com.xanadutec.CubeAgentMacOS/Data/Downloads";
    NSString* documentsDirectoryPath = urlFromBookmark.path;
    
    return documentsDirectoryPath;
}

-(void)startScope
{
    NSData* bookmarkData = [[NSUserDefaults standardUserDefaults] objectForKey:DOWNLOAD_FOLDER_BOOKMARK_PATH];
    
    BOOL isStale;
    NSError* error;
    NSURL* saveFolder = [NSURL URLByResolvingBookmarkData:bookmarkData
                                                  options:NSURLBookmarkResolutionWithSecurityScope
                                            relativeToURL:nil
                                      bookmarkDataIsStale:&isStale
                                                    error:&error];
    
   [saveFolder startAccessingSecurityScopedResource];
//    bool is1 =  [saveFolder startAccessingSecurityScopedResource];

    
}

-(void)stopScope
{
    NSData* bookmarkData = [[NSUserDefaults standardUserDefaults] objectForKey:DOWNLOAD_FOLDER_BOOKMARK_PATH];
    
    BOOL isStale;
    NSError* error;
    NSURL* saveFolder = [NSURL URLByResolvingBookmarkData:bookmarkData
                                                  options:NSURLBookmarkResolutionWithSecurityScope
                                            relativeToURL:nil
                                      bookmarkDataIsStale:&isStale
                                                    error:&error];
    
    [saveFolder stopAccessingSecurityScopedResource];
    
}
@end
