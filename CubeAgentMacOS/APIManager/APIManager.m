//
//  APIManager.m
//  Communicator
//
//  Created by mac on 05/04/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "APIManager.h"
#import "AppDelegate.h"
//#import "AppPreferences.h"
//#import "UIDevice+Identifier.h"
#import "NSData+AES256.h"
#import "Constants.h"
#import "SharedSession.h"
#import "DownloadMetaDataJob.h"
#import <objc/runtime.h>

@implementation APIManager
@synthesize responsesData,session;
static APIManager *singleton = nil;

// Shared method
+(APIManager *) sharedManager
{
    if (singleton == nil)
    {
        singleton = [[APIManager alloc] init];
        
        return singleton;
        //[[AppPreferences sharedAppPreferences] startReachabilityNotifier];
    }
    else
        
        
        return singleton;
}

// Init method
-(id) init
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
}

#pragma mark
#pragma mark ValidateUser API
#pragma mark

-(void) updateDeviceMacID:(NSString*) macID password:(NSString*) password username:(NSString* )username
{
    //    if ([[AppPreferences sharedAppPreferences] isReachable])
    //    {
    
    NSError* error;
    NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:macID,@"macid",password,@"pwd",username,@"username", nil];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    
    NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
    
    
    
    NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
    
    NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
    
    NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
    
    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:UPDATE_MAC_ID_API withRequestParameter:array withResourcePath:UPDATE_MAC_ID_API withHttpMethd:POST];
    [downloadmetadatajob startMetaDataDownLoad];
    //    }
    //    else
    //    {
    //
    //    }
    
}
-(void) authenticateUser:(NSString*) password username:(NSString* )username;
{
    
    NSError* error;
    NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:password,@"pwd",username,@"username", nil];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    
    NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
    
    
    
    NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
    
    NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
    
    NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
    
    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:AUTHENTICATE_API withRequestParameter:array withResourcePath:AUTHENTICATE_API withHttpMethd:POST];
    
    [downloadmetadatajob startMetaDataDownLoad];
    
}
-(void) getCubeConfig:(NSString*) userId
{
//    if ([[AppPreferences sharedAppPreferences] isReachable])
//    {
    
        NSError* error;
        NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:userId,@"userid", nil];
        
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                           options:0 // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        
        NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
        
        
        
        NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
        
        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
        
        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
        
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:ACCESS_CUBE_CONFIG_API withRequestParameter:array withResourcePath:ACCESS_CUBE_CONFIG_API withHttpMethd:POST];
        [downloadmetadatajob startMetaDataDownLoad];
//    }
//    else
//    {
//        
//    }
    
}



-(void) getAudioFileExtensions
{
    
    
    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:AUDIO_FILE_EXTENSIONS_API withRequestParameter:nil withResourcePath:AUDIO_FILE_EXTENSIONS_API withHttpMethd:POST];
    [downloadmetadatajob startMetaDataDownLoad];
   
    
}


-(void) getTransCompanyName:(NSString*) tcId
{
    //    if ([[AppPreferences sharedAppPreferences] isReachable])
    //    {
    
    NSError* error;
    NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:tcId,@"TCID", nil];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    
    NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
    
    
    
    NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
    
    NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
    
    NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
    
    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:GET_TC_NAME_API withRequestParameter:array withResourcePath:GET_TC_NAME_API withHttpMethd:POST];
    [downloadmetadatajob startMetaDataDownLoad];
    //    }
    //    else
    //    {
    //
    //    }
    
}

-(void) getEncryptDecryptString
{
    
    
    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:GET_ENCRYPT_DECRYPT_STRING_API withRequestParameter:nil withResourcePath:GET_ENCRYPT_DECRYPT_STRING_API withHttpMethd:POST];
    [downloadmetadatajob startMetaDataDownLoad];
    
    
}


-(void) getSingleQueryValueComment:(NSString*) comment
{
    //    if ([[AppPreferences sharedAppPreferences] isReachable])
    //    {
    
    NSError* error;
    NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:comment,@"strComment", nil];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    
    NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
    
    

    NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
    
    NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
    
    NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
    
    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:GET_SINGLE_QEURY_EXECUTE_QUERY_API withRequestParameter:array withResourcePath:GET_SINGLE_QEURY_EXECUTE_QUERY_API withHttpMethd:POST];
    [downloadmetadatajob startMetaDataDownLoad];
    //    }
    //    else
    //    {
    //
    //    }
    
}


-(void) checkDuplicateAudioForDay:(NSString*) userid originalFileName:(NSString* )filename
{
    
    NSError* error;
    NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:userid,@"userid",filename,@"OriginalFileNam", nil];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    
    NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
    
    
    
    NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
    
    NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
    
    NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
    
    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:CHECK_DUPLICATE_AUDIO_FOR_DAY_API withRequestParameter:array withResourcePath:CHECK_DUPLICATE_AUDIO_FOR_DAY_API withHttpMethd:POST];
    
    [downloadmetadatajob startMetaDataDownLoad];
    
}

-(void) updateDownloadFileStatus:(NSString*) status dictationId:(NSString* )dictationId
{
    
    NSError* error;
    NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:dictationId,@"DictationID",status,@"FileStatus", nil];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    
    NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
    
    
    
    NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
    
    NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
    
    NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
    
    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:UPDATE_DOWNLOAD_FILE_STATUS_API withRequestParameter:array withResourcePath:UPDATE_DOWNLOAD_FILE_STATUS_API withHttpMethd:POST];
    
    [downloadmetadatajob startMetaDataDownLoad];
    
}


-(void) FTPGetTCIdView:(NSString*) userId
{
    //    if ([[AppPreferences sharedAppPreferences] isReachable])
    //    {
    
    NSError* error;
    NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:userId,@"userid", nil];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    
    NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
    
    
    
    NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
    
    NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
    
    NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
    
    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:FTP_GET_TC_ID_VIEW_API withRequestParameter:array withResourcePath:FTP_GET_TC_ID_VIEW_API withHttpMethd:POST];
    [downloadmetadatajob startMetaDataDownLoad];
    //    }
    //    else
    //    {
    //
    //    }
    
}

-(void) uploadFile:(NSString*) data
{
    //    if ([[AppPreferences sharedAppPreferences] isReachable])
    //    {
    
    NSError* error;
    NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:data,@"FileNameStar", nil];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    
    NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
    
    
    
    NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
    
    NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
    
    NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
    
    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:FILE_UPLOAD_API withRequestParameter:array withResourcePath:FILE_UPLOAD_API withHttpMethd:POST];
    [downloadmetadatajob startMetaDataDownLoad];
    //    }
    //    else
    //    {
    //
    //    }
    
}

-(void) getBrowserAudioFilesForDownload:(NSString*) userId
{
    //    if ([[AppPreferences sharedAppPreferences] isReachable])
    //    {
    
    NSError* error;
    NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:userId,@"userid", nil];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    
    NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
    
    
    
    NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
    
    NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
    
    NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
    
    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:GET_BROWSER_AUDIO_FILES_DOWNLOAD_API withRequestParameter:array withResourcePath:GET_BROWSER_AUDIO_FILES_DOWNLOAD_API withHttpMethd:POST];
    [downloadmetadatajob startMetaDataDownLoad];
    //    }
    //    else
    //    {
    //
    //    }
    
}

-(void) getDicatationIds:(NSString*) userId
{
    //    if ([[AppPreferences sharedAppPreferences] isReachable])
    //    {
    
    NSError* error;
    NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:userId,@"userid", nil];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    
    NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
    
    
    
    NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
    
    NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
    
    NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
    
    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:GET_DICTATION_IDS_API withRequestParameter:array withResourcePath:GET_DICTATION_IDS_API withHttpMethd:POST];
    [downloadmetadatajob startMetaDataDownLoad];
    //    }
    //    else
    //    {
    //
    //    }
    
}

-(void) downloadFile:(NSString*) dictationId
{
    //    if ([[AppPreferences sharedAppPreferences] isReachable])
    //    {
    
    NSError* error;
    NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:dictationId,@"DictationId", nil];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    
    NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
    
    
    
    NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
    
    NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
    
    NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
    
    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:DOWNLOAD_FILE_API withRequestParameter:array withResourcePath:DOWNLOAD_FILE_API withHttpMethd:POST];
    [downloadmetadatajob startMetaDataDownLoad];
    //    }
    //    else
    //    {
    //
    //    }
    
}

-(void) getDictatorsFolder:(NSString*) userId
{
    //    if ([[AppPreferences sharedAppPreferences] isReachable])
    //    {
    
    NSError* error;
    NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:userId,@"userid", nil];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    
    NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
    
    
    
    NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
    
    NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
    
    NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
    
    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:GET_DICTATORS_FOLDER_API withRequestParameter:array withResourcePath:GET_DICTATORS_FOLDER_API withHttpMethd:POST];
    [downloadmetadatajob startMetaDataDownLoad];
    //    }
    //    else
    //    {
    //
    //    }
    
}


-(void) generateFilenameDictationId:(NSString*) DictationId userId:(NSString*)userId
{
    //    if ([[AppPreferences sharedAppPreferences] isReachable])
    //    {
    
    NSError* error;
    NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:DictationId,@"DictationId",userId,@"userid", nil];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    
    NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
    
    
    
    NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
    
    NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
    
    NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
    
    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:GENERATE_FILENAME_API withRequestParameter:array withResourcePath:GENERATE_FILENAME_API withHttpMethd:POST];
    [downloadmetadatajob startMetaDataDownLoad];
    //    }
    //    else
    //    {
    //
    //    }
    
}

-(void)checkAPI
{
    NSData* passData = [@"d" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *dataDesc = [passData AES256EncryptWithKey:@"cubemob"];
    
    NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
    
    NSLog(@"%@",str2);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    //    NSMutableData *responseData = self.responsesData[@(dataTask.taskIdentifier)];
    //    if (!responseData) {
    //        responseData = [NSMutableData dataWithData:data];
    //        //self.responsesData[@(dataTask.taskIdentifier)] = responseData;
    //    } else {
    //        [responseData appendData:data];
    //    }
    
    //    NSString* fileName = self.responsesData[@(dataTask.taskIdentifier)];
    
    if (!(data == nil))
    {
        NSString* taskIdentifier = [[NSString stringWithFormat:@"%@",session.configuration.identifier] stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)dataTask.taskIdentifier]];
        
        //        NSString* fileName;
        //
        //        dispatch_async(dispatch_get_main_queue(), ^
        //                       {
        //                           //NSLog(@"Reachable");
        
        
        
        //                           fileName = fileName1;
        //                       });
        
        NSError* error1;
        NSString* encryptedString = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:&error1];
        
        
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encryptedString options:0];
        NSData* data1=[decodedData AES256DecryptWithKey:@"QIADb8dPW1rTGCPaOIDU5A=="];
        NSString* responseString=[[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
        responseString=[responseString stringByReplacingOccurrencesOfString:@"True" withString:@"1"];
        responseString=[responseString stringByReplacingOccurrencesOfString:@"False" withString:@"0"];
        
        NSData *responsedData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        
        result = [NSJSONSerialization JSONObjectWithData:responsedData
                                                 options:NSJSONReadingAllowFragments
                                                   error:nil];
        
        NSString* returnCode= [result valueForKey:@"code"];
        
    }
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)dataTask didCompleteWithError:(NSError *)error
{
    //[dataTask resume];
    NSLog(@"error code:%ld",(long)error.code);
    
    NSString* taskIdentifier = [[NSString stringWithFormat:@"%@",session.configuration.identifier] stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)dataTask.taskIdentifier]];
    
    if (error)
    {
        if (error.code == -999)
        {
            NSLog(@"cancelled from app delegate");
            
            NSLog(@"%@",error.localizedDescription);
            
        }
        else
        {
            
        }
        
    }
    else
    {
        
    }
    
}
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        float progress = (double)totalBytesSent / (double)totalBytesExpectedToSend;
        //NSLog(@"progress %f",progress);
        
        NSString* progressPercent= [NSString stringWithFormat:@"%f",progress*100];
        
        int progressPercentInInt=[progressPercent intValue];
        
        progressPercent=[NSString stringWithFormat:@"%d",progressPercentInInt];
        
        NSString* progressShow= [NSString stringWithFormat:@"%@%%",progressPercent];
        
        NSString* taskIdentifier = [[NSString stringWithFormat:@"%@",session.configuration.identifier] stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)task.taskIdentifier]];
        
    });
    
}



-(void)uploadFileToServerUsingNSURLSession:(NSString*)str

{
    
    //    if ([[AppPreferences sharedAppPreferences] isReachable])
    //    {
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       //                           departmentId= [[Database shareddatabase] getDepartMentIdForFileName:str];
                       //                           transferStatus=[[Database shareddatabase] getTransferStatus:str];
                       //                           mobileDictationIdVal=[[Database shareddatabase] getMobileDictationIdFromFileName:str];
                       
                       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                           
                           [self uploadFileAfterGettingdatabaseValues:str departmentID:1 transferStatus:1 mobileDictationIdVal:122];
                           
                       });
                       
                   });
    
    
    
    //    }
    //    else
    //    {
    //        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    //    }
    
    
}

-(void)uploadFileAfterGettingdatabaseValues:(NSString*)str departmentID:(int)departmentID transferStatus:(int)transferStatus mobileDictationIdVal:(int)mobileDictationIdVal
{
    //    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    //    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    
    NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,str] ];
    
    NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASE_URL_PATH, FILE_UPLOAD_API]];
    
    NSString *boundary = [self generateBoundaryString];
    
    NSDictionary *params = @{@"filename"     : str,
                             };
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    
    long filesizelong=[[APIManager sharedManager] getFileSize:filePath];
    
    int filesizeint=(int)filesizelong;
    
    // NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
    //DepartMent *deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];//    if ([[[NSUserDefaults standardUserDefaults]
    
    
    //NSString* macId=[Keychain getStringForKey:@"udid"];
    
    NSString* macId = [[NSUserDefaults standardUserDefaults] valueForKey:@"MacId"];
    
    if (transferStatus==0)
        transferStatus=1;
    else if(transferStatus==1)
    {
        transferStatus=5;
    }
    else if(transferStatus==3)
    {
        transferStatus=5;
    }
    else if(transferStatus==2)
    {
        transferStatus=1;
    }
    else if(transferStatus==4)
    {
        transferStatus=5;
    }
    
  
    
    // NSString* authorisation=[NSString stringWithFormat:@"%@*%d*%ld*%d*%d",macId,filesizeint,deptObj.Id,1,0];
    NSString* authorisation=[NSString stringWithFormat:@"%@*%d*%d*%d*%d",macId,filesizeint,departmentID,transferStatus,mobileDictationIdVal];
    
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    //    NSError* error;
    
    
    NSData* jsonData=[authorisation dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
    
    
    
    NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
    
    [request setValue:str2 forHTTPHeaderField:@"Authorization"];
    
    // create body
    
    NSData *httpBody = [self createBodyWithBoundary:boundary parameters:params paths:@[filePath] fieldName:str];
    
    
    
    
    
    request.HTTPBody = httpBody;
    
    //    NSInputStream *readData = [[NSInputStream alloc] initWithData:httpBody];
    //    [readData open];
    //
    //    request.HTTPBodyStream = readData;
    //
    //    [readData close];
    
    session = [SharedSession getSharedSession:[APIManager sharedManager]];
    
    //
    [request setHTTPMethod:@"POST"];
    
    
    NSURLSessionUploadTask* uploadTask = [session uploadTaskWithRequest:request fromData:nil];
    //    NSURLSessionUploadTask* uploadTask = [session uploadTaskWithStreamedRequest:request];
    
    
    
    
    NSString* taskIdentifier = [[NSString stringWithFormat:@"%@",session.configuration.identifier] stringByAppendingString:[NSString stringWithFormat:@"%lu", (unsigned long)uploadTask.taskIdentifier]];
    
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       //NSLog(@"Reachable");
                       
                       //                       [[Database shareddatabase] insertTaskIdentifier:[NSString stringWithFormat:@"%@",taskIdentifier] fileName:str];
                   });
    
    
    
    
    
    [uploadTask resume];
    
}


- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
    
    
}

-(void)uploadFileToServer:str
{
    //    if ([AppPreferences sharedAppPreferences].filesInUploadingQueueArray.count<2)
    //    {
    //        if ([AppPreferences sharedAppPreferences].filesInUploadingQueueArray.count == 1)
    //        {
    //            NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:
    //                                  [NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,[[AppPreferences sharedAppPreferences].filesInUploadingQueueArray objectAtIndex:0]] ];
    //
    //            long firstFileSize = [self getFileSize:filePath];
    //
    //            if (firstFileSize>30000000)
    //            {
    //                [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray addObject:str];
    //            }
    //
    //            else
    //            {
    //                filePath = [NSHomeDirectory() stringByAppendingPathComponent:
    //                            [NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,str]];
    //                long secondFileSize = [self getFileSize:filePath];
    //
    //                if (secondFileSize>30000000)
    //                {
    //                    [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray addObject:str];
    //                }
    //
    //                else
    //                {
    //                    [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray addObject:str];
    [self uploadFileToServerUsingNSURLSession:str];
    //                }
    //            }
    //        }
    
    //        else
    //        {
    //            [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray addObject:str];
    //            [self uploadFileToServerUsingNSURLSession:str];
    //        }
    //
    //    }
    //    else
    //    {
    //        [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray addObject:str];
    //    }
    //[self uploadFileToServerUsingNSURLConnection:str];
    
}

//-(void)uploadFileToServer:str
//{
//if ([AppPreferences sharedAppPreferences].filesInUploadingQueueArray.count<2)
//{
//    [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray addObject:str];
//    [self uploadFileToServerUsingNSURLSession:str];
//
//}
//else
//{
//    [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray addObject:str];
//}
//}


- (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                             paths:(NSArray *)paths
                         fieldName:(NSString *)fieldName
{
    NSMutableData *httpBody = [NSMutableData data];
    
    // add params (all params are strings)
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // add image data
    
    for (NSString *path in paths)
    {
        NSString *filename  = [path lastPathComponent];
        NSData   *data1      = [NSData dataWithContentsOfFile:path];
        
        NSData *data = [data1 AES256EncryptWithKey:SECRET_KEY];
        
        NSString *mimetype  = [self mimeTypeForPath:path];
        
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:data];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return httpBody;
}


- (NSString *)mimeTypeForPath:(NSString *)path
{
    // get a mime type for an extension using MobileCoreServices.framework
    
    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);
    
    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    
    assert(mimetype != NULL);
    
    CFRelease(UTI);
    
    return mimetype;
}


- (NSString *)generateBoundaryString
{
    return [NSString stringWithFormat:@"*%@", [[NSUUID UUID] UUIDString]];
    //return [NSString stringWithFormat:@"*"];
    
}

//-(void) authenticateUserMacID:(NSString*) macID password:(NSString*) password username:(NSString* )username
//{
//    //DDCF3B2D-362B-4C81-8AB3-DD56D49E5365
//    //    if ([[AppPreferences sharedAppPreferences] isReachable])
//    //    {
//
//
//    NSError* error;
//    NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:macID,@"macid",password,@"pwd",username,@"username", nil];
//
//    //        NSArray* paramArray = [[NSArray alloc] initWithObjects:@"fdfdfd",password, nil];
//    //
//    //        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:paramArray
//    //                                                           options:0 // Pass 0 if you don't care about the readability of the generated string
//    //                                                             error:&error];
//
//    //    NSArray* passArray = [[NSArray alloc] initWithObjects:password, nil];
//    //    NSData *pwd = [password dataUsingEncoding:NSASCIIStringEncoding];
//
//    NSData* pwd = [password dataUsingEncoding:NSUTF8StringEncoding];
//    //        NSData* pwd = [NSJSONSerialization dataWithJSONObject:passArray options:0 error:&error];
//    NSString* ivVString = @"@1B2c3D4e5F6g7H8";
//    NSData* ivVector = [ivVString dataUsingEncoding:NSUTF8StringEncoding];
//
//    NSData* salt = [@"s@1tValue" dataUsingEncoding:NSUTF8StringEncoding];
//
//    //        NSData *pwdDesc = [pwd AES256EncryptWithKey:SECRET_KEY];
//
//    //    NSData encryptedDataForData:<#(NSData *)#> password:<#(NSString *)#> iv:(NSData *__autoreleasing *) salt:<#(NSData *__autoreleasing *)#> error:<#(NSError *__autoreleasing *)#>
//
//
//
//    NSData *pwdDesc = [NSData encryptedDataForData:pwd password:@"password" iv:&ivVector salt:&salt error:&error];
//
//    //ZiKJfFNIH66enafzWFLBBQ==
//    //    sZu7qrTs5weNjHb+BRCzQQ==
//    NSString* str2 = [pwdDesc base64EncodedStringWithOptions:0];
//
//    NSData *nsdataFromBase64String = [[NSData alloc] initWithBase64EncodedString:str2 options:0];
//
//    NSData *pwdDesc1 = [NSData decryptedDataForData:nsdataFromBase64String password:@"password" iv:&ivVector salt:&salt error:&error];
//
//    NSString* newStr = [NSString stringWithUTF8String:[pwdDesc1 bytes]];
//
//    NSString* responseString=[[NSString alloc] initWithData:pwdDesc1 encoding:NSUTF8StringEncoding];
//
//    NSMutableArray* array=[NSMutableArray arrayWithObjects:username,@"ZiKJfFNIH66enafzWFLBBQ==", @"fdsdfsd", nil];
//
//    DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:AUTHENTICATE_API withRequestParameter:array withResourcePath:AUTHENTICATE_API withHttpMethd:POST];
//    [downloadmetadatajob startMetaDataDownLoad];
//    //    }
//    //    else
//    //    {
//    //        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
//    //    }
//
//}

@end
