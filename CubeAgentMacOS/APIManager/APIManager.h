//
//  APIManager.h
//  Communicator
//
//  Created by mac on 05/04/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+AES256.h"
@interface APIManager : NSObject<NSURLSessionDelegate,NSURLSessionTaskDelegate,NSURLSessionDataDelegate>
{
    NSDictionary* result;
    NSString* filnameString;
    NSURLSessionUploadTask* uploadTask;
   
}

+(APIManager *) sharedManager;

//@property(nonatomic,strong) NSMutableArray* inCompleteFileTransferNamesArray;
//@property(nonatomic,strong) NSMutableArray* awaitingFileTransferNamesArray;
//@property(nonatomic,strong) NSMutableArray* todaysFileTransferNamesArray;
//@property(nonatomic,strong) NSMutableArray* failedTransferNamesArray;
//
//@property(nonatomic,strong) NSMutableArray* deletedListArray;
//@property(nonatomic,strong) NSMutableArray* transferredListArray;
//
//@property(nonatomic)int awaitingFileTransferCount;
//@property(nonatomic)int todaysFileTransferCount;
//@property(nonatomic)int transferFailedCount;
//@property(nonatomic)int incompleteFileTransferCount;
//@property(nonatomic)bool  userSettingsOpened;
//@property(nonatomic)bool  userSettingsClosed;

@property(nonatomic)NSMutableDictionary* responsesData;
@property(nonatomic,strong)NSString* taskId;
@property(nonatomic,strong)NSURLSessionUploadTask* uploadTask;
@property(nonatomic,strong)NSURLSession* session;
//-(void) validateUser:(NSString *) usernameString andPassword:(NSString *) passwordString;

-(void) updateDeviceMacID:(NSString*) macID password:(NSString*) password username:(NSString* )username;

-(void) authenticateUser:(NSString*) password username:(NSString* )username;

-(void) getCubeConfig:(NSString*) userId;

-(void) getAudioFileExtensions;

-(void) getTransCompanyName:(NSString*) tcId;

-(void) getEncryptDecryptString;

-(void) setVCID:(NSString*) userId;

-(void) getSingleQueryValueComment:(NSString*) comment;

-(void) checkDuplicateAudioForDay:(NSString*) userid originalFileName:(NSString* )filename;

-(void) updateDownloadFileStatus:(NSString*) status dictationId:(NSString* )dictationId;

-(void) FTPGetTCIdView:(NSString*) userId  originalFileName:(NSString* )filename;


-(void) uploadFile:(NSString*) data;

-(void) getBrowserAudioFilesForDownload:(NSString*) userId;

-(void) getDicatationIds:(NSString*) userId;

-(void) downloadFile:(NSString*) dictationId;

-(void) getDictatorsFolder:(NSString*) userId;

-(void) generateFilenameDictationId:(NSString*) DictationId userId:(NSString*)userId;


-(NSString*)getMacId;//get macid of current device

-(uint64_t)getFreeDiskspace;

-(void)uploadFileAfterGettingdatabaseValues:(NSString*)filename dictatorId:(long)dictatorId FTPAudioPath:(NSString*)FTPAudioPath strInHouse:(int)strInHouse clinicName:(NSString*)clinicName userId:(long)userId dictatorFirstName:(NSString*)dictatorFirstName tcId:(long)tcId vcId:(long)vcId filePath:(NSString*)filePath;








//-(void)uploadFileFilename:(NSString*)filename macID:(NSString*)macID fileSize:(NSString*)filesize;


-(NSString*)getDateAndTimeString;


-(BOOL)deleteFile:(NSString*)fileName;

-(void)uploadFileToServer:(NSString*)str;





@end
