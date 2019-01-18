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
#import "DownloadMetaDataJob.h"
#import "AudioFile.h"
#import "NSData+AES256.h"
#import "BaseLogFileManager.h"
#import "UITextViewLogger.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.checkingFilesLabel.stringValue = @"";

//    NSString* appDir = [self applicationSupportDirectory];
//    dataSource = [NSArray arrayWithObjects:@"John", @"Mary", @"George", nil];

//    dataSource = [NSArray arrayWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSDictionary alloc] initWithObjectsAndKeys:@"obj1",@"children", nil],@"children", nil], nil];

    // something nice for your family
   

//    firstParent = [[NSDictionary alloc] initWithObjectsAndKeys:[NSArray arrayWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:[NSArray arrayWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:[NSArray arrayWithObjects:@"Mary", nil],@"children", nil], nil],@"children", nil], nil],@"children", nil];
    
//    firstParent = [[NSDictionary alloc] initWithObjectsAndKeys:
//                                                                [NSArray arrayWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:[NSArray arrayWithObjects:@"Mary", nil],@"children", nil], nil], @"children",
//                                                                nil];

    CubeFilesFolderPath = [[AppPreferences sharedAppPreferences] getCubeFilesFolderPathUsingBookmark];
    
    pathComponents = [CubeFilesFolderPath pathComponents];
    
    [pathComponents removeObject:@"/"];
    
    pathComponents = [[pathComponents reverseObjectEnumerator] allObjects];

    NSMutableArray* allDict = [NSMutableArray new];
    
    NSDictionary* inside1;
    
    int i = 0;
    
//    inside1 = [[NSDictionary alloc] initWithObjectsAndKeys:
//               [[NSArray alloc] initWithObjects:@"",nil],@"children", nil];

    inside1 = [[NSDictionary alloc] initWithObjectsAndKeys:
               [[NSArray alloc] initWithObjects:@"",nil],@"children", nil];
    
//    NSDictionary* inside2 = [[NSDictionary alloc] initWithObjectsAndKeys:
//                             inside1,@"children", nil];
    
//    NSDictionary* inside3 =  [[NSDictionary alloc] initWithObjectsAndKeys:
//                              inside2,@"children", nil];
    
//    [allDict addObject:inside1];
//
//    [allDict addObject:inside2];
//
//    [allDict addObject:inside3];
    
    pairingDict = [[NSMutableDictionary alloc] init];

    while (i < pathComponents.count)
    {
       
        [pairingDict setObject:[pathComponents objectAtIndex:i] forKey:inside1];
        
        i++;
        
        if (i != pathComponents.count)
        {
            inside1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                       inside1,@"children", nil];
        }
       
        
    }
    
//   NSDictionary* inside1 = [[NSDictionary alloc] initWithObjectsAndKeys:
//     [[NSArray alloc] initWithObjects:@"",nil],@"children", nil];
    
    
    
   
    
    firstParent = inside1;
    
//    [pairingDict setObject:@"Users" forKey:inside1];
//
//    [pairingDict setObject:@"admin" forKey:inside2];
//
//    [pairingDict setObject:@"Documents" forKey:inside3];

    // ---> calling setBackgroundColorOFButtonsAndView method
    [self setBackgroundColorOFButtonsAndView];
    
//    secondParent = [[NSDictionary alloc] initWithObjectsAndKeys:@"Elisabeth",@"parent",[NSArray arrayWithObjects:@"Jimmie",@"Kate", nil],@"children", nil];
   
    list = [NSArray arrayWithObjects:firstParent, nil];

    self.uploadedAudioFilesArrayForTableView = [NSMutableArray new];
    
    self.dictationIdsArrayForDownload = [NSMutableArray new];

    self.audioFileAddedInQueueArray = [NSMutableArray new];
    
    self.duplicateFileCheckArray = [NSMutableArray new];
    
    self.validForTCIdCallNonDuplicateAudioArray = [NSMutableArray new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateNoInternet:) name:NOTIFICATION_NO_INTERNET
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateDuplicateFileReponse:) name:NOTIFICATION_CHECK_DUPLICATE_AUDIO_FOR_DAY_API
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateTCIDViewReponse:) name:NOTIFICATION_FTP_GET_TC_ID_VIEW_API
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateVCIDViewReponse:) name:NOTIFICATION_FTP_SET_VC_ID_VERIFY_API
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateFileUploadReponse:) name:NOTIFICATION_FILE_UPLOAD_API
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateAudioFileDownloadReponse:) name:NOTIFICATION_GET_BROWSER_AUDIO_FILES_DOWNLOAD_API
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateDictationIdsReponse:) name:NOTIFICATION_GET_DICTATION_IDS_API
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateGenerateFileNameReponse:) name:NOTIFICATION_GENERATE_FILENAME_API
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateDictatorsFolderReponse:) name:NOTIFICATION_GET_DICTATORS_FOLDER_API
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateDocFileDownloadReponse:) name:NOTIFICATION_DOWNLOAD_FILE_API
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateUpdateDictationIdReponse:) name:NOTIFICATION_UPDATE_DOWNLOAD_FILE_STATUS_API
                                               object:nil];
//    NSString* StrSQL = [NSString stringWithFormat:@"Select d.DictatorFirstName  + ' ' + d.DictatorLastName as DictatorFullName from Users a inner join Clinics b on a.ParentCompanyID=b.ClinicID INNER JOIN Dictators d on d.DictatorID=a.UserID WHERE a.UserID=%ld",[AppPreferences sharedAppPreferences].loggedInUser.userId];
  
    [[APIManager sharedManager] setVCID:[NSString stringWithFormat:@"%ld",[AppPreferences sharedAppPreferences].loggedInUser.userId]];
    
//    [[APIManager sharedManager] getSingleQueryValueComment:StrSQL];
    
    CGSize size =  CGSizeMake(900, 770);
    
    self.preferredContentSize = size;

    [self checkIfFolderGeneratedAndStartCycle];
   
//    window = [NSWindow new];
//    [self startInitialCycle];
}

-(void)checkIfFolderGeneratedAndStartCycle
{
//[[NSUserDefaults standardUserDefaults] setBool:false forKey:DOWNLOAD_FOLDER_BOOKMARK_GENERATED];
    BOOL isCubeFilesFolderGenerated = [[NSUserDefaults standardUserDefaults] boolForKey:DOWNLOAD_FOLDER_BOOKMARK_GENERATED];
    
    if (isTimerStartedFirstTime == false)
    {
        if (isCubeFilesFolderGenerated)
        {
            [self startInitialCycle];
            
            [folderGeneratedTimer invalidate];
            
            isTimerStartedFirstTime = true;
        }
        else
        {
//            self.checkingFilesLabel.stringValue = @"CubeFiles folder not selected";

            [self isCubeFilesFolderGeneratedTimer];
        }
    }
    
}

-(void)isCubeFilesFolderGeneratedTimer
{
    if ([folderGeneratedTimer isValid])
    {
        [folderGeneratedTimer invalidate];
    }
    folderGeneratedTimer =  [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(checkIfFolderGeneratedAndStartCycle) userInfo:nil repeats:YES];
    
}
-(void)startInitialCycle
{
  
    [self checkForFilesFirstTimeAfterLoginRapidTimer];
    
    [self testLogs];
    
//    CubeFilesFolderPath = [[AppPreferences sharedAppPreferences] getCubeFilesFolderPathUsingBookmark];
//
//    pathComponents = [CubeFilesFolderPath pathComponents];
//
//    [pathComponents removeObject:@"/"];
    
    [self.outlineView reloadData];
}
-(void)validateNoInternet:(NSNotification*)noti
{
//    [hud removeFromSuperview];
    
}


-(void)testLogs
{
//    setenv("XcodeColors", "YES", 0);
//
//    [[AppPreferences sharedAppPreferences] startScope];
    
    [[AppPreferences sharedAppPreferences] addLoggerOnce];

    // setup the text view logger
    UITextViewLogger *textViewLogger = [UITextViewLogger new];
    
    textViewLogger.autoScrollsToBottom = YES;

    [DDLog addLogger:textViewLogger];
    
    textViewLogger.textView = self.logTextView;
    
//    [[AppPreferences sharedAppPreferences] stopScope];
    
}
#pragma mark : Notification Callback Methods

-(void)validateUpdateDictationIdReponse:(NSNotification*)notification
{
    NSDictionary* dict = notification.object;
    
    NSString* errorCode = [dict valueForKey:@"errorCode"];
    
    if (errorCode != nil)
    {
        DDLogInfo(@"Doc file status not updated");

        if ([AppPreferences sharedAppPreferences].nextBlockToBeDownloadPoolArray.count > 0)
        {
            [[AppPreferences sharedAppPreferences].nextBlockToBeDownloadPoolArray removeAllObjects];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self performSelector:@selector(cleanUpTableViewAfterDocDownload) withObject:nil afterDelay:3.0];
            
            [self checkForNewFilesSubSequentTimer];
            
            return;
            
        });
        
    }
    else
    {
        DDLogInfo(@"Doc file status updated successfully");
        
        if ([AppPreferences sharedAppPreferences].nextBlockToBeDownloadPoolArray.count > 0)
        {
            if ([AppPreferences sharedAppPreferences].isReachable)
            {
                DDLogInfo(@"Downloading next Doc file");
                
                NSBlockOperation* operation = [[AppPreferences sharedAppPreferences].nextBlockToBeDownloadPoolArray objectAtIndex:0];
                
                [[AppPreferences sharedAppPreferences].docDownloadQueue addOperation:operation];
                
                [[AppPreferences sharedAppPreferences].nextBlockToBeDownloadPoolArray removeObjectAtIndex:0];
            }
            else
            {
                [self checkForNewFilesSubSequentTimer];
            }
            
        }
        else
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self performSelector:@selector(cleanUpTableViewAfterDocDownload) withObject:nil afterDelay:3.0];
                
            });
            
        }

    }
   
}

-(void)validateDictatorsFolderReponse:(NSNotification*)notification
{
    NSDictionary* responseDict = notification.object;
    
//     DDLogInfo(@"%@",responseDict);
}

-(void)validateGenerateFileNameReponse:(NSNotification*)notification
{
    NSDictionary* responseDict = notification.object;

//    DDLogInfo(@"%@",responseDict);

}

-(void)validateDuplicateFileReponse:(NSNotification*)notification
{
    
    NSDictionary* responseString = notification.object;
    
    NSString* response = [responseString objectForKey:@"response"];
    
    NSString* audioFileName = [responseString objectForKey:@"audioFileName"];
    
    NSString* audioFilePath = [responseString objectForKey:@"audioFilePath"];

    // remove added audio file obj from array and later check if more obj exists, if no and intenet not aviable then start timer
    [self.duplicateFileCheckArray removeObject:audioFileName];
    
    if ([response isEqualToString:@"No Records"])
    {
//        NSString* audioUploadFolderPath = [[AppPreferences sharedAppPreferences] getUsernameUploadAudioDirectoryPath];
        
//        NSString* audioFilePath = [audioUploadFolderPath stringByAppendingPathComponent:audioFileName];
        
        uint64_t fileSize = [[AppPreferences sharedAppPreferences] getFileSize:audioFilePath];
        
        if (fileSize > 104857600)
        {
            DDLogInfo(@"File size is too big to upload");

        }
        else
        {
            if ([AppPreferences sharedAppPreferences].isReachable)
            {
                [self.validForTCIdCallNonDuplicateAudioArray addObject:audioFileName];
                
                 [[APIManager sharedManager] FTPGetTCIdView:[NSString stringWithFormat:@"%ld",[AppPreferences sharedAppPreferences].loggedInUser.userId] originalFileName:audioFileName filePath:audioFilePath];
            }
            else
                if (self.duplicateFileCheckArray.count < 1 && self.uploadedAudioFilesArrayForTableView.count < 1)
            {

                    [self checkForNewFilesSubSequentTimer];
            }
           
        }
    }
    else
    if ([response isEqualToString:@"duplicate"])
    {
       // DDLogInfo(@"Duplicate file found, file name = %@",audioFileName);

     //   DDLogInfo(@"Moving duplicate audio file to BackupAudio folder");
        
        // ---> Removing logs for duplicate file
        
        DDLogInfo(@"Moving %@ audio file to BackupAudio folder", audioFileName);


        NSString* FileServerPath = [responseString valueForKey:@"FileServerPath"];
        
        NSArray* arr = [FileServerPath componentsSeparatedByString:@"\\"];
        
        NSString* dateFolderName = [arr lastObject];
        
        DDLogInfo(@"Uploaded Date = %@", dateFolderName);

        [self performCleanUpForDuplicate:dateFolderName filePath:audioFilePath];
        
        [listOfAudioFilesToUploadDict removeObjectForKey:audioFileName];
       
        // if internet not reachable and no file in tableview then start the cycle again
        if (![AppPreferences sharedAppPreferences].isReachable && self.duplicateFileCheckArray.count < 1 && self.uploadedAudioFilesArrayForTableView.count < 1)
        {
            [self checkForNewFilesSubSequentTimer];
        }
        // if internet available and last file checked and no file in tableview then start browser file download
        else if (self.duplicateFileCheckArray.count < 1 && self.uploadedAudioFilesArrayForTableView.count < 1 && self.validForTCIdCallNonDuplicateAudioArray.count < 1)
        {
            [self checkBrowserAudioFilesForDownload];
        }
//        DDLogInfo(@"Checking next file to upload");

//        if ([AppPreferences sharedAppPreferences].nextBlockToBeUploadPoolArray.count > 0)
//        {
//            NSBlockOperation* nextOperation = [[AppPreferences sharedAppPreferences].nextBlockToBeUploadPoolArray objectAtIndex:0];
//
//            [[AppPreferences sharedAppPreferences].audioUploadQueue addOperation:nextOperation];
//
//            [[AppPreferences sharedAppPreferences].nextBlockToBeUploadPoolArray  removeObjectAtIndex:0];
//
//        }
//        else
//        {
//            DDLogInfo(@"No file found");
//
//        }
        
    }
    else
    {
        if (self.duplicateFileCheckArray.count < 1 && self.uploadedAudioFilesArrayForTableView.count < 1)
//        if (([AppPreferences sharedAppPreferences].nextBlockToBeUploadPoolArray.count < 1 || [AppPreferences sharedAppPreferences].nextBlockToBeDownloadPoolArray.count < 1 || [AppPreferences sharedAppPreferences].audioUploadQueue.operationCount < 1 || [AppPreferences sharedAppPreferences].docDownloadQueue.operationCount < 1))
        {
            [self checkForNewFilesSubSequentTimer];
        }
    }
}

-(void)validateVCIDViewReponse:(NSNotification*)notification
{
    DDLogInfo(@"VC info received");
    
    // --->adding username in log
    
    DDLogInfo(@"Welcome %@", [AppPreferences sharedAppPreferences].loggedInUser.userName);

    NSDictionary* responseString = notification.object;
    
    NSArray* verifyArray = [responseString valueForKey:@"SetTCID_Verifylist"];
    
    NSDictionary* verifyDict = [verifyArray objectAtIndex:0];
    
    
    vcIdList1 = [[VCIdList alloc] init];
    
    //    vcIdList.AutoOutsourceTime =  [[verifyDict valueForKey:@"AutoOutsourceTime"] intValue];
    vcIdList1.Inhouse =  [[verifyDict valueForKey:@"Inhouse"] intValue];
    vcIdList1.TCID =  [[verifyDict valueForKey:@"TCID"] intValue];
    vcIdList1.VCID =  [[verifyDict valueForKey:@"VCID"] intValue];
    vcIdList1.verify =  [[verifyDict valueForKey:@"Verify"] boolValue];
    
}

-(void)validateTCIDViewReponse:(NSNotification*)notification
{
    
    NSDictionary* responseString = notification.object;

    NSString* error = [responseString objectForKey:@"error"];

    // we have started the timer in duplicate, if we got this reposnse then we have file to upload hence  invalidate the timer
    if ([checkForNewFilesTimer isValid])
    {
        [checkForNewFilesTimer invalidate];
    }
    DDLogInfo(@"Finished checking TC ID View");
    // if internet not reachable and no file is in queue to upload or download queue then start the cycle again
     if (![AppPreferences sharedAppPreferences].isReachable && self.uploadedAudioFilesArrayForTableView.count < 1)
     {
         [self checkForNewFilesSubSequentTimer];
     }
    else if (error != nil)
    {
        
    }
    else
    {
        
        NSDictionary* responseDict = [responseString objectForKey:@"response"];
        
        NSArray* tcIdListArray = [responseDict objectForKey:@"vwGetTCIDlist"];
        
        NSDictionary* tcIdListDict = [tcIdListArray objectAtIndex:0];
        
        NSString* audioFileName = [responseString objectForKey:@"audioFileName"];
        
        if ([self.validForTCIdCallNonDuplicateAudioArray containsObject:audioFileName])
        {
            [self.validForTCIdCallNonDuplicateAudioArray removeObject:audioFileName];
        }
        NSString* filePath = [responseString objectForKey:@"audioFilePath"];
        
        [[AppPreferences sharedAppPreferences] getUsernameUploadAudioDirectoryPath];
//        tcIdList = nil;
        
        VCIdList* vcIdList = vcIdList1;
        
        ViewTCIdList *tcIdList = [ViewTCIdList new];
        
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
        
//        NSString* folderPath = [[AppPreferences sharedAppPreferences] getUsernameUploadAudioDirectoryPath];
        
//        NSString* filePath = [folderPath stringByAppendingPathComponent:audioFileName];
        
        uint64_t fileSize = [[AppPreferences sharedAppPreferences] getFileSize:filePath];
        
        [AppPreferences sharedAppPreferences].audioUploadQueue.maxConcurrentOperationCount = 1;
        
        AudioFile* audioFile = [AudioFile new];
        audioFile.fileName = audioFileName;
        audioFile.originalFileNamePath = filePath;
        audioFile.originalFileName = audioFileName;
        audioFile.fileSize = fileSize;
        audioFile.status = @"Uploading";
        audioFile.fileType = @"AudioUpload";
        NSOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
            
            
            DownloadMetaDataJob* job = [DownloadMetaDataJob new];

            job.downLoadEntityJobName = FILE_UPLOAD_API;

            job.audioFileObject = audioFile;

            [job uploadFileAfterGettingdatabaseValues:tcIdList vcList:vcIdList audioFile:audioFile];
//            APIManager* apiManager = [APIManager sharedManager];
//
//            apiManager.audioFileObject = audioFile;
//
//            [apiManager uploadFileAfterGettingdatabaseValues:tcIdList vcList:vcIdList audioFile:audioFile];
            
        }];
        
        
        if (self.uploadedAudioFilesArrayForTableView.count < 1)
        {
            DDLogInfo(@"Uploading audio file %@", audioFile.fileName);
            
            // set row count of audio file so that we can reload bytes sent column later
            int tableViewRowCount = [AppPreferences sharedAppPreferences].totalFilesToBeAddedInTableView;
            
            audioFile.rowNumber = tableViewRowCount;
            
//            [self.audioFileAddedInQueueArray addObject:audioFile];
            
            [self.uploadedAudioFilesArrayForTableView addObject:audioFile];
            
            NSIndexSet* rowIndexSet = [[NSIndexSet alloc] initWithIndex:[AppPreferences sharedAppPreferences].totalFilesToBeAddedInTableView];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView insertRowsAtIndexes:rowIndexSet withAnimation:NSTableViewAnimationEffectNone];
                
                ++[AppPreferences sharedAppPreferences].totalFilesToBeAddedInTableView;
                
                [[AppPreferences sharedAppPreferences].audioUploadQueue addOperation:blockOperation];
                
            });
            //        [self.tableView reloadData];
            
           
            
            
        }
        else
        {
           
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // set row count (to queued + 1) of audio file so that we can reload bytes sent column later
                int tableViewRowCount = [AppPreferences sharedAppPreferences].totalFilesToBeAddedInTableView;
;
                audioFile.rowNumber = tableViewRowCount;
                
                audioFile.status = @"In Queue";
                
                [self.uploadedAudioFilesArrayForTableView addObject:audioFile];
                //
                NSIndexSet* rowIndexSet = [[NSIndexSet alloc] initWithIndex:[AppPreferences sharedAppPreferences].totalFilesToBeAddedInTableView];
                
                [self.tableView insertRowsAtIndexes:rowIndexSet withAnimation:NSTableViewAnimationEffectNone];
                
                ++[AppPreferences sharedAppPreferences].totalFilesToBeAddedInTableView;

                [[AppPreferences sharedAppPreferences].nextBlockToBeUploadPoolArray addObject:blockOperation];
                
            });
            
            
        }
        
        // get the count of total files to upload to show on view ( uploading 2 0f uploadFilesQueueCount )
        [AppPreferences sharedAppPreferences].uploadFilesQueueCount = [AppPreferences sharedAppPreferences].uploadFilesQueueCount + 1;
        
        if (!progressTimer.isValid)
        {
            [self startFileUploadProgressBarTimer];
            
        }
        
    }
    
    
}


-(void)validateFileUploadReponse:(NSNotification*)notification
{
    NSDictionary* dict =  notification.object;
    
    AudioFile* audioFileObject = [dict objectForKey:@"audioFileObject"];
    
    NSString* isUploaded = audioFileObject.status;
    
    
    if ([isUploaded  isEqual: @"Uploaded"])
    {
        
        [AppPreferences sharedAppPreferences].totalUploadedCount = [AppPreferences sharedAppPreferences].totalUploadedCount + 1;

        DDLogInfo(@"Finished Uploading audio file %@", audioFileObject.fileName);

        [self performCleanUp:audioFileObject.originalFileNamePath];
        
        // remove object from dictionary
        [listOfAudioFilesToUploadDict removeObjectForKey:audioFileObject.fileName];
        
    }
    else
    {
//        DDLogInfo(@"File uploading failed filename %@", audioFileObject.fileName);

        long errorCode = [[dict objectForKey:@"errorCode"] longLongValue];

        // delete the encypted file
        [[AppPreferences sharedAppPreferences] deleteFileAtPath:audioFileObject.originalFileNamePath];
//        [self performCleanUp:audioFileObject.originalFileNamePath];
        
//        [listOfAudioFilesToUploadDict removeObjectForKey:audioFileObject.fileName];
        NSLog(@"array name =uploadedAudioFilesArrayForTableView");
        
        AudioFile* tempFileObj = [self.uploadedAudioFilesArrayForTableView objectAtIndex:audioFileObject.rowNumber];
        
        
        tempFileObj.status = @"Not Uploaded";
        
        [self.uploadedAudioFilesArrayForTableView replaceObjectAtIndex:audioFileObject.rowNumber withObject:tempFileObj];
        
        NSIndexSet* rowIndexSet = [[NSIndexSet alloc] initWithIndex:audioFileObject.rowNumber];
        
        NSIndexSet* columnIndexSet = [[NSIndexSet alloc] initWithIndex:3];
        
        [self.tableView reloadDataForRowIndexes:rowIndexSet columnIndexes:columnIndexSet];
        
        if ((errorCode == -1009 || errorCode == -1005) && [AppPreferences sharedAppPreferences].nextBlockToBeUploadPoolArray.count == 0)// no internet and no file to upload
        {
            
            [self checkForNewFilesSubSequentTimer];
        }
        
//        return;
//        [self.tableView reloadData];
        
    }
    
    if ([AppPreferences sharedAppPreferences].nextBlockToBeUploadPoolArray.count > 0)
    {
     
        dispatch_async(dispatch_get_main_queue(), ^{
            
             NSBlockOperation* nextOperation = [[AppPreferences sharedAppPreferences].nextBlockToBeUploadPoolArray objectAtIndex:0];
            
              AudioFile* tempFileObj = [self.uploadedAudioFilesArrayForTableView objectAtIndex:audioFileObject.rowNumber+1];
            
                tempFileObj.status = @"Uploading";
                
                [self.uploadedAudioFilesArrayForTableView replaceObjectAtIndex:audioFileObject.rowNumber+1 withObject:tempFileObj];
        
//                NSIndexSet* rowIndexSet = [[NSIndexSet alloc] initWithIndex:audioFileObject.rowNumber+1];
            
//                NSIndexSet* columnIndexSet = [[NSIndexSet alloc] initWithIndex:3];
        
//                    [self.tableView reloadDataForRowIndexes:rowIndexSet columnIndexes:columnIndexSet];
            
                    [self.tableView reloadData];
            DDLogInfo(@"Uploading next audio file");
            
            [[AppPreferences sharedAppPreferences].audioUploadQueue addOperation:nextOperation];
            
            [[AppPreferences sharedAppPreferences].nextBlockToBeUploadPoolArray  removeObjectAtIndex:0];
            
        });
        
      
        
    }
    else
    {
        if ([AppPreferences sharedAppPreferences].nextBlockToBeUploadPoolArray.count == 0)
        {
            
            [progressTimer invalidate];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
//                DDLogInfo(@"Finished Uploading all audio files");

                self.uploadingCountLabel.textColor = [NSColor colorWithRed:92/255.0 green:168/255.0 blue:48/255.0 alpha:1.0];
                
                self.uploadingCountLabel.stringValue = [NSString stringWithFormat:@"Uploaded %lu of %lu", (unsigned long)[AppPreferences sharedAppPreferences].totalUploadedCount,(unsigned long)[AppPreferences sharedAppPreferences].uploadFilesQueueCount];
                
                [self performSelector:@selector(updateUploadedFileAndQueueCount:) withObject:nil afterDelay:1.0];
                
                [self performSelector:@selector(cleanUpTableViewAfterAudioUpload) withObject:nil afterDelay:3.0];
            });
            
            
            //            [self checkForNewFilesSubSequentTimer];
        }
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}


-(void)validateAudioFileDownloadReponse:(NSNotification*)notification
{
    DDLogInfo(@"Finished checking audio files for download");

    NSDictionary* dict = notification.object;
    
    NSString* downloadStatus = [dict valueForKey:@"downloadStatus"];
    
    if ([downloadStatus isEqualToString:@"Downloaded"])
    {
        NSURL* downloadLocation = [dict valueForKey:@"downloadLocationUrl"];
        
        NSData* data = [NSData dataWithContentsOfURL:downloadLocation];
        
        NSError* error, *error1;
        
        id response = [NSJSONSerialization JSONObjectWithData:data
                                                      options:NSUTF8StringEncoding
                                                        error:&error];
        
        bool isArray = [response isKindOfClass:[NSArray class]];
        
        
        
        
        if(isArray)
        {
            
            NSArray* responseArray = response;
            
            DDLogInfo(@"%ld audio file(s) downloaded successfully", responseArray.count);

            for (int i =0; i < responseArray.count; i++)
            {
                [[AppPreferences sharedAppPreferences] startScope];
                
                NSDictionary* response = [responseArray objectAtIndex:0];
                
                AudioFile* audioFile = [AudioFile new];
                
                audioFile.status = @"Downloaded";
                
                audioFile.fileName = [response valueForKey:@"FileName"];
                
                audioFile.fileSize = [[response valueForKey:@"FileSize"] longLongValue];
                
                audioFile.originalFileName = [response valueForKey:@"OriginalFileName"];
                
                NSString* FileServerPath = [response valueForKey:@"FileServerPath"];
                
                NSArray* arr = [FileServerPath componentsSeparatedByString:@"\\"];
                
                NSString* dateFolderName = [arr lastObject];
                
                NSString *pathToBackUpFiles = [[AppPreferences sharedAppPreferences] getGivenDateBackUpAudioFolderPath:dateFolderName];

//                NSString* backupDirectoryPath = [[AppPreferences sharedAppPreferences] getUsernameBacupAudioDirectoryPath];
                
                NSString* newFilePath = [pathToBackUpFiles stringByAppendingPathComponent:audioFile.originalFileName];
                
                audioFile.originalFileNamePath = newFilePath;
                
                
                
                //                audioFile.file
                NSString* base64EncryptedString = [response valueForKey:@"FileData"];
                
                NSData *encodedData = [[NSData alloc] initWithBase64EncodedString:base64EncryptedString options:0];
                
                NSData* decryptedData = [encodedData AES256DecryptWithKey:SECRET_KEY];
                //

                if ([[NSFileManager defaultManager] fileExistsAtPath:newFilePath])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:newFilePath error:&error1];
                }
                //            BOOL isWritten = [decryptedData writeToFile:newFilePath atomically:YES];
                
                BOOL isWritten = [decryptedData writeToFile:newFilePath options:NSDataWritingAtomic error:&error];
                
                bool isDeleted = [[NSFileManager defaultManager] removeItemAtURL:downloadLocation error:&error1];
                
                if (isWritten)
                {
                    // ---> printing original downloaded file name
                    DDLogInfo(@"Downloaded audio file name = %@", audioFile.originalFileName);

                    // ---> printing original downloaded file name
                    DDLogInfo(@"Downloaded audio file %@ moved to backup folder", audioFile.originalFileName);
                    
                    long fileSize = [[AppPreferences sharedAppPreferences] getFileSize:newFilePath];
                    
                    audioFile.fileSize = fileSize;
                    
                }
                else
                {
                    DDLogInfo(@"Failed to write audio file %@, error occured = %@", audioFile.fileName, error.localizedDescription);

                }
                int tableViewRowCount = [AppPreferences sharedAppPreferences].totalFilesToBeAddedInTableView;
                
                audioFile.rowNumber = tableViewRowCount;
                
                audioFile.fileType = @"AudioDownload";
                
                ++[AppPreferences sharedAppPreferences].totalFilesToBeAddedInTableView;
                
                [self.uploadedAudioFilesArrayForTableView addObject:audioFile];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.tableView reloadData];
                    
                });
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (responseArray.count != 0)
                {
                    [self.progressIndicator setDoubleValue:100];
                    
                    self.uploadingCountLabel.textColor = [NSColor colorWithRed:92/255.0 green:168/255.0 blue:48/255.0 alpha:1.0];

                    self.uploadingCountLabel.stringValue = [NSString stringWithFormat:@"Downloaded %ld of %ld",responseArray.count, responseArray.count];
                }
                [self performSelector:@selector(cleanUpTableViewAfterAudioDownload) withObject:nil afterDelay:3.0];
                
                
            });
            
        }
        else
        {
            DDLogInfo(@"No Audio file available for download");

            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self performSelector:@selector(cleanUpTableViewAfterAudioDownload) withObject:nil afterDelay:3.0];
                
            });
        }
        
    }
}


-(void)validateDictationIdsReponse:(NSNotification*)notification
{
    NSDictionary* responseDict = notification.object;
    
    NSString* error = [responseDict valueForKey:@"error"];

    if (error != nil || [error isEqualToString:@""])
    {
         [self checkForNewFilesSubSequentTimer];
        
        return;
    }
    NSString* dictationIdsString = [responseDict valueForKey:@"Id"];
    
    DDLogInfo(@"Finished checking dictation ids");
    
    if ([AppPreferences sharedAppPreferences].nextBlockToBeDownloadPoolArray.count > 0)
    {
        [[AppPreferences sharedAppPreferences].nextBlockToBeDownloadPoolArray removeAllObjects];
    }
    
    //653047,653048,653049,653050,653051,653052
    if([dictationIdsString isEqualToString:@""])
    {
//        [self.dictationIdsArrayForDownload removeAllObjects];
        self.dictationIdsArrayForDownload = [@[] mutableCopy];
        
        [self checkForNewFilesSubSequentTimer];
        
        DDLogInfo(@"No Doc file available for download");

    }
    else
    {
        self.dictationIdsArrayForDownload = [@[] mutableCopy];
//
        
        self.dictationIdsArrayForDownload = [[dictationIdsString componentsSeparatedByString:@","] mutableCopy];
        
        DDLogInfo(@"%ld Doc file(s) available for download", self.dictationIdsArrayForDownload.count);

        if (self.dictationIdsArrayForDownload.count < 1 || ![AppPreferences sharedAppPreferences].isReachable)
        {
            [self checkForNewFilesSubSequentTimer];
            
            return;
        }
        for (int i =0 ; i < self.dictationIdsArrayForDownload.count; i++)
        {
            DDLogInfo(@"Downloading Doc file");

            NSOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
                
                [[APIManager sharedManager] downloadFile:[self.dictationIdsArrayForDownload objectAtIndex:i]];
                
                //            [self.dictationIdsArrayForDownload removeObjectAtIndex:0];
            }];
            
            if ([AppPreferences sharedAppPreferences].docDownloadQueue.operationCount < 1)
            {
                [[AppPreferences sharedAppPreferences].docDownloadQueue addOperation:blockOperation];
            }
            else
            {
                [[AppPreferences sharedAppPreferences].nextBlockToBeDownloadPoolArray addObject:blockOperation];
            }
            
        }
    }

}



-(void)validateDocFileDownloadReponse:(NSNotification*)notification
{
    
        
    NSDictionary* dict = notification.object;
    
    NSString* errorCode = [dict valueForKey:@"errorCode"];

    if (errorCode != nil)
    {
        if ([AppPreferences sharedAppPreferences].nextBlockToBeDownloadPoolArray.count > 0)
        {
            [[AppPreferences sharedAppPreferences].nextBlockToBeDownloadPoolArray removeAllObjects];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self performSelector:@selector(cleanUpTableViewAfterDocDownload) withObject:nil afterDelay:3.0];
            
            [self checkForNewFilesSubSequentTimer];

            return;

        });
        
    }
    NSString* downloadStatus = [dict valueForKey:@"downloadStatus"];
    
    NSURL* downloadLocation = [dict valueForKey:@"downloadLocationUrl"];
    
    NSData* data = [NSData dataWithContentsOfURL:downloadLocation];
    
    [[AppPreferences sharedAppPreferences] startScope];
    
    if ([downloadStatus isEqualToString:@"Downloaded"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
        
            NSError* error, *error1;

            
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSUTF8StringEncoding
                                                                       error:&error];
            
            AudioFile* audioFile = [AudioFile new];
            
            audioFile.status = @"Downloaded";
            
            long dictationID = [[response valueForKey:@"Id"] longLongValue];
            
            audioFile.fileName = [response valueForKey:@"FileName"];
            
            audioFile.fileSize = [[response valueForKey:@"FileSize"] longLongValue];
            
            audioFile.originalFileName = [response valueForKey:@"OriginalFileName"] ;
            
            audioFile.originalFileName = [audioFile.originalFileName stringByDeletingPathExtension];
            
            audioFile.originalFileName = [audioFile.originalFileName stringByAppendingPathExtension:@"doc"];
            
            NSString* FileServerPath = [response valueForKey:@"FileServerPath"];

            NSArray* arr = [FileServerPath componentsSeparatedByString:@"\\"];
            
            NSString* dateFolderName = [arr lastObject];

            NSString* transDirectoryPath = [[AppPreferences sharedAppPreferences] getGivenDateTranscriptionFolderPath:dateFolderName];
            
            NSLog(@"response = %@", response);

            NSString* base64EncryptedString = [response valueForKey:@"FileData"];
            
            NSString* newFilePath = [transDirectoryPath stringByAppendingPathComponent:audioFile.originalFileName];
            
            audioFile.originalFileNamePath = newFilePath;
            
            NSLog(@"base64EncryptedString = %@", base64EncryptedString);
            
            NSData *encodedData = [[NSData alloc] initWithBase64EncodedString:base64EncryptedString options:0];
            
            NSData* decryptedData = [encodedData AES256DecryptWithKey:SECRET_KEY];
            //
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:newFilePath])
            {
                [[NSFileManager defaultManager] removeItemAtPath:newFilePath error:&error1];
            }
            
            BOOL isWritten = [decryptedData writeToFile:newFilePath options:NSDataWritingAtomic error:nil];
            
            bool isDeleted = [[NSFileManager defaultManager] removeItemAtURL:downloadLocation error:&error1];
            
            if (isWritten)
            {
                DDLogInfo(@"Finished downloading Doc file, name = %@", audioFile.originalFileName);

            }
            else
            {
                DDLogInfo(@"Failed to write downloaded doc file, name = %@", audioFile.originalFileName);

            }
            long fileSize = [[AppPreferences sharedAppPreferences] getFileSize:newFilePath];
            
            audioFile.fileSize = fileSize;
            
            int tableViewRowCount = [AppPreferences sharedAppPreferences].totalFilesToBeAddedInTableView;
            
            audioFile.rowNumber = tableViewRowCount;
            
            audioFile.fileType = @"DocDownload";
            
            [self.uploadedAudioFilesArrayForTableView addObject:audioFile];
            
            NSIndexSet* rowIndexSet = [[NSIndexSet alloc] initWithIndex:[AppPreferences sharedAppPreferences].totalFilesToBeAddedInTableView];
            
            
            ++[AppPreferences sharedAppPreferences].totalFilesToBeAddedInTableView;

            DDLogInfo(@"Updating downloaded Doc file status, name = %@", audioFile.originalFileName);
            

//      [[APIManager sharedManager] updateDownloadFileStatus:@"13" dictationId:[NSString stringWithFormat:@"%ld",dictationID]];
       
           [self demoDOwnload];


        
            

                self.progressIndicator.doubleValue = 100;
                
                self.uploadingCountLabel.textColor = [NSColor colorWithRed:92/255.0 green:168/255.0 blue:48/255.0 alpha:1.0];
                
                self.uploadingCountLabel.stringValue = [NSString stringWithFormat:@"Downloaded %ld of %ld",self.uploadedAudioFilesArrayForTableView.count, self.dictationIdsArrayForDownload.count];
                
                [self.tableView insertRowsAtIndexes:rowIndexSet withAnimation:NSTableViewAnimationEffectNone];
                
            });

    }
    
     
}

-(void)demoDOwnload
{
    DDLogInfo(@"Doc file status updated successfully");
    
    if ([AppPreferences sharedAppPreferences].nextBlockToBeDownloadPoolArray.count > 0)
    {
        if ([AppPreferences sharedAppPreferences].isReachable)
        {
            DDLogInfo(@"Downloading next Doc file");
            
            NSBlockOperation* operation = [[AppPreferences sharedAppPreferences].nextBlockToBeDownloadPoolArray objectAtIndex:0];
            
            [[AppPreferences sharedAppPreferences].docDownloadQueue addOperation:operation];
            
            [[AppPreferences sharedAppPreferences].nextBlockToBeDownloadPoolArray removeObjectAtIndex:0];
        }
        else
        {
            [self checkForNewFilesSubSequentTimer];
        }
        
    }
    else
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self performSelector:@selector(cleanUpTableViewAfterDocDownload) withObject:nil afterDelay:3.0];
            
        });
        
    }

}



#pragma mark: Reset Tableview

-(void)updateUploadedFileAndQueueCount:(id)obj
{
    [AppPreferences sharedAppPreferences].totalUploadedCount = 0;
    
    [AppPreferences sharedAppPreferences].uploadFilesQueueCount = 0;
}

-(void)performCleanUp:(NSString*)audioFilePath
{
    
    // delete the encypted file
    [[AppPreferences sharedAppPreferences] deleteFileAtPath:audioFilePath];
    
    // move file to backup
    [[AppPreferences sharedAppPreferences] moveAudioFileToBackup:audioFilePath];
    
    // if dict.count value is 0 start the upload timer
    if (listOfAudioFilesToUploadDict.count == 0)
    {
        // retsart the timer to upload audio
    }
   
}

-(void)performCleanUpForDuplicate:(NSString*)dateFolderName filePath:(NSString*)filePath
{
    
    // delete the encypted file
//    [[AppPreferences sharedAppPreferences] deleteFileAtPath:audioFilePath];
    
    // move file to backup
    [[AppPreferences sharedAppPreferences] moveDuplicateAudioFileToGivenDateBackup:dateFolderName filePath:filePath];
    
    // if dict.count value is 0 start the upload timer
    if (listOfAudioFilesToUploadDict.count == 0)
    {
        // retsart the timer to upload audio
    }
    
}

-(void)cleanUpTableViewAfterDocDownload
{
    self.progressIndicator.doubleValue = 0;
    
    self.uploadingCountLabel.stringValue = @"";
    
    [self.uploadedAudioFilesArrayForTableView removeAllObjects];
    
    [AppPreferences sharedAppPreferences].totalFilesToBeAddedInTableView = 0;
    
    [self.tableView reloadData];
    
    [[AppPreferences sharedAppPreferences] stopScope];
    
    [self checkForNewFilesSubSequentTimer];
    
}

-(void)cleanUpTableViewAfterAudioDownload
{
    [self.uploadedAudioFilesArrayForTableView removeAllObjects];
    
    [AppPreferences sharedAppPreferences].totalFilesToBeAddedInTableView = 0;
    
    self.uploadingCountLabel.stringValue = @"";

    [self.progressIndicator setDoubleValue:0];

    [self.tableView reloadData];
    
    [[AppPreferences sharedAppPreferences] stopScope];
    
    [self getDictationIds];
}


-(void)cleanUpTableViewAfterAudioUpload
{
    [self.uploadedAudioFilesArrayForTableView removeAllObjects];
    
    [AppPreferences sharedAppPreferences].totalFilesToBeAddedInTableView = 0;
    
    [self.tableView reloadData];
    
    [[AppPreferences sharedAppPreferences] stopScope];

    [self checkBrowserAudioFilesForDownload];
    
    [self.progressIndicator setDoubleValue:0];
    
    self.uploadingCountLabel.stringValue = @"";
    
}
#pragma mark: Timer And Methods

-(void)checkForFilesFirstTimeAfterLoginRapidTimer
{
    checkForNewFilesTimer =  [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(checkForNewFilesForFirstTime) userInfo:nil repeats:YES];
    
}

-(void)checkForNewFilesForFirstTime
{
    
    [self getFilesToBeUploadFromUploadFilesFolder];
    
     [checkForNewFilesTimer invalidate];
    
}

-(void)checkForNewFilesSubSequentTimer
{
    if ([checkForNewFilesTimer isValid])
    {
        [checkForNewFilesTimer invalidate];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self->checkForNewFilesTimer isValid])
        {
            [self->checkForNewFilesTimer invalidate];
        }
          self->checkForNewFilesTimer =  [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(checkForNewFilesForSubSequentTime) userInfo:nil repeats:YES];
        
       
    });
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//    });
    
    
    
    
}

-(void)checkForNewFilesForSubSequentTime
{
    [[AppPreferences sharedAppPreferences] addLoggerOnce];

    self.checkingFilesLabel.stringValue = @"Checking Files...";
    
    self.checkingFilesLabel.textColor = [NSColor orangeColor];
    
    if ([checkForNewFilesTimer isValid])
    {
        [checkForNewFilesTimer invalidate];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self->checkForNewFilesTimer isValid])
        {
            [self->checkForNewFilesTimer invalidate];
        }
        
    });
    
    [self getFilesToBeUploadFromUploadFilesFolder];
    
  
}

-(void)startFileUploadProgressBarTimer
{
    progressTimer =  [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(updateFileUploadProgresCount) userInfo:nil repeats:YES];
}

-(void)updateFileUploadProgresCount
{
    if (!([AppPreferences sharedAppPreferences].totalUploadedCount > [AppPreferences sharedAppPreferences].uploadFilesQueueCount))
    {
        NSIndexSet* rowIndexSet = [[NSIndexSet alloc] initWithIndex:[AppPreferences sharedAppPreferences].currentUploadingTableViewRow];
        
        NSIndexSet* columnIndexSet = [[NSIndexSet alloc] initWithIndex:2];
        
        [self.tableView reloadDataForRowIndexes:rowIndexSet columnIndexes:columnIndexSet];
        
        self.uploadingCountLabel.textColor = [NSColor orangeColor];
        
        self.uploadingCountLabel.stringValue = [NSString stringWithFormat:@"Uploading %ld of %lu", [AppPreferences sharedAppPreferences].totalUploadedCount+1,(unsigned long)[AppPreferences sharedAppPreferences].uploadFilesQueueCount];
    }
//    else
//        if (([AppPreferences sharedAppPreferences].totalUploadedCount >= [AppPreferences sharedAppPreferences].uploadFilesQueueCount))
//        {
//            self.uploadingCountLabel.textColor = [NSColor colorWithRed:92/255.0 green:168/255.0 blue:48/255.0 alpha:1.0];
//
//            self.uploadingCountLabel.stringValue = [NSString stringWithFormat:@"Uploaded %lu of %lu", (unsigned long)[AppPreferences sharedAppPreferences].totalUploadedCount,(unsigned long)[AppPreferences sharedAppPreferences].uploadFilesQueueCount];
//
//        }
    
    [self.progressIndicator setDoubleValue:[AppPreferences sharedAppPreferences].currentUploadingPercentage];
}
#pragma mark: Cycle Methods


-(void)getFilesToBeUploadFromUploadFilesFolder
{
    DDLogInfo(@"Checking audio files for upload");
    
//    [[AppPreferences sharedAppPreferences] startScope];

    NSError* error;
    
    NSString* filePath =  [[AppPreferences sharedAppPreferences] getUsernameUploadAudioDirectoryPath];
    
//    NSError * error;
    [[AppPreferences sharedAppPreferences] startScope];
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
    
//    [[AppPreferences sharedAppPreferences] stopScope];
    
}

-(void) checkBrowserAudioFilesForDownload
{
    DDLogInfo(@"Checking audio files for download");

    [[APIManager sharedManager] getBrowserAudioFilesForDownload:[NSString stringWithFormat:@"%ld", [AppPreferences sharedAppPreferences].loggedInUser.userId]];
}

-(void) getDictationIds
{
    if([AppPreferences sharedAppPreferences].isReachable)
    {
          [[APIManager sharedManager] getDicatationIds:[NSString stringWithFormat:@"%ld",[AppPreferences sharedAppPreferences].loggedInUser.userId]];
    }
    else
    {
        [self checkForNewFilesSubSequentTimer];
    }
        
  
}



#pragma mark: Supportive Methods

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
    
//    NSMutableArray *contents = [NSMutableArray new] ;

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
            
//            [contents addObject:entry.lastPathComponent];
            
            if ([listOfAudioFilesToUploadDict objectForKey: entry.lastPathComponent] == nil)
            {
                [listOfAudioFilesToUploadDict setObject:entry forKey:entry.lastPathComponent];
            }
            else
            {
                NSString* uploadDirePath = [[AppPreferences sharedAppPreferences] getUsernameUploadAudioDirectoryPath];
                
                uploadDirePath = [uploadDirePath stringByAppendingPathComponent:entry];
                
                [[NSFileManager defaultManager] removeItemAtPath:uploadDirePath error:nil];
            }
            
        }
    }
    

    for(NSString *audioNameAsKey in [listOfAudioFilesToUploadDict allKeys])
    {
        if (![[AppPreferences sharedAppPreferences].supportedAudioFileExtensions containsObject:[audioNameAsKey pathExtension]])
        {
            DDLogInfo(@"%@ File extension not supported",audioNameAsKey);
            [listOfAudioFilesToUploadDict removeObjectForKey:audioNameAsKey];
        }
    }
    
//    NSDictionary* dict = listOfAudioFilesToUploadDict;
    
    if (listOfAudioFilesToUploadDict.count > 0)
    {
        DDLogInfo(@"Finished checking audio files, %ld audio file(s) found", listOfAudioFilesToUploadDict.count);
        
        if ([AppPreferences sharedAppPreferences].isReachable)
        {
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
                
                self.checkingFilesLabel.stringValue = @"Finished Checking Files.";
                
                self.checkingFilesLabel.textColor = [NSColor colorWithRed:92/255.0 green:168/255.0 blue:48/255.0 alpha:1.0];
                
                [checkForNewFilesTimer invalidate];
                
                NSString* fileSubPath = [listOfAudioFilesToUploadDict objectForKey:filename];
                
                NSString* audioDirecPath = [[AppPreferences sharedAppPreferences] getUsernameUploadAudioDirectoryPath];
                
                NSString* fullPath = [audioDirecPath stringByAppendingPathComponent:fileSubPath];
                
                // add file in duplicate file check array, so that when duplicate response received remove this file from array and check if this array contains more object, if yes then dont start the timer
                [self.duplicateFileCheckArray addObject:filename];
                
                [[APIManager sharedManager] checkDuplicateAudioForDay:[NSString stringWithFormat:@"%ld", [AppPreferences sharedAppPreferences].loggedInUser.userId] originalFileName:filename filePath:fullPath];
            }
            
        }
        else
        {
            DDLogInfo(@"Internet connection appears to be offline");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[AppPreferences sharedAppPreferences] showAlertWithTitle:@"Alert" subTitle:@"The Internet connection appears to be offline. Operations could not be processed."];
                
                 [self checkForNewFilesSubSequentTimer];

            });
           
           
          
        }
    }
    else
    {
        if ([AppPreferences sharedAppPreferences].isReachable)
        {
            
            self.checkingFilesLabel.stringValue = @"Finished Checking Files.";
            
            self.checkingFilesLabel.textColor = [NSColor colorWithRed:92/255.0 green:168/255.0 blue:48/255.0 alpha:1.0];
            
            DDLogInfo(@"Finished checking audio file(s), no file available for upload");
            
            DDLogInfo(@"Checked folder path = %@", [[AppPreferences sharedAppPreferences] getUsernameUploadAudioDirectoryPath]);
            
            [self checkBrowserAudioFilesForDownload];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[AppPreferences sharedAppPreferences] showAlertWithTitle:@"Alert" subTitle:@"The Internet connection appears to be offline. Operations could not be processed."];
                
            });
            
            [self checkForNewFilesSubSequentTimer];
        }
        
    }
   
//    NSLog(@"directoryContents ====== %@",@"ds");

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
#pragma mark: TableView DataSource And Delegate

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString* identifier;
    
    NSTableCellView* cell;
    
    if (tableColumn == self.tableView.tableColumns[0])
    {
        identifier = @"fileName";
        
        cell = [self.tableView makeViewWithIdentifier:identifier owner:nil];
        
        AudioFile* audioFile = [self.uploadedAudioFilesArrayForTableView objectAtIndex:row];
        
        cell.textField.stringValue = audioFile.originalFileName;
    }
    else
        if (tableColumn == self.tableView.tableColumns[1])
        {
            identifier = @"fileSize";
            
            cell = [self.tableView makeViewWithIdentifier:identifier owner:nil];
            
            AudioFile* audioFile = [self.uploadedAudioFilesArrayForTableView objectAtIndex:row];
            
            cell.textField.stringValue = [NSString stringWithFormat:@"%ld", audioFile.fileSize];

        }
        else
            if (tableColumn == self.tableView.tableColumns[2])
            {
                identifier = @"byteSent";
                
                cell = [self.tableView makeViewWithIdentifier:identifier owner:nil];
                
                AudioFile* audioFile = [self.uploadedAudioFilesArrayForTableView objectAtIndex:row];
                
                if ([audioFile.fileType isEqualToString:@"AudioDownload"] || [audioFile.fileType isEqualToString:@"DocDownload"])
                {
                    cell.textField.stringValue = [NSString stringWithFormat:@"%ld", audioFile.fileSize];

                }
                else
                {
                    NSString* progressPercent = [[AppPreferences sharedAppPreferences].progressCountFileNameDict objectForKey:audioFile.fileName];
                    
                    cell.textField.stringValue = [NSString stringWithFormat:@"%lld", [progressPercent longLongValue]];
                }
                
            }
            else
                if (tableColumn == self.tableView.tableColumns[3])
                {
                    identifier = @"status";
                    
                    cell = [self.tableView makeViewWithIdentifier:identifier owner:nil];
                    
                    AudioFile* audioFile = [self.uploadedAudioFilesArrayForTableView objectAtIndex:row];
                    
                    cell.textField.stringValue = [NSString stringWithFormat:@"%@", audioFile.status];
                }
                else
                    if (tableColumn == self.tableView.tableColumns[4])
                    {
                        identifier = @"originalFileName";
                        
                        cell = [self.tableView makeViewWithIdentifier:identifier owner:nil];
                        
                        AudioFile* audioFile = [self.uploadedAudioFilesArrayForTableView objectAtIndex:row];
                        
                        cell.textField.stringValue = audioFile.originalFileName;
                    }
                    else
                        if (tableColumn == self.tableView.tableColumns[5])
                        {
                            identifier = @"originalFileNamePath";
                            
                            cell = [self.tableView makeViewWithIdentifier:identifier owner:nil];
                            
                            AudioFile* audioFile = [self.uploadedAudioFilesArrayForTableView objectAtIndex:row];
                            
                            cell.textField.stringValue = audioFile.originalFileNamePath;
                        }
    
    
    
    
    
    
    return cell;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.uploadedAudioFilesArrayForTableView.count;
}

#pragma mark: Storyboard Actions

- (IBAction)pasteAudioFilesButtonClicked:(id)sender
{
//    NSData* bookmarkData = [[NSUserDefaults standardUserDefaults] objectForKey:@"bookmark"];
//    NSURL* urlFromBookmark = [NSURL URLByResolvingBookmarkData:bookmarkData
//                                                       options:NSURLBookmarkResolutionWithSecurityScope
//                                                 relativeToURL:nil
//                                           bookmarkDataIsStale:nil
//                                                         error:nil];


//    NSString* uploadFilesFolderPath = urlFromBookmark.path;

//    NSString* uploadFilesFolderPath = [[AppPreferences sharedAppPreferences] getUsernameUploadAudioDirectoryPath];
    
//    [self openFolderInFinder:uploadFilesFolderPath];
    
    BOOL isCubeFilesFolderGenerated = [[NSUserDefaults standardUserDefaults] boolForKey:DOWNLOAD_FOLDER_BOOKMARK_GENERATED];

    if (isCubeFilesFolderGenerated)
    {
        NSString* uploadFilesFolderPath = [[AppPreferences sharedAppPreferences] getUsernameUploadAudioDirectoryPath];
        
        [self openFolderInFinder:uploadFilesFolderPath];
    }
    else
    {
       NSAlert* alert   = [[NSAlert alloc] init];
        
        [alert setMessageText:@"Action Required!"];
        
        [alert setInformativeText:@"You have to select or create & select CubeFiles folder first to allow Cube Agent to access files from created folder"];
        
        [alert addButtonWithTitle:@"Select OR Create & Select CubeFiles Folder"];
        
//        [alert setInformativeText:[NSString stringWithFormat:@"You need to create or select Downloads/CubeFiles/%@/UploadAudio folder first to allow Cube Agent to access files from UploadAudio folder", [AppPreferences sharedAppPreferences].loggedInUser.userName]];
//
//         [alert addButtonWithTitle:[NSString stringWithFormat:@"Select or Create Downloads/CubeFiles/%@/UploadAudio Folder",[AppPreferences sharedAppPreferences].loggedInUser.userName]];
        
        [alert addButtonWithTitle:@"Cancel"];

        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSAlertFirstButtonReturn) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self bookmark:@"upload"];


                });

            }
            else if (NSAlertSecondButtonReturn)
            {
                return;
            }
        }];
    }
   
}

- (IBAction)getDownloadedFilesButtonClicked:(id)sender
{
   
    BOOL isCubeFilesFolderGenerated = [[NSUserDefaults standardUserDefaults] boolForKey:DOWNLOAD_FOLDER_BOOKMARK_GENERATED];

    if (isCubeFilesFolderGenerated)
    {
        NSString* downloadedTransFolderPath = [[AppPreferences sharedAppPreferences] getUsernameTranscriptionDirectoryPath];
        
        [self openFolderInFinder:downloadedTransFolderPath];
    }
    else
    {
        NSAlert* alert   = [[NSAlert alloc] init];
        
        [alert setMessageText:@"Action Required!"];
        
        [alert setInformativeText:@"You have to select or create & select CubeFiles folder first to allow Cube Agent to access files from created folder"];
        
        [alert addButtonWithTitle:@"Select OR Create & Select CubeFiles Folder"];
//         [alert setInformativeText:[NSString stringWithFormat:@"You need to create or select Downloads/CubeFiles/%@/Transcription folder first to allow Cube Agent to save files in Transcription folder", [AppPreferences sharedAppPreferences].loggedInUser.userName]];
//
//        [alert addButtonWithTitle:[NSString stringWithFormat:@"Select or Create Downloads/CubeFiles/%@/Transcription Folder",[AppPreferences sharedAppPreferences].loggedInUser.userName]];

        [alert addButtonWithTitle:@"Cancel"];

        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSAlertFirstButtonReturn) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self bookmark:@"download"];


                });

            }
            else if (NSAlertSecondButtonReturn)
            {
                return;
            }
        }];
    }
}

- (IBAction)getBackupFilesButtonClicked:(id)sender
{
    BOOL isCubeFilesFolderGenerated = [[NSUserDefaults standardUserDefaults] boolForKey:DOWNLOAD_FOLDER_BOOKMARK_GENERATED];

    if (isCubeFilesFolderGenerated)
    {
        NSString* backupFolderPath = [[AppPreferences sharedAppPreferences] getUsernameBacupAudioDirectoryPath];
        
        [self openFolderInFinder:backupFolderPath];
    }
    else
    {
        NSAlert* alert   = [[NSAlert alloc] init];
        
        [alert setMessageText:@"Action Required!"];
        
        [alert setInformativeText:@"You have to select or create & select CubeFiles folder first to allow Cube Agent to access files from created folder"];
        
        [alert addButtonWithTitle:@"Select OR Create & Select CubeFiles Folder"];
//        [alert setInformativeText:[NSString stringWithFormat:@"You need to create or select Downloads/CubeFiles/%@/BackupAudio folder first to allow Cube Agent to backup files in BackupAudio folder", [AppPreferences sharedAppPreferences].loggedInUser.userName]];
//
//        [alert addButtonWithTitle:[NSString stringWithFormat:@"Select or Create Downloads/CubeFiles/%@/BackupAudio Folder",[AppPreferences sharedAppPreferences].loggedInUser.userName]];
        
        [alert addButtonWithTitle:@"Cancel"];
        
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSAlertFirstButtonReturn) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self bookmark:@"backup"];
                    
                    
                });
                
            }
            else if (NSAlertSecondButtonReturn)
            {
                return;
            }
        }];
    }
}

-(void)bookmark:(NSString*)createdByButton
{
//    NSOpenPanel *  panel;
    
//    panel = [NSOpenPanel openPanel];
//    panel.canChooseDirectories = YES;
//    panel.allowsMultipleSelection = NO;
//    panel.canChooseFiles = NO;

    openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setCanCreateDirectories:YES];
    [openDlg setAllowsMultipleSelection:FALSE];
    [openDlg setPrompt:@"Select"];
    if ( [openDlg runModal] == NSModalResponseOK )
    {
        NSURL *url = openDlg.URL;

        NSError *error = nil;
        NSData *bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope
                         includingResourceValuesForKeys:nil
                                          relativeToURL:nil
                                                  error:&error];
        if (bookmark != nil)
        {


            NSURL* urlFromBookmark = [NSURL URLByResolvingBookmarkData:bookmark
                                                               options:NSURLBookmarkResolutionWithSecurityScope
                                                         relativeToURL:nil
                                                   bookmarkDataIsStale:nil
                                                                 error:&error];

            NSString* selectedPath = urlFromBookmark.path;

            NSString* lastPathComponent = [selectedPath lastPathComponent];

//            if( !([@"CubeFiles" caseInsensitiveCompare:lastPathComponent] == NSOrderedSame) )
            if (![@"CubeFiles" isEqualToString: lastPathComponent])
            {
                [[AppPreferences sharedAppPreferences] showAlertWithTitle:@"Alert" subTitle:@"Please Select OR Create & Select CubeFiles Folder in choosed location"];

                return;
            }
            else
            {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:bookmark forKey:DOWNLOAD_FOLDER_BOOKMARK_PATH];
                [userDefaults synchronize];

                //                NSData* bookmarkData = [userDefaults objectForKey:@"bookmark"];

                [[NSUserDefaults standardUserDefaults] setBool:true forKey:DOWNLOAD_FOLDER_BOOKMARK_GENERATED];

//                NSString* downloadedTransFolderPath = [[AppPreferences sharedAppPreferences] getUsernameTranscriptionDirectoryPath];
//
//                [self openFolderInFinder:downloadedTransFolderPath];
                [[AppPreferences sharedAppPreferences] createAllFolderOnce];

               // [[AppPreferences sharedAppPreferences] showAlertWithTitle:@"Folder Created Successfully" subTitle:@"Please keep your audio files inside Downloads/CubeFiles/UploadAudio"];

                // ---> changing folder path in Alert

                 NSString * pathToCubeLogStr = [NSString stringWithFormat:@"Please keep your audio files inside %@/%@/UploadAudio folder",selectedPath,[AppPreferences sharedAppPreferences].loggedInUser.userName];

//                NSString * pathToCubeLogStr = [@"Please keep your audio files inside Downloads/CubeFiles/" stringByAppendingString:[AppPreferences sharedAppPreferences].loggedInUser.userName];

                 [[AppPreferences sharedAppPreferences] showAlertWithTitle:@"Folder Created Successfully" subTitle: pathToCubeLogStr];

                 self.checkingFilesLabel.stringValue = @"Checking Files..";

            }
            NSLog(@"url = %@", urlFromBookmark);
        }
        else
        {
            //check the error
        }


    }
}
#pragma mark: Outline View Datasource and Delegates



- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item

{
   
    if (item == nil) { //item is nil when the outline view wants to inquire for root level items
       
        return [list count];
       
    }
  
    if ([item isKindOfClass:[NSDictionary class]]) {
       
        return [[item objectForKey:@"children"] count];
    
    }
    
    return 0;
    
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
   
    if (item == nil) { //item is nil when the outline view wants to inquire for root level items
  
        return [list objectAtIndex:index];
 
    }

    

    if ([item isKindOfClass:[NSDictionary class]]) {
      
//        return [[item objectForKey:@"children"] objectAtIndex:index];

        return [item objectForKey:@"children"];

    }
 
    

    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item

{
    
//    if ([item isKindOfClass:[NSDictionary class]] || [item isKindOfClass:[NSArray class]])
//    {
//
//        return YES;
//
//    }
//    else
//    {
//
//        return NO;
//
//    }

    if ([item isKindOfClass:[NSDictionary class]])
    {
        if ([[item objectForKey:@"children"] isKindOfClass:[NSArray class]])
        {
            return false;
        }
        else
        {
            return YES;
        }
        
        
        
    }
    else
    {
        
        return NO;
        
    }
}

-(NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    NSTableCellView* view;
    if ([tableColumn.identifier isEqualToString:@"name"])
    {
        view = [outlineView makeViewWithIdentifier:@"children" owner:self];

//        view.frame = NSRectFromCGRect(CGRectMake(0, 0, 100, 10));
        if (CubeFilesFolderPath == nil)
        {
            CubeFilesFolderPath = [[AppPreferences sharedAppPreferences] getCubeFilesFolderPathUsingBookmark];

        }
        
        if (CubeFilesFolderPath == nil)
        {
            return view;
        }
//        NSString* cubeFilesFolder = [CubeFilesFolderPath lastPathComponent];
//
//        if (pathComponents == nil || pathComponents.count == 0)
//        {
//           pathComponents = [CubeFilesFolderPath pathComponents];
//
//           [pathComponents removeObject:@"/"];
//
//
//        }
        
        
//        NSString* systemFilesFolder = [CubeFilesFolderPath lastPathComponent];

        if ([item isKindOfClass:[NSDictionary class]])
        {
            view.textField.stringValue = [pairingDict objectForKey:item];
        }
//        else
//        {
//
//            view.textField.stringValue = @"last";
//
//        }
        
//        [pathComponents removeObjectAtIndex:0];
    }
    return view;
}
-(NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item
{
    NSTableRowView* view;
   
    view = [outlineView makeViewWithIdentifier:@"row" owner:self];
    
     view.frame = NSRectFromCGRect(CGRectMake(0, 0, 100, 10));
    
    return view;
}

// ---> Defining setBackgroundColorOFButtonsAndView method
-(void) setBackgroundColorOFButtonsAndView
{
    [self.pasteAudioFileButton setBordered:NO];
    
    [self.pasteAudioFileButton setWantsLayer:YES];
    
    self.pasteAudioFileButton.layer.cornerRadius = 5;
    
    self.pasteAudioFileButton.layer.backgroundColor = [NSColor colorWithCalibratedRed:0.220f green:0.514f blue:0.827f alpha:1.0f].CGColor;
    
    [self.getDownloadFileButton setBordered:NO];
    
    [self.getDownloadFileButton setWantsLayer:YES];
    
    self.getDownloadFileButton.layer.cornerRadius = 5;
    
    self.getDownloadFileButton.layer.backgroundColor = [NSColor colorWithCalibratedRed:0.220f green:0.514f blue:0.827f alpha:1.0f].CGColor;
    
    [self.backupFileButton setBordered:NO];
    
    [self.backupFileButton setWantsLayer:YES];
    
    self.backupFileButton.layer.cornerRadius = 5;
    
    self.backupFileButton.layer.backgroundColor = [NSColor colorWithCalibratedRed:0.220f green:0.514f blue:0.827f alpha:1.0f].CGColor;
    
    [self.homeBackgroundView setWantsLayer:YES];
    
    //    self.submitButton.layer.cornerRadius = 8;
    self.homeBackgroundView.layer.backgroundColor = [NSColor colorWithCalibratedRed:255.0f green:255.0f blue:255.0f alpha:1.0f].CGColor;
    
}




//-(NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item
//{
//    
//    NSTableCellView* row = [outlineView makeViewWithIdentifier:@"children" owner:self];
//    
//    return row;
//}
//- (id)outlineView:(NSOutlineView *)outlineView
//            child:(NSInteger)index
//           ofItem:(id)item// returns the data to be display
//{
//    // 2 child of item to acces sequentially, first time item will be null hence return the first object of root array
//    if(item == nil) {
//        return [dataSource objectAtIndex:index];
//    }
//    else {
//        return [[item valueForKey:@"children"] objectAtIndex:index];
//    }
//    return nil;
//
//}
//
//- (BOOL)outlineView:(NSOutlineView *)outlineView
//   isItemExpandable:(id)item
//{
//    // 3 check accessed item is collapsable or not
//    if([[item valueForKey:@"children"] count]>0) return YES;
//
//    return NO;
//
//}
//
//- (NSInteger)outlineView:(NSOutlineView *)outlineView
//  numberOfChildrenOfItem:(id)item
//{
//    // 1 number of children of item, first time it will return 1 in our case
//    if (item == nil)
//    {
//         return [dataSource count];
//    }
//   long count = [[item valueForKey:@"children"] count];
//    return [[item valueForKey:@"children"] count];
////        return [[item valueForKey:@"children"] count];
//
//}

//1. numberOfChildrenOfItem will be called wit item = nil and when it is nill return our main datasurce items count
//2. now we have the count of numberofchildren of our main datasource item(since item was nil count = datasource count itself), now we will
//   find the children of that item but since item was first time nil, we will return the first item of datatsource.
// 3. now check if item is expandable, if yes again numberofchildrenOfItem will be called and process will be repeat

//- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)theColumn byItem:(id)item
//{
//
//
//
//    if ([[theColumn identifier] isEqualToString:@"name"]) { // in the column "children"...
//
//        if ([item isKindOfClass:[NSDictionary class]]) { // if we have a dictionary...
//
//            // ... then write something informative in the header (number of kids + "kids")...
//
//            return [NSString stringWithFormat:@"%li kids",[[item objectForKey:@"children"] count]];
//
//        }
//
//        return item; // ...and, if we actually have a value, return the value
//
//    } else {
//
//        if ([item isKindOfClass:[NSDictionary class]]) { // in the "parent" column
//
//            return [item objectForKey:@"parent"]; // just write the value for the @parent keys
//
//        }
//
//    }
//
//
//
//    return nil; // if shit happens, don't blame it on me !
//
//}


- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
                           inDomain:(NSSearchPathDomainMask)domainMask
                appendPathComponent:(NSString *)appendComponent
                              error:(NSError **)errorOut
{
    // Search for the path
    NSArray* paths = NSSearchPathForDirectoriesInDomains(
                                                         searchPathDirectory,
                                                         domainMask,
                                                         YES);
    if ([paths count] == 0)
    {
        // *** creation and return of error object omitted for space
        return nil;
    }
    
    // Normally only need the first path
    NSString *resolvedPath = [paths objectAtIndex:0];
    
    if (appendComponent)
    {
        resolvedPath = [resolvedPath
                        stringByAppendingPathComponent:appendComponent];
    }
    
    // Create the path if it doesn't exist
    NSError *error;
    BOOL success = [[NSFileManager defaultManager]
                    createDirectoryAtPath:resolvedPath
                    withIntermediateDirectories:YES
                    attributes:nil
                    error:&error];
    if (!success)
    {
        if (errorOut)
        {
            *errorOut = error;
        }
        return nil;
    }
    
    // If we've made it this far, we have a success
    if (errorOut)
    {
        *errorOut = nil;
    }
    return resolvedPath;
}

- (NSString *)applicationSupportDirectory
{
    NSString *executableName =
    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    NSError *error;
    NSString *result =
    [self
     findOrCreateDirectory:NSApplicationSupportDirectory
     inDomain:NSUserDomainMask
     appendPathComponent:executableName
     error:&error];
    if (error)
    {
        NSLog(@"Unable to find or create application support directory:\n%@", error);
    }
    return result;
}

@end

