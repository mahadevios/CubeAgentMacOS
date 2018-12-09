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

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.uploadedAudioFilesArrayForTableView = [NSMutableArray new];
    
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
                                             selector:@selector(validateVCIDViewReponse:) name:NOTIFICATION_FTP_SET_VC_ID_VERIFY_API
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateFileUploadReponse:) name:NOTIFICATION_FILE_UPLOAD_API
                                               object:nil];
    
    NSString* StrSQL = [NSString stringWithFormat:@"Select d.DictatorFirstName  + ' ' + d.DictatorLastName as DictatorFullName from Users a inner join Clinics b on a.ParentCompanyID=b.ClinicID INNER JOIN Dictators d on d.DictatorID=a.UserID WHERE a.UserID=%ld",[AppPreferences sharedAppPreferences].loggedInUser.userId];
  
    [[APIManager sharedManager] setVCID:[NSString stringWithFormat:@"%ld",[AppPreferences sharedAppPreferences].loggedInUser.userId]];
    
    [[APIManager sharedManager] getSingleQueryValueComment:StrSQL];

//    [self getFilesToBeUploadFromUploadFilesFolder];

    CGSize size =  CGSizeMake(900, 770);
    
    self.preferredContentSize = size;

    [self checkForFilesFirstTimeAfterLoginRapidTimer];
//    [[APIManager sharedManager] getEncryptDecryptString];
}

#pragma mark : Notification Callback Methods

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
        
        [listOfAudioFilesToUploadDict removeObjectForKey:[[audioFileName lastPathComponent] lastPathComponent]];
        
        // move audio to backup path
        // remove object and key from dictionary and check if dictioanry count is 0, if yes start the timer to upload next files
    }
    NSLog(@"");
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

-(void)validateFileUploadReponse:(NSNotification*)notification
{
    NSDictionary* dict =  notification.object;
    
    
    AudioFile* audioFileObject = [dict objectForKey:@"audioFileObject"];

    NSString* isUploaded = audioFileObject.status;

    [AppPreferences sharedAppPreferences].totalUploadedCount = [AppPreferences sharedAppPreferences].totalUploadedCount + 1;
    
    if ([isUploaded  isEqual: @"uploaded"])
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
    
    if ([AppPreferences sharedAppPreferences].nextToBeUploadedPoolArray.count > 0)
    {
        NSBlockOperation* nextOperation = [[AppPreferences sharedAppPreferences].nextToBeUploadedPoolArray objectAtIndex:0];
        
        [[AppPreferences sharedAppPreferences].audioUploadQueue addOperation:nextOperation];
        
        [[AppPreferences sharedAppPreferences].nextToBeUploadedPoolArray  removeObjectAtIndex:0];
        
    }
    else
    {
        if ([AppPreferences sharedAppPreferences].nextToBeUploadedPoolArray.count == 0)
        {
            
            [progressTimer invalidate];
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                 self.uploadingCountLabel.stringValue = [NSString stringWithFormat:@"Uploaded %lu of %lu", (unsigned long)[AppPreferences sharedAppPreferences].uploadFilesQueueCount,(unsigned long)[AppPreferences sharedAppPreferences].uploadFilesQueueCount];
                
                [self performSelector:@selector(updateUploadedFileAndQueueCount:) withObject:nil afterDelay:3.0];
                
                
//                self.uploadingCountLabel.stringValue = @"";

                
            });
            
           
            
            [self checkForNewFilesSubSequentTimer];
        }
    }
    
    [self.uploadedAudioFilesArrayForTableView addObject:audioFileObject];

    [self.tableView reloadData];
    
   
}

-(void)updateUploadedFileAndQueueCount:(id)obj
{
    [AppPreferences sharedAppPreferences].totalUploadedCount = 1;
    
    [AppPreferences sharedAppPreferences].uploadFilesQueueCount = 0;
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
    
    uint64_t fileSize = [[AppPreferences sharedAppPreferences] getFileSize:filePath];

    [AppPreferences sharedAppPreferences].audioUploadQueue.maxConcurrentOperationCount = 1;
    
    NSOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        DownloadMetaDataJob* job = [DownloadMetaDataJob new];
        AudioFile* audioFile = [AudioFile new];
        audioFile.fileName = audioFileName;
        audioFile.originalFileNamePath = filePath;
        audioFile.originalFileName = audioFileName;
        audioFile.fileSize = fileSize;
        job.audioFileObject = audioFile;
        [job uploadFileAfterGettingdatabaseValues:self->tcIdList vcList:self->vcIdList audioFile:audioFile];
        
    }];
    
    
    if ([AppPreferences sharedAppPreferences].audioUploadQueue.operationCount < 1)
    {
        [[AppPreferences sharedAppPreferences].audioUploadQueue addOperation:blockOperation];
    }
    else
    {
        [[AppPreferences sharedAppPreferences].nextToBeUploadedPoolArray addObject:blockOperation];
    }
    
    // get the count of total files to upload to show on view ( uploading 2 0f uploadFilesQueueCount )
    [AppPreferences sharedAppPreferences].uploadFilesQueueCount = [AppPreferences sharedAppPreferences].uploadFilesQueueCount + 1;
    
    if (!progressTimer.isValid)
    {
        [self startFileUploadProgressBarTimer];

    }

}

-(void)performCleanUp:(NSString*)audioFilePath
{
    NSString* audioFileName = [audioFilePath lastPathComponent];
    
    // delete the encypted file
    [[AppPreferences sharedAppPreferences] deleteFileAtPath:audioFilePath];
    
    // remove object from dictionary
    //    [listOfAudioFilesToUploadDict removeObjectForKey:audioFileName];
    
    // move file to backup
    [[AppPreferences sharedAppPreferences] moveAudioFileToBackup:audioFilePath];
    
    // if dict.count value is 0 start the upload timer
    if (listOfAudioFilesToUploadDict.count == 0)
    {
        // retsart the timer to upload audio
    }
    
    
}

#pragma mark: Timer And Methods

-(void)checkForFilesFirstTimeAfterLoginRapidTimer
{
    checkForNewFilesTimer =  [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(checkForNewFilesForFirstTime) userInfo:nil repeats:YES];
    
}

-(void)checkForNewFilesForFirstTime
{
    [self getFilesToBeUploadFromUploadFilesFolder];
}

-(void)checkForNewFilesSubSequentTimer
{
    if (checkForNewFilesTimer != nil)
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
        self.uploadingCountLabel.stringValue = [NSString stringWithFormat:@"Uploading %ld of %lu", [AppPreferences sharedAppPreferences].totalUploadedCount,(unsigned long)[AppPreferences sharedAppPreferences].uploadFilesQueueCount];
    }
    else
        if (([AppPreferences sharedAppPreferences].totalUploadedCount >= [AppPreferences sharedAppPreferences].uploadFilesQueueCount))
        {
            self.uploadingCountLabel.stringValue = [NSString stringWithFormat:@"Uploaded %lu of %lu", (unsigned long)[AppPreferences sharedAppPreferences].uploadFilesQueueCount,(unsigned long)[AppPreferences sharedAppPreferences].uploadFilesQueueCount];
        
        }
    
    [self.progressIndicator setDoubleValue:[AppPreferences sharedAppPreferences].currentUploadingPercentage];
}

#pragma mark: Supportive Methods
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
    
    if (listOfAudioFilesToUploadDict.count > 0)
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
            
            [checkForNewFilesTimer invalidate];
            
            
            
            NSString* fileSubPath = [listOfAudioFilesToUploadDict objectForKey:filename];
            
            
            [[APIManager sharedManager] checkDuplicateAudioForDay:[NSString stringWithFormat:@"%ld", [AppPreferences sharedAppPreferences].loggedInUser.userId] originalFileName:fileSubPath];
            //        }
        }
    }
    else
    {
        self.checkingFilesLabel.stringValue = @"Finished Checking Files.";

    }
   
    NSLog(@"directoryContents ====== %@",@"ds");

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
                
                cell.textField.stringValue = [NSString stringWithFormat:@"%ld", audioFile.totalBytesSent];
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

