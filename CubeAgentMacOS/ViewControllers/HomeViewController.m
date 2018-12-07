//
//  HomeViewController.m
//  CubeAgentMacOS
//
//  Created by Martina Makasare on 11/29/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//
//com.apple.security.temporary-exception.files.home-relative-path.read-write
#import "HomeViewController.h"
#import "APIManager.h"
#import "Constants.h"
#import "AppPreferences.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateSingleQueryReponse:) name:NOTIFICATION_GET_SINGLE_QEURY_EXECUTE_QUERY_API
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateDuplicateFileReponse:) name:NOTIFICATION_CHECK_DUPLICATE_AUDIO_FOR_DAY_API
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateTCIDViewReponse:) name:NOTIFICATION_FTP_GET_TC_ID_VIEW_API
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateVCIDViewReponse:) name:NOTIFICATION_FTP_SET_TCID_VERIFY_API
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateFileUploadReponse:) name:NOTIFICATION_FILE_UPLOAD_API
                                               object:nil];
    
    NSString* StrSQL = [NSString stringWithFormat:@"Select d.DictatorFirstName  + ' ' + d.DictatorLastName as DictatorFullName from Users a inner join Clinics b on a.ParentCompanyID=b.ClinicID INNER JOIN Dictators d on d.DictatorID=a.UserID WHERE a.UserID=%ld",[AppPreferences sharedAppPreferences].loggedInUser.userId];
   
//    NSString *escaped = [StrSQL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//843,770
    [[APIManager sharedManager] setVCID:[NSString stringWithFormat:@"%ld",[AppPreferences sharedAppPreferences].loggedInUser.userId]];
    
    [[APIManager sharedManager] getSingleQueryValueComment:StrSQL];

    [self getFilesToBeUploadFromUploadFilesFolder];

    CGSize size =  CGSizeMake(900, 770);
    self.preferredContentSize = size;

//    [[APIManager sharedManager] getEncryptDecryptString];
}

-(void)validateFileUploadReponse:(NSNotification*)notification
{
    NSDictionary* dict =  notification.object;
    
    NSString* isUploaded = [dict objectForKey:@"isUploaded"];
    
    NSString* audioFilePath = [dict objectForKey:@"audioFileName"];

    if ([isUploaded  isEqual: @"true"])
    {
        [self performCleanUp:audioFilePath];
       
    }
    else
    {
        
    }
}

-(void)performCleanUp:(NSString*)audioFilePath
{
    NSString* audioFileName = [audioFilePath lastPathComponent];

    // delete the encypted file
    [[AppPreferences sharedAppPreferences] deleteFileAtPath:audioFilePath];
    
    // remove object from dictionary
    [listOfAudioFilesToUploadDict removeObjectForKey:audioFileName];
    
    // move file to backup
    [[AppPreferences sharedAppPreferences] moveAudioFileToBackup:audioFilePath];
    
    // if dict.count value is 0 start the upload timer
    if (listOfAudioFilesToUploadDict.count == 0)
    {
        // retsart the timer to upload audio
    }
}

-(void)validateVCIDViewReponse:(NSNotification*)notification
{
    NSDictionary* responseString = notification.object;
    
    NSArray* verifyArray = [responseString valueForKey:@"SetTCID_Verifylist"];

    NSDictionary* verifyDict = [verifyArray objectAtIndex:0];

    
    vcIdList = [[VCIdList alloc] init];
    
//    vcIdList.AutoOutsourceTime =  [[verifyDict valueForKey:@"AutoOutsourceTime"] intValue];
    vcIdList.Inhouse =  [[verifyDict valueForKey:@"Inhouse"] intValue];
    vcIdList.TCID =  [[verifyDict valueForKey:@"TCID"] intValue];
    vcIdList.VCID =  [[verifyDict valueForKey:@"VCID"] intValue];
    vcIdList.verify =  [[verifyDict valueForKey:@"Verify"] boolValue];

    
    NSLog(@"");
}

-(void)validateSingleQueryReponse:(NSNotification*)notification
{

    NSString* responseString = notification.object;
    
    NSLog(@"");
}

-(void)validateDuplicateFileReponse:(NSNotification*)notification
{
    NSDictionary* responseString = notification.object;
    
    NSString* response = [responseString objectForKey:@"response"];
    
    NSString* audioFileName = [responseString objectForKey:@"audioFileName"];

    if ([response isEqualToString:@"No Records"])
    {
        NSString* audioUploadFolderPath = [[AppPreferences sharedAppPreferences] getUsernameUploadAudioDirectoryPath];
        
        NSString* audioFilePath = [audioUploadFolderPath stringByAppendingPathComponent:audioFileName];
        
       uint64_t fileSize = [[AppPreferences sharedAppPreferences] getFileSize:audioFilePath];
        
        if (fileSize > 104857600)
        {
            
        }
        else
        {
            [[APIManager sharedManager] FTPGetTCIdView:[NSString stringWithFormat:@"%ld",[AppPreferences sharedAppPreferences].loggedInUser.userId] originalFileName:audioFileName];
        }
    }
    else
    {
        [self performCleanUp:audioFileName];
        // move audio to backup path
        // remove object and key from dictionary and check if dictioanry count is 0, if yes start the timer to upload next files
    }
    NSLog(@"");
}

-(void)validateTCIDViewReponse:(NSNotification*)notification
{
    NSDictionary* responseString = notification.object;
    
    NSDictionary* responseDict = [responseString objectForKey:@"response"];
    
    NSArray* tcIdListArray = [responseDict objectForKey:@"vwGetTCIDlist"];

    NSDictionary* tcIdListDict = [tcIdListArray objectAtIndex:0];
    
    NSString* audioFileName = [responseString objectForKey:@"audioFileName"];
    
    [[AppPreferences sharedAppPreferences] getUsernameUploadAudioDirectoryPath];
    tcIdList = nil;
    
    tcIdList = [ViewTCIdList new];
    
    tcIdList.ClientName = [tcIdListDict valueForKey:@"ClientName"];
    tcIdList.ClinicName = [[tcIdListDict valueForKey:@"ClinicName"] stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    tcIdList.DictatorFirstName = [tcIdListDict valueForKey:@"DictatorFirstName"];
    tcIdList.DictatorLastName = [tcIdListDict valueForKey:@"DictatorLastName"];
    tcIdList.ParentCompanyID = [[tcIdListDict valueForKey:@"ParentCompanyID"] intValue];
    tcIdList.TCID = [[tcIdListDict valueForKey:@"TCID"] intValue];
    tcIdList.TCName = [[tcIdListDict valueForKey:@"TCName"] stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    tcIdList.UserID = [[tcIdListDict valueForKey:@"UserID"] intValue];
    tcIdList.UserName = [tcIdListDict valueForKey:@"UserName"];
    tcIdList.Verify = [tcIdListDict valueForKey:@"Verify"];
    
    NSString* folderPath = [[AppPreferences sharedAppPreferences] getUsernameUploadAudioDirectoryPath];
    
    NSString* filePath = [folderPath stringByAppendingPathComponent:audioFileName];
    
    queue = [[NSOperationQueue alloc] init];
    
    
    /* Push an expensive computation to the operation queue, and then
     * display the response to the user on the main thread. */
    [queue addOperationWithBlock: ^{
        /* Perform expensive processing with data on our background thread */
        [[APIManager sharedManager] uploadFileAfterGettingdatabaseValues:audioFileName dictatorId:tcIdList.UserID FTPAudioPath:tcIdList.TCName strInHouse:vcIdList.Inhouse clinicName:tcIdList.ClinicName userId:tcIdList.UserID dictatorFirstName:tcIdList.DictatorFirstName tcId:tcIdList.TCID vcId:vcIdList.VCID filePath:filePath];
        
    }];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//
//
//    });
   

}

-(void)openFolderInFinder:(NSString*)folderPath
{
    //    NSString* filePath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSURL* fileURL1 = [NSURL fileURLWithPath:folderPath];
    
    NSArray *fileURLs = [NSArray arrayWithObjects:fileURL1 ,nil];
    
    //    NSLog(@"home = %@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]);
    
    
    NSWorkspace * workSpace = [NSWorkspace sharedWorkspace];
    
    //    [workSpace type:str conformsToType:@""];
    
    [workSpace activateFileViewerSelectingURLs:fileURLs];
}

-(void)getFilesToBeUploadFromUploadFilesFolder
{
//    [AppPreferences sharedAppPreferences].loggedInUser = [User new];
//
//    [AppPreferences sharedAppPreferences].loggedInUser.userName = @"Sanjay";
    
    NSString* filePath =  [[AppPreferences sharedAppPreferences] getUsernameUploadAudioDirectoryPath];
    
    NSError * error;
    
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:&error];
    
   
    NSLog(@"directoryContents ====== %@",directoryContents);
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:&error] ;
    
    NSMutableArray *listOfAudioFiles = [NSMutableArray arrayWithCapacity:0];
    
    // Check for Audios of supported type
    for(NSString *filepath in contents)
    {
        if ([[AppPreferences sharedAppPreferences].supportedAudioFileExtensions containsObject:[filepath pathExtension]])
        {
            // Found Audio File
            [listOfAudioFiles addObject:filepath];
        }
    }

    [self getAllFiles:filePath];
}

-(void)getAllFiles:(NSString*)documentsDir
{
    NSFileManager *fileMgr;
    NSString *entry;
    NSDirectoryEnumerator *enumerator;
    BOOL isDirectory;
    
    fileMgr = [NSFileManager defaultManager];
    
    [fileMgr changeCurrentDirectoryPath:documentsDir];
    
    // Enumerator for docs directory
    enumerator = [fileMgr enumeratorAtPath:documentsDir];
    
    NSMutableArray *contents = [NSMutableArray new] ;

    listOfAudioFilesToUploadDict = [NSMutableDictionary new];
    
    listOfAudioToUploadFiles = [NSMutableArray new];

    // Get each entry (file or folder)
    while ((entry = [enumerator nextObject]) != nil)
    {
        // File or directory
        if ([fileMgr fileExistsAtPath:entry isDirectory:&isDirectory] && isDirectory)
        {
            
        }
        else
        {
            NSLog (@"  File - %@", entry.lastPathComponent);
            
            [contents addObject:entry.lastPathComponent];
            
            [listOfAudioFilesToUploadDict setObject:entry forKey:entry.lastPathComponent];
        }
    }
    

    for(NSString *audioNameAsKey in [listOfAudioFilesToUploadDict allKeys])
    {
        if (![[AppPreferences sharedAppPreferences].supportedAudioFileExtensions containsObject:[audioNameAsKey pathExtension]])
        {
            // Found Image File
            [listOfAudioFilesToUploadDict removeObjectForKey:audioNameAsKey];
        }
    }
    
//    NSDictionary* dict = listOfAudioFilesToUploadDict;
    
    for(NSString *filename in [listOfAudioFilesToUploadDict allKeys])
    {
//        if([[filename uppercaseString] containsString:@"CLINICDATE"])
//        {
//            NSArray* separatedName = [[filename uppercaseString] componentsSeparatedByString:@"CLINICDATE"];
//
//            NSString* newFileName = [separatedName objectAtIndex:1];
//
//            NSString* oldFilePath = [listOfAudioFilesToUploadDict objectForKey:filename];
//
//            NSString* newFileSubPath = [oldFilePath stringByDeletingLastPathComponent];
//
//            newFileSubPath = [newFileSubPath stringByAppendingPathComponent:newFileName];
//
//            [listOfAudioFilesToUploadDict removeObjectForKey:filename];
//
//            [listOfAudioFilesToUploadDict setObject:newFileName forKey:newFileSubPath];
//
//            [[APIManager sharedManager] checkDuplicateAudioForDay:[NSString stringWithFormat:@"%ld", [AppPreferences sharedAppPreferences].loggedInUser.userId] originalFileName:newFileSubPath];
//        }
//        else
//        {
            NSString* fileSubPath = [listOfAudioFilesToUploadDict objectForKey:filename];
            
             [[APIManager sharedManager] checkDuplicateAudioForDay:[NSString stringWithFormat:@"%ld", [AppPreferences sharedAppPreferences].loggedInUser.userId] originalFileName:fileSubPath];
//        }
    }
    NSLog(@"directoryContents ====== %@",@"ds");

}

- (IBAction)pasteAudioFilesButtonClicked:(id)sender
{
    NSString* uploadFilesFolderPath = [[AppPreferences sharedAppPreferences] getUsernameUploadAudioDirectoryPath];
    
    [self openFolderInFinder:uploadFilesFolderPath];
}

- (IBAction)getDownloadedFilesButtonClicked:(id)sender
{
    NSString* downloadedTransFolderPath = [[AppPreferences sharedAppPreferences] getUsernameTranscriptionDirectoryPath];
    
    [self openFolderInFinder:downloadedTransFolderPath];
}

- (IBAction)getBackupFilesButtonClicked:(id)sender
{
    NSString* backupFolderPath = [[AppPreferences sharedAppPreferences] getUsernameBacupAudioDirectoryPath];
    
    [self openFolderInFinder:backupFolderPath];
}
@end

