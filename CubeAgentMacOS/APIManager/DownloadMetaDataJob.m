//
//  DownloadMetaDataJob.m
//  Communicator
//
//  Created by mac on 05/04/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "DownloadMetaDataJob.h"
#include <sys/xattr.h>
#import "AppDelegate.h"
#import "User.h"
#import "SharedSession.h"
#import "AppPreferences.h"


/*================================================================================================================================================*/

@implementation DownloadMetaDataJob
@synthesize downLoadEntityJobName;
@synthesize requestParameter;
@synthesize downLoadResourcePath;
@synthesize downLoadJobDelegate;
@synthesize httpMethod;

@synthesize addTrintsAfterSomeTimeTimer;
@synthesize currentSaveTrintIndex;
@synthesize isNewMatchFound;
@synthesize dataArray;
-(id) initWithdownLoadEntityJobName:(NSString *) jobName withRequestParameter:(id) localRequestParameter withResourcePath:(NSString *) resourcePath withHttpMethd:(NSString *) httpMethodParameter
{
    self = [super init];
    if (self)
    {
        self.downLoadResourcePath = resourcePath;
        //self.requestParameter = localRequestParameter;
        self.downLoadEntityJobName = [[NSString alloc] initWithFormat:@"%@",jobName];
        self.httpMethod=httpMethodParameter;
        self.dataArray=localRequestParameter;
        self.isNewMatchFound = [NSNumber numberWithInt:1];
    }
    return self;
}

/*================================================================================================================================================*/

#pragma mark -
#pragma mark StartMetaDataDownload
#pragma mark -

-(void)startMetaDataDownLoad
{
    [self sendNewRequestWithResourcePath:downLoadResourcePath withRequestParameter:dataArray withJobName:downLoadEntityJobName withMethodType:httpMethod];
}


-(void) sendNewRequestWithResourcePath:(NSString *) resourcePath withRequestParameter:(NSMutableArray *)array withJobName:(NSString *)jobName withMethodType:(NSString *) httpMethodParameter
{
    responseData = [NSMutableData data];
    
//    NSArray *params = [self.requestParameter objectForKey:REQUEST_PARAMETER];
    
    NSMutableString *parameter = [[NSMutableString alloc] init];
//    for(NSString *strng in array)
//    {
//        if([[array objectAtIndex:0] isEqualToString:strng]) {
//            [parameter appendFormat:@"%@", strng];
//        } else {
//            [parameter appendFormat:@"&%@", strng];
//        }
//    }
    
    NSString *webservicePath = [NSString stringWithFormat:@"%@/%@",BASE_URL_PATH,resourcePath];
//    NSString *webservicePath = [NSString stringWithFormat:@"%@/%@?%@",BASE_URL_PATH,resourcePath,parameter];

    NSURL *url = [[NSURL alloc] initWithString:[webservicePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    [request setHTTPMethod:httpMethodParameter];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSError* error;
    
    //NSData *ciphertext = [RNEncryptor e
//    NSString* str=[NSString stringWithFormat:@"%@",array];
//    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *encryptedData = [RNEncryptor encryptData:data
//                                        withSettings:kRNCryptorAES256Settings
//                                            password:SECRET_KEY
//                                               error:&error];
//    NSString *encString = [encryptedData base64EncodedStringWithOptions:0];
    
//    NSDictionary* dic=[array objectAtIndex:0];
    NSData *requestData;
    
    if (array != nil)
    {
        requestData = [NSJSONSerialization dataWithJSONObject:array options:kNilOptions error:&error];

    }
    
    
    [request setHTTPBody:requestData];
//    NSError* error;
//    NSData *requestData = [NSJSONSerialization dataWithJSONObject:array options:kNilOptions error:&error];


    
    
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%@",urlConnection);
}




/*================================================================================================================================================*/

#pragma mark -
#pragma mark - URL connection callbacks
#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[responseData setLength:0];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    statusCode = (int)[httpResponse statusCode];
    ////NSLog(@"Status code: %d",statusCode);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    NSLog(@"%@",data);
    
	[responseData appendData:data];
}


- (NSString *)shortErrorFromError:(NSError *)error
{
   
    return [error localizedDescription];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Failed %@",error.description);
    NSLog(@"%@ Entity Job -",self.downLoadEntityJobName);
    
    
    if ([self.downLoadEntityJobName isEqualToString:AUTHENTICATE_API])
    {
     
        
//        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:[self shortErrorFromError:error] withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
        
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    ////NSLog(@"Success");
    
    NSError *error;
//    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:responseData
//                                                                 options:NSUTF8StringEncoding
//                                                                   error:&error];
    
    
    NSString *response = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:NSUTF8StringEncoding
                                                               error:&error];
    
    
//    if ([encryptedResponse containsString:@"ExceptionMessage"] || [encryptedResponse containsString:@"ExceptionType"] || [encryptedResponse containsString:@"Message"] || [encryptedResponse containsString:@"StackTrace"])
//    {
////         [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"Something went wrong, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
//
//        return;
//    }


    if([self.downLoadEntityJobName isEqualToString:UPDATE_MAC_ID_API])
        
    {
        
        if (statusCode == 200)
        {
            if ([response longLongValue] == 0)
            {
                NSDictionary* reponseDict = [[NSDictionary alloc] initWithObjectsAndKeys:FAILURE,RESPONSE_IS_MAC_ID_VALID,@"200",RESPONSE_CODE, nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_MAC_ID_API object:reponseDict];
                
                return;
            }
            else
            {
               NSDictionary* reponseDict = [[NSDictionary alloc] initWithObjectsAndKeys:SUCCESS,RESPONSE_IS_MAC_ID_VALID,@"200",RESPONSE_CODE, nil];
                
                 [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_MAC_ID_API object:reponseDict];
            }
        }
        else
        {
            return;
        }
        
    }



if([self.downLoadEntityJobName isEqualToString:AUTHENTICATE_API])

{
    if (statusCode == 200)
    {
        if ([response longLongValue] != 0)
        {
            long userId = [response longLongValue];
            
            NSString* userIdString = [NSString stringWithFormat:@"%ld", userId];
            
            NSDictionary* reponseDict = [[NSDictionary alloc] initWithObjectsAndKeys:userIdString,@"userIdString",@"200",RESPONSE_CODE, nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AUTHENTICATE_API object:reponseDict];
            
            return;
        }
        else
        {
            
        }
    }
}
    
    if([self.downLoadEntityJobName isEqualToString:ACCESS_CUBE_CONFIG_API])
        
    {
        if (statusCode == 200)
        {
//            if ([response longLongValue] != 0)
//            {
//                long userId = [response longLongValue];
            
//                NSString* userIdString = [NSString stringWithFormat:@"%ld", userId];
            
//                NSDictionary* reponseDict = [[NSDictionary alloc] initWithObjectsAndKeys:userIdString,@"userIdString",@"200",RESPONSE_CODE, nil];
            
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CUBE_CONFIG_API object:response];
                
                return;
//            }
//            else
//            {
//
//            }
        }
    }


    if([self.downLoadEntityJobName isEqualToString:AUDIO_FILE_EXTENSIONS_API])
        
    {
        if (statusCode == 200)
        {
            
            
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AUDIO_FILE_EXTENSIONS_API object:response];
                
                return;
           
        }
    }


    if([self.downLoadEntityJobName isEqualToString:GET_TC_NAME_API])
        
    {
        if (statusCode == 200)
        {
            
            
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TC_NAME_API object:response];
                
                return;
           
        }
    }

//    if([self.downLoadEntityJobName isEqualToString:GET_ENCRYPT_DECRYPT_STRING_API])
//        
//    {
//        if (statusCode == 200)
//        {
//            
//            
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_ENCRYPT_DECRYPT_STRING_API object:response];
//            
//            return;
//            
//        }
//    }

    if([self.downLoadEntityJobName isEqualToString:FTP_SET_TCID_VERIFY_API])
        
    {
        if (statusCode == 200)
        {
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FTP_SET_TCID_VERIFY_API object:response];
            
            return;
            
        }
    }
    
    if([self.downLoadEntityJobName isEqualToString:GET_SINGLE_QEURY_EXECUTE_QUERY_API])
        
    {
        if (statusCode == 200)
        {
            
          
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_SINGLE_QEURY_EXECUTE_QUERY_API object:response];
            
            return;
            
        }
    }
    
    if([self.downLoadEntityJobName isEqualToString:CHECK_DUPLICATE_AUDIO_FOR_DAY_API])
        
    {
        if (statusCode == 200)
        {
            
            
            NSString* audioFileName = self.audioFileName;
            
            if ([response isEqualToString:@"No Records"])
            {
                NSDictionary* responseDict = [[NSDictionary alloc] initWithObjectsAndKeys:response,@"response",audioFileName,@"audioFileName", nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHECK_DUPLICATE_AUDIO_FOR_DAY_API object:responseDict];
            }
            else
            {
                NSString* audioFileName = self.audioFileName;
                
                NSDictionary* responseDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"duplicate",@"response",audioFileName,@"audioFileName", nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHECK_DUPLICATE_AUDIO_FOR_DAY_API object:responseDict];
            }
            
           
            
            return;
            
        }
        else
        {
            NSString* audioFileName = self.audioFileName;

            NSDictionary* responseDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"duplicate",@"response",audioFileName,@"audioFileName", nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHECK_DUPLICATE_AUDIO_FOR_DAY_API object:responseDict];
        }
    }
    
    if([self.downLoadEntityJobName isEqualToString:UPDATE_DOWNLOAD_FILE_STATUS_API])
        
    {
        if (statusCode == 200)
        {
            
            

            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_DOWNLOAD_FILE_STATUS_API object:response];
            
            return;
            
        }
    }
    
    if([self.downLoadEntityJobName isEqualToString:FTP_GET_TC_ID_VIEW_API])
        
    {
        if (statusCode == 200)
        {
            
            NSDictionary* responseDict = [[NSDictionary alloc] initWithObjectsAndKeys:response,@"response",self.audioFileName,@"audioFileName", nil];

            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FTP_GET_TC_ID_VIEW_API object:responseDict];
            
            return;
            
        }
    }
    
    if([self.downLoadEntityJobName isEqualToString:FILE_UPLOAD_API])
        
    {
        if (statusCode == 200)
        {
        
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:response];
            
            return;
            
        }
    }
    
    if([self.downLoadEntityJobName isEqualToString:GET_BROWSER_AUDIO_FILES_DOWNLOAD_API])
        
    {
        if (statusCode == 200)
        {
            
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_BROWSER_AUDIO_FILES_DOWNLOAD_API object:response];
            
            return;
            
        }
    }
    
    if([self.downLoadEntityJobName isEqualToString:GET_DICTATION_IDS_API])
        
    {
        if (statusCode == 200)
        {
            
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_DICTATION_IDS_API object:response];
            
            return;
            
        }
    }
    
    if([self.downLoadEntityJobName isEqualToString:DOWNLOAD_FILE_API])
        
    {
        if (statusCode == 200)
        {
            
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DOWNLOAD_FILE_API object:response];
            
            return;
            
        }
    }
    
    if([self.downLoadEntityJobName isEqualToString:GET_DICTATORS_FOLDER_API])
        
    {
        if (statusCode == 200)
        {
            
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DOWNLOAD_FILE_API object:response];
            
            return;
            
        }
    }
    
    if([self.downLoadEntityJobName isEqualToString:GENERATE_FILENAME_API])
        
    {
        if (statusCode == 200)
        {
            
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GENERATE_FILENAME_API object:response];
            
            return;
            
        }
    }
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
        
        NSError* error1;
        NSMutableDictionary* encryptedDict = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:NSJSONReadingAllowFragments
                                                                               error:&error1];
        
        NSLog(@"");
        
        NSString* audioFileName = self.audioFileName;

        if (encryptedDict != nil)
        {
            encryptedDict = [NSMutableDictionary new];

            [encryptedDict setObject:audioFileName forKey:@"audioFileName"];

            [encryptedDict setObject:@"true" forKey:@"isUploaded"];

        }
        else
        {
            encryptedDict = [NSMutableDictionary new];
            
            [encryptedDict setObject:audioFileName forKey:@"audioFileName"];
            
            [encryptedDict setObject:@"false" forKey:@"isUploaded"];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:encryptedDict];

        //        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:encryptedString];
        
        //        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encryptedString options:0];
        //        NSData* data1=[decodedData AES256DecryptWithKey:SECRET_KEY];
        //        NSString* responseString=[[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
        //        responseString=[responseString stringByReplacingOccurrencesOfString:@"True" withString:@"1"];
        //        responseString=[responseString stringByReplacingOccurrencesOfString:@"False" withString:@"0"];
        //
        //        NSData *responsedData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        //
        //        result = [NSJSONSerialization JSONObjectWithData:responsedData
        //                                                 options:NSJSONReadingAllowFragments
        //                                                   error:nil];
        //
        //        NSString* returnCode= [result valueForKey:@"code"];
        
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
-(void)uploadFileAfterGettingdatabaseValues:(NSString*)filename dictatorId:(long)dictatorId FTPAudioPath:(NSString*)FTPAudioPath strInHouse:(int)strInHouse clinicName:(NSString*)clinicName userId:(long)userId dictatorFirstName:(NSString*)dictatorFirstName tcId:(long)tcId vcId:(long)vcId filePath:(NSString*)filePath
{
    NSString* parameterString  = @"";
    
    //    -DictId,FTPAudioPath,strInhouse,ClinicName,UserID,DictatorFirstName,intTCID,intVCID
    parameterString = [parameterString stringByAppendingString:[NSString stringWithFormat:@"%ld,", dictatorId]];
    
    parameterString = [parameterString stringByAppendingString:[NSString stringWithFormat:@"%@,", FTPAudioPath]];
    
    parameterString = [parameterString stringByAppendingString:[NSString stringWithFormat:@"%d,", strInHouse]];
    
    parameterString = [parameterString stringByAppendingString:[NSString stringWithFormat:@"%@,", clinicName]];
    
    parameterString = [parameterString stringByAppendingString:[NSString stringWithFormat:@"%ld,", userId]];
    
    parameterString = [parameterString stringByAppendingString:[NSString stringWithFormat:@"%@,", dictatorFirstName]];
    
    parameterString = [parameterString stringByAppendingString:[NSString stringWithFormat:@"%ld,", tcId]];
    
    parameterString = [parameterString stringByAppendingString:[NSString stringWithFormat:@"%ld", vcId]];
    
    
    //    NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:
    //                          [NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,filename] ];
    
    NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASE_URL_PATH, FILE_UPLOAD_API]];
    
    NSString *boundary = [self generateBoundaryString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:POST];
    
    //    long filesizelong = [[AppPreferences sharedAppPreferences] getFileSize:filePath];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // NSString* authorisation=[NSString stringWithFormat:@"%@*%d*%ld*%d*%d",macId,filesizeint,deptObj.Id,1,0];
    //    NSString* authorisation=[NSString stringWithFormat:@"%ld*%@*%d*%@*%ld*%@*%ld,%ld",dictatorId,FTPAudioPath,strInHouse,clinicName,userId,dictatorFirstName,tcId,vcId];
    
    NSData* jsonData=[parameterString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
    
    NSString* str2 = [dataDesc base64EncodedStringWithOptions:0];
    
    NSDictionary* dict = @{
                           
                           };
    
    [request setValue:str2 forHTTPHeaderField:@"Authorization"];
    
    NSData *httpBody = [self createBodyWithBoundary:boundary parameters:dict paths:@[filePath] fieldName:filename];
    
    request.HTTPBody = httpBody;
    
    session = [SharedSession getSharedSession:self];
    
    uploadTask = [session uploadTaskWithRequest:request fromData:nil];
    
    NSString* taskIdentifier = [[NSString stringWithFormat:@"%@",session.configuration.identifier] stringByAppendingString:[NSString stringWithFormat:@"%lu", (unsigned long)uploadTask.taskIdentifier]];
    
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       
                   });
    
    [uploadTask resume];
    
}


- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
    
    
}



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
        
        NSString* tempDirectoryPath = [[AppPreferences sharedAppPreferences] getCubeTempDirectoryPath];
        
        NSString *encryptedFileName  = [[path lastPathComponent] stringByAppendingPathExtension:@"fcfe"];
        
        NSString* encryptedFilePath = [[tempDirectoryPath stringByAppendingPathComponent:filename] stringByAppendingPathExtension:@"fcfe"];
        
        bool isWritten = [data writeToFile:encryptedFilePath atomically:YES];
        
        NSData   *encryptedFCFEData = [NSData dataWithContentsOfFile:encryptedFilePath];
        
        //        NSData *encryptedFCFEData = [FCFEData AES256EncryptWithKey:SECRET_KEY];
        
        NSString *mimetype  = [self mimeTypeForPath:path];
        
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, encryptedFileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:encryptedFCFEData];
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

@end

/*================================================================================================================================================*/
