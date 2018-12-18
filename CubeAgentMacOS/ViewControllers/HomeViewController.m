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
    
    self.uploadedAudioFilesArrayForTableView = [NSMutableArray new];
    
//    self.queueAudioFilesArrayForTableView = [NSMutableArray new];
    
    self.dictationIdsArrayForDownload = [NSMutableArray new];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(validateSingleQueryReponse:) name:NOTIFICATION_GET_SINGLE_QEURY_EXECUTE_QUERY_API
//                                               object:nil];
    
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
    
    
//    NSString* StrSQL = [NSString stringWithFormat:@"Select d.DictatorFirstName  + ' ' + d.DictatorLastName as DictatorFullName from Users a inner join Clinics b on a.ParentCompanyID=b.ClinicID INNER JOIN Dictators d on d.DictatorID=a.UserID WHERE a.UserID=%ld",[AppPreferences sharedAppPreferences].loggedInUser.userId];
  
    [[APIManager sharedManager] setVCID:[NSString stringWithFormat:@"%ld",[AppPreferences sharedAppPreferences].loggedInUser.userId]];
    
//    [[APIManager sharedManager] getSingleQueryValueComment:StrSQL];

//    [self getFilesToBeUploadFromUploadFilesFolder];

    CGSize size =  CGSizeMake(900, 770);
    
    self.preferredContentSize = size;

    [self checkForFilesFirstTimeAfterLoginRapidTimer];
//    [[APIManager sharedManager] getEncryptDecryptString];
//    [[APIManager sharedManager] getDictatorsFolder:[NSString stringWithFormat:@"%ld",[AppPreferences sharedAppPreferences].loggedInUser.userId]];
    
//    [self getDictationIds];
    
    [self testLogs];
}

-(void)testLogs
{
//    setenv("XcodeColors", "YES", 0);
//
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    NSString* logDirectoryPath = [[AppPreferences sharedAppPreferences] getCubeLogDirectoryPath];
    
    DDLogFileManagerDefault *logManager = [[BaseLogFileManager alloc] initWithLogsDirectory:logDirectoryPath];
    
    DDFileLogger * file = [[DDFileLogger alloc] initWithLogFileManager:logManager];
    
    [DDLog addLogger:file];
    // And we also enable colors
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    // setup the text view logger
    UITextViewLogger *textViewLogger = [UITextViewLogger new];
    
    textViewLogger.autoScrollsToBottom = YES;

    [DDLog addLogger:textViewLogger];
    
    textViewLogger.textView = self.logTextView;
    
}
#pragma mark : Notification Callback Methods

-(void)validateDictatorsFolderReponse:(NSNotification*)notification
{
    NSDictionary* responseDict = notification.object;
    
     DDLogInfo(@"%@",responseDict);
}

-(void)validateGenerateFileNameReponse:(NSNotification*)notification
{
    NSDictionary* responseDict = notification.object;

    DDLogInfo(@"%@",responseDict);

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
            DDLogInfo(@"File size is too big to upload");

        }
        else
        {
            if ([AppPreferences sharedAppPreferences].isReachable)
            {
                 [[APIManager sharedManager] FTPGetTCIdView:[NSString stringWithFormat:@"%ld",[AppPreferences sharedAppPreferences].loggedInUser.userId] originalFileName:audioFileName];
            }
            else
            {
                // if internet not reachable and no file is in queue to upload or download queue then start the cycle again
                if ([AppPreferences sharedAppPreferences].nextBlockToBeUploadPoolArray.count < 1 || [AppPreferences sharedAppPreferences].nextBlockToBeDownloadPoolArray.count < 1 || [AppPreferences sharedAppPreferences].audioUploadQueue.operationCount < 1 || [AppPreferences sharedAppPreferences].docDownloadQueue.operationCount < 1)
                {
                    [self checkForNewFilesSubSequentTimer];
                }
            }
           
        }
    }
    else
    {
        DDLogInfo(@"Duplicate file found, file name = %@",audioFileName);

        DDLogInfo(@"Moving duplicate audio file to backup folder");

        [self performCleanUp:audioFileName];
        
        [listOfAudioFilesToUploadDict removeObjectForKey:[[audioFileName lastPathComponent] lastPathComponent]];
       
        // if internet not reachable and no file is in queue to upload or download queue then start the cycle again
        if (![AppPreferences sharedAppPreferences].isReachable && ([AppPreferences sharedAppPreferences].nextBlockToBeUploadPoolArray.count < 1 || [AppPreferences sharedAppPreferences].nextBlockToBeDownloadPoolArray.count < 1 || [AppPreferences sharedAppPreferences].audioUploadQueue.operationCount < 1 || [AppPreferences sharedAppPreferences].docDownloadQueue.operationCount < 1))
        {
            [self checkForNewFilesSubSequentTimer];
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
}

-(void)validateVCIDViewReponse:(NSNotification*)notification
{
    DDLogInfo(@"VC info received");

    NSDictionary* responseString = notification.object;
    
    NSArray* verifyArray = [responseString valueForKey:@"SetTCID_Verifylist"];
    
    NSDictionary* verifyDict = [verifyArray objectAtIndex:0];
    
    
    vcIdList = [[VCIdList alloc] init];
    
    //    vcIdList.AutoOutsourceTime =  [[verifyDict valueForKey:@"AutoOutsourceTime"] intValue];
    vcIdList.Inhouse =  [[verifyDict valueForKey:@"Inhouse"] intValue];
    vcIdList.TCID =  [[verifyDict valueForKey:@"TCID"] intValue];
    vcIdList.VCID =  [[verifyDict valueForKey:@"VCID"] intValue];
    vcIdList.verify =  [[verifyDict valueForKey:@"Verify"] boolValue];
    
}

-(void)validateTCIDViewReponse:(NSNotification*)notification
{
    // if internet not reachable and no file is in queue to upload or download queue then start the cycle again

     if (![AppPreferences sharedAppPreferences].isReachable && ([AppPreferences sharedAppPreferences].nextBlockToBeUploadPoolArray.count < 1 || [AppPreferences sharedAppPreferences].nextBlockToBeDownloadPoolArray.count < 1 || [AppPreferences sharedAppPreferences].audioUploadQueue.operationCount < 1 || [AppPreferences sharedAppPreferences].docDownloadQueue.operationCount < 1))
     {
         [self checkForNewFilesSubSequentTimer];
     }
    else
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
            
            [job uploadFileAfterGettingdatabaseValues:self->tcIdList vcList:self->vcIdList audioFile:audioFile];
            
        }];
        
        
        if ([AppPreferences sharedAppPreferences].audioUploadQueue.operationCount < 1)
        {
            // set row count of audio file so that we can reload bytes sent column later
            int tableViewRowCount = totalFilesToBeAddedInTableView;
            
            audioFile.rowNumber = tableViewRowCount;
            
            
            [self.uploadedAudioFilesArrayForTableView addObject:audioFile];
            
            NSIndexSet* rowIndexSet = [[NSIndexSet alloc] initWithIndex:totalFilesToBeAddedInTableView];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView insertRowsAtIndexes:rowIndexSet withAnimation:NSTableViewAnimationEffectNone];
                
            });
            //        [self.tableView reloadData];
            
            ++totalFilesToBeAddedInTableView;
            
            [[AppPreferences sharedAppPreferences].audioUploadQueue addOperation:blockOperation];
            
            
        }
        else
        {
            // set row count (to queued + 1) of audio file so that we can reload bytes sent column later
            int tableViewRowCount = totalFilesToBeAddedInTableView;
            
            audioFile.rowNumber = tableViewRowCount;
            
            audioFile.status = @"In Queue";
            
            
            [self.uploadedAudioFilesArrayForTableView addObject:audioFile];
            //
            NSIndexSet* rowIndexSet = [[NSIndexSet alloc] initWithIndex:totalFilesToBeAddedInTableView];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView insertRowsAtIndexes:rowIndexSet withAnimation:NSTableViewAnimationEffectNone];
                
                ++self->totalFilesToBeAddedInTableView;
                
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
    
    [AppPreferences sharedAppPreferences].totalUploadedCount = [AppPreferences sharedAppPreferences].totalUploadedCount + 1;
    
    if ([isUploaded  isEqual: @"Uploaded"])
    {
        [self performCleanUp:audioFileObject.originalFileNamePath];
        
        // remove object from dictionary
        [listOfAudioFilesToUploadDict removeObjectForKey:audioFileObject.fileName];
        
    }
    else
    {
        [self performCleanUp:audioFileObject.originalFileNamePath];
        
        [listOfAudioFilesToUploadDict removeObjectForKey:audioFileObject.fileName];
        
    }
    
    if ([AppPreferences sharedAppPreferences].nextBlockToBeUploadPoolArray.count > 0)
    {
        NSBlockOperation* nextOperation = [[AppPreferences sharedAppPreferences].nextBlockToBeUploadPoolArray objectAtIndex:0];
        
        //       [self.uploadedAudioFilesArrayForTableView addObject:[self.queueAudioFilesArrayForTableView objectAtIndex:0]];
        
        // to update the status "uploaded" in tableview
        for (int i = audioFileObject.rowNumber+1; i < self.uploadedAudioFilesArrayForTableView.count; i++)
        {
            AudioFile* tempFileObj = [self.uploadedAudioFilesArrayForTableView objectAtIndex:i];
            
            if ([tempFileObj.fileType isEqualToString:@"AudioUpload"])
            {
                //                AudioFile* fileObj =  [self.uploadedAudioFilesArrayForTableView objectAtIndex:i];
                
                tempFileObj.status = @"Uploading";
                
                [self.uploadedAudioFilesArrayForTableView replaceObjectAtIndex:i withObject:tempFileObj];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
                
                break;
            }
            
        }
        
        [[AppPreferences sharedAppPreferences].audioUploadQueue addOperation:nextOperation];
        
        [[AppPreferences sharedAppPreferences].nextBlockToBeUploadPoolArray  removeObjectAtIndex:0];
        
    }
    else
    {
        if ([AppPreferences sharedAppPreferences].nextBlockToBeUploadPoolArray.count == 0)
        {
            
            [progressTimer invalidate];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.uploadingCountLabel.textColor = [NSColor colorWithRed:92/255.0 green:168/255.0 blue:48/255.0 alpha:1.0];
                
                self.uploadingCountLabel.stringValue = [NSString stringWithFormat:@"Uploaded %lu of %lu", (unsigned long)[AppPreferences sharedAppPreferences].uploadFilesQueueCount,(unsigned long)[AppPreferences sharedAppPreferences].uploadFilesQueueCount];
                
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
            
            for (int i =0; i < responseArray.count; i++)
            {
                NSDictionary* response = [responseArray objectAtIndex:0];
                
                AudioFile* audioFile = [AudioFile new];
                
                audioFile.status = @"Downloaded";
                
                audioFile.fileName = [response valueForKey:@"FileName"];
                
                audioFile.fileSize = [[response valueForKey:@"FileSize"] longLongValue];
                
                audioFile.originalFileName = [response valueForKey:@"OriginalFileName"];
                
                NSString* backupDirectoryPath = [[AppPreferences sharedAppPreferences] getUsernameBacupAudioDirectoryPath];
                
                NSString* newFilePath = [backupDirectoryPath stringByAppendingPathComponent:audioFile.fileName];
                
                audioFile.originalFileNamePath = newFilePath;
                
                long fileSize = [[AppPreferences sharedAppPreferences] getFileSize:newFilePath];
                
                audioFile.fileSize = fileSize;
                
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
                
                BOOL isWritten = [decryptedData writeToFile:newFilePath options:NSDataWritingAtomic error:nil];
                
                bool isDeleted = [[NSFileManager defaultManager] removeItemAtURL:downloadLocation error:&error1];
                
                
                int tableViewRowCount = totalFilesToBeAddedInTableView;
                
                audioFile.rowNumber = tableViewRowCount;
                
                audioFile.fileType = @"AudioDownload";
                
                ++totalFilesToBeAddedInTableView;
                
                [self.uploadedAudioFilesArrayForTableView addObject:audioFile];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.tableView reloadData];
                    
                });
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (responseArray.count != 0)
                {
                    [self.progressIndicator setDoubleValue:100];
                    
                    self.uploadingCountLabel.stringValue = [NSString stringWithFormat:@"Downloaded %ld of %ld",responseArray.count, responseArray.count];
                }
                [self performSelector:@selector(cleanUpTableViewAfterAudioDownload) withObject:nil afterDelay:3.0];
                
                
            });
            
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self performSelector:@selector(cleanUpTableViewAfterAudioDownload) withObject:nil afterDelay:3.0];
                
            });
        }
        
    }
}


-(void)validateDictationIdsReponse:(NSNotification*)notification
{
    NSDictionary* responseDict = notification.object;
    
    NSString* dictationIdsString = [responseDict valueForKey:@"Id"];
    
    if([dictationIdsString isEqualToString:@""])
    {
        [self.dictationIdsArrayForDownload removeAllObjects];

        [self checkForNewFilesSubSequentTimer];
    }
    else
    {
        [self.dictationIdsArrayForDownload removeAllObjects];
        
        self.dictationIdsArrayForDownload = [dictationIdsString componentsSeparatedByString:@","];
        
        if (self.dictationIdsArrayForDownload.count < 1 || ![AppPreferences sharedAppPreferences].isReachable)
        {
            [self checkForNewFilesSubSequentTimer];
            
            return;
        }
        for (int i =0 ; i < self.dictationIdsArrayForDownload.count; i++)
        {
            
            NSOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
                
                [[APIManager sharedManager] downloadFile:[self.dictationIdsArrayForDownload objectAtIndex:0]];
                
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
    
    NSString* downloadStatus = [dict valueForKey:@"downloadStatus"];
    
    if ([downloadStatus isEqualToString:@"Downloaded"])
    {
        NSURL* downloadLocation = [dict valueForKey:@"downloadLocationUrl"];
        
        NSData* data = [NSData dataWithContentsOfURL:downloadLocation];
        
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
        
            NSString* transDirectoryPath = [[AppPreferences sharedAppPreferences] getUsernameTranscriptionDirectoryPath];
            
            NSString* newFilePath = [transDirectoryPath stringByAppendingPathComponent:audioFile.originalFileName];
            
            audioFile.originalFileNamePath = newFilePath;
            
            NSString* base64EncryptedString = [response valueForKey:@"FileData"];
            
            NSData *encodedData = [[NSData alloc] initWithBase64EncodedString:base64EncryptedString options:0];
            
            NSData* decryptedData = [encodedData AES256DecryptWithKey:SECRET_KEY];
            //
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:newFilePath])
            {
                [[NSFileManager defaultManager] removeItemAtPath:newFilePath error:&error1];
            }
        
            BOOL isWritten = [decryptedData writeToFile:newFilePath options:NSDataWritingAtomic error:nil];
            
            bool isDeleted = [[NSFileManager defaultManager] removeItemAtURL:downloadLocation error:&error1];
            
            long fileSize = [[AppPreferences sharedAppPreferences] getFileSize:newFilePath];
        
            audioFile.fileSize = fileSize;
        
            int tableViewRowCount = totalFilesToBeAddedInTableView;
            
            audioFile.rowNumber = tableViewRowCount;
            
            audioFile.fileType = @"DocDownload";
        
            [self.uploadedAudioFilesArrayForTableView addObject:audioFile];

            NSIndexSet* rowIndexSet = [[NSIndexSet alloc] initWithIndex:totalFilesToBeAddedInTableView];
        
            ++totalFilesToBeAddedInTableView;

            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.progressIndicator.doubleValue = 100;
                
                self.uploadingCountLabel.textColor = [NSColor colorWithRed:92/255.0 green:168/255.0 blue:48/255.0 alpha:1.0];
                
                self.uploadingCountLabel.stringValue = [NSString stringWithFormat:@"Downloaded %ld of %ld",self.uploadedAudioFilesArrayForTableView.count, self.dictationIdsArrayForDownload.count];

            [self.tableView insertRowsAtIndexes:rowIndexSet withAnimation:NSTableViewAnimationEffectNone];

                
                        });
        
        [[APIManager sharedManager] updateDownloadFileStatus:@"13" dictationId:[NSString stringWithFormat:@"%ld",dictationID]];

    }
    
    if ([AppPreferences sharedAppPreferences].nextBlockToBeDownloadPoolArray.count > 0)
    {
        if ([AppPreferences sharedAppPreferences].isReachable)
        {
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
    [AppPreferences sharedAppPreferences].totalUploadedCount = 1;
    
    [AppPreferences sharedAppPreferences].uploadFilesQueueCount = 0;
}

-(void)performCleanUp:(NSString*)audioFilePath
{
    
    // delete the encypted file
    [[AppPreferences sharedAppPreferences] deleteFileAtPath:audioFilePath];
    
    // remove object from dictionary
    //    [listOfAudioFilesToUploadDict removeObjectForKey:audioFileName];
    
    DDLogInfo(@"Audio file moved to backup folder");

    // move file to backup
    [[AppPreferences sharedAppPreferences] moveAudioFileToBackup:audioFilePath];
    
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
    
    self->totalFilesToBeAddedInTableView = 0;
    
    [self.tableView reloadData];
    
    [self checkForNewFilesSubSequentTimer];
    
}

-(void)cleanUpTableViewAfterAudioDownload
{
    [self.uploadedAudioFilesArrayForTableView removeAllObjects];
    
    self->totalFilesToBeAddedInTableView = 0;
    
    [self.tableView reloadData];
    
    [self getDictationIds];
}


-(void)cleanUpTableViewAfterAudioUpload
{
    [self.uploadedAudioFilesArrayForTableView removeAllObjects];
    
    self->totalFilesToBeAddedInTableView = 0;
    
    [self.tableView reloadData];
    
    [self checkBrowserAudioFilesForDownload];
    
    [self.progressIndicator setDoubleValue:0];
    
    self.uploadingCountLabel.stringValue = @"";
    
}
#pragma mark: Timer And Methods

-(void)checkForFilesFirstTimeAfterLoginRapidTimer
{
    checkForNewFilesTimer =  [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(checkForNewFilesForFirstTime) userInfo:nil repeats:YES];
    
    
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
        self->checkForNewFilesTimer =  [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(checkForNewFilesForSubSequentTime) userInfo:nil repeats:YES];
    });
    
    
    
    
}

-(void)checkForNewFilesForSubSequentTime
{
    self.checkingFilesLabel.stringValue = @"Checking Files...";
    
    self.checkingFilesLabel.textColor = [NSColor orangeColor];
    
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
        
        self.uploadingCountLabel.stringValue = [NSString stringWithFormat:@"Uploading %ld of %lu", [AppPreferences sharedAppPreferences].totalUploadedCount,(unsigned long)[AppPreferences sharedAppPreferences].uploadFilesQueueCount];
    }
    else
        if (([AppPreferences sharedAppPreferences].totalUploadedCount >= [AppPreferences sharedAppPreferences].uploadFilesQueueCount))
        {
            self.uploadingCountLabel.textColor = [NSColor colorWithRed:92/255.0 green:168/255.0 blue:48/255.0 alpha:1.0];
            
            self.uploadingCountLabel.stringValue = [NSString stringWithFormat:@"Uploaded %lu of %lu", (unsigned long)[AppPreferences sharedAppPreferences].uploadFilesQueueCount,(unsigned long)[AppPreferences sharedAppPreferences].uploadFilesQueueCount];
            
        }
    
    [self.progressIndicator setDoubleValue:[AppPreferences sharedAppPreferences].currentUploadingPercentage];
}
#pragma mark: Cycle Methods


-(void)getFilesToBeUploadFromUploadFilesFolder
{
    DDLogInfo(@"Checking audio files to be upload from directory");
    
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

-(void) checkBrowserAudioFilesForDownload
{
    DDLogInfo(@"Checking audio files to be download");

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
                
                
                [[APIManager sharedManager] checkDuplicateAudioForDay:[NSString stringWithFormat:@"%ld", [AppPreferences sharedAppPreferences].loggedInUser.userId] originalFileName:fileSubPath];
            }
            
        }
        else
        {
            [self checkForNewFilesSubSequentTimer];
            
            
        }
    }
    else
    {
        self.checkingFilesLabel.stringValue = @"Finished Checking Files.";

        self.checkingFilesLabel.textColor = [NSColor colorWithRed:92/255.0 green:168/255.0 blue:48/255.0 alpha:1.0];

        DDLogInfo(@"Finished checking audio file(s), no file avaliable to upload");

        DDLogInfo(@"Checked folder path = %@", [[AppPreferences sharedAppPreferences] getUsernameUploadAudioDirectoryPath]);

        [self checkBrowserAudioFilesForDownload];
    }
   
    NSLog(@"directoryContents ====== %@",@"ds");

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
        
        cell.textField.stringValue = audioFile.fileName;
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

