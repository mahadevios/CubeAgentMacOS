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

   
    
    if ([self.downLoadEntityJobName  isEqual: GET_BROWSER_AUDIO_FILES_DOWNLOAD_API] || [self.downLoadEntityJobName  isEqual: DOWNLOAD_FILE_API])
    {
        [self downloadFilesUsingNSUrlSession:request];
    }
    else
    {
        urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

    }
    
//    [urlConnection start];
//    NSLog(@"%@",urlConnection);
//    DDLogInfo(@"%@",urlConnection);

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
    
//    DDLogInfo(@"API Name %@, Status Code = %d",self.downLoadEntityJobName, statusCode);
    
    ////NSLog(@"Status code: %d",statusCode);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
//    NSLog(@"%@",data);

	[responseData appendData:data];
    
//    DDLogInfo(@"API Name %@, Receive Data", self.downLoadEntityJobName);

}


- (NSString *)shortErrorFromError:(NSError *)error
{
   
    return [error localizedDescription];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Failed %@",error.description);
//    NSLog(@"%@ Entity Job -",self.downLoadEntityJobName);
    

    if (error.code != 0)

    {
        NSArray* arr = [self.downLoadEntityJobName componentsSeparatedByString:@"_"];
        
        if (arr.count > 1)
        {
            NSString* apiSubName = [arr objectAtIndex:1];
            
            DDLogInfo(@"%@ Complete with Error = %@", apiSubName, [self shortErrorFromError:error]);
            
            if ([self.downLoadEntityJobName isEqualToString:UPDATE_MAC_ID_API])
            {
                 NSDictionary* reponseDict = [[NSDictionary alloc] initWithObjectsAndKeys:error.localizedDescription,RESPONSE_IS_MAC_ID_VALID,[NSString stringWithFormat:@"%ld", error.code],RESPONSE_CODE, nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NO_INTERNET object:reponseDict];

                return;
            }
            
            if ([self.downLoadEntityJobName isEqualToString:AUTHENTICATE_API])
            {
                NSDictionary* reponseDict = [[NSDictionary alloc] initWithObjectsAndKeys:error.localizedDescription,RESPONSE_IS_MAC_ID_VALID,[NSString stringWithFormat:@"%ld", error.code],RESPONSE_CODE, nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NO_INTERNET object:reponseDict];
                
                return;
            }
            
            if ([self.downLoadEntityJobName isEqualToString:ACCESS_CUBE_CONFIG_API])
            {
                NSDictionary* reponseDict = [[NSDictionary alloc] initWithObjectsAndKeys:error.localizedDescription,RESPONSE_IS_MAC_ID_VALID,[NSString stringWithFormat:@"%ld", error.code],RESPONSE_CODE, nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NO_INTERNET object:reponseDict];
                
                return;
            }
            
            if ([self.downLoadEntityJobName isEqualToString:AUDIO_FILE_EXTENSIONS_API])
            {
                NSDictionary* reponseDict = [[NSDictionary alloc] initWithObjectsAndKeys:error.localizedDescription,RESPONSE_IS_MAC_ID_VALID,[NSString stringWithFormat:@"%ld", error.code],RESPONSE_CODE, nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NO_INTERNET object:reponseDict];
                
                return;
            }
            
            if ([self.downLoadEntityJobName isEqualToString:GET_TC_NAME_API])
            {
                NSDictionary* reponseDict = [[NSDictionary alloc] initWithObjectsAndKeys:error.localizedDescription,RESPONSE_IS_MAC_ID_VALID,[NSString stringWithFormat:@"%ld", error.code],RESPONSE_CODE, nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NO_INTERNET object:reponseDict];
                
                return;
            }
            
            if ([self.downLoadEntityJobName isEqualToString:CHECK_DUPLICATE_AUDIO_FOR_DAY_API])
            {
                NSDictionary* responseDict = [[NSDictionary alloc] initWithObjectsAndKeys:error.localizedDescription,@"response", nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHECK_DUPLICATE_AUDIO_FOR_DAY_API object:responseDict];
                
                 return;
              
            }
        }
        

    }
   
//    if ([self.downLoadEntityJobName isEqualToString:AUTHENTICATE_API])
//    {
//
//    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;

    NSString *response = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:NSUTF8StringEncoding
                                                               error:&error];
    
    
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
            [[AppPreferences sharedAppPreferences] showAlertWithTitle:@"Alert" subTitle:@"Something went wrong, please try again."];

//            DDLogInfo(@"API Name = %@, Response = %@, Status Code = %d", self.downLoadEntityJobName, response, statusCode);
            return;
        }
        
    }


else
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
//            DDLogInfo(@"API Name = %@, Response = %@, Status Code = %d", self.downLoadEntityJobName, response, statusCode);

            return;
        }
    }
}
    else
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
        else
        {
//            DDLogInfo(@"API Name = %@, Response = %@, Status Code = %d", self.downLoadEntityJobName, response, statusCode);
            return;
        }
    }

else
    if([self.downLoadEntityJobName isEqualToString:AUDIO_FILE_EXTENSIONS_API])
        
    {
        if (statusCode == 200)
        {
           
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AUDIO_FILE_EXTENSIONS_API object:response];
                
                return;
           
        }
        else
        {
//             DDLogInfo(@"API Name = %@, Response = %@, Status Code = %d", self.downLoadEntityJobName, response, statusCode);
        }
    }

else
    if([self.downLoadEntityJobName isEqualToString:GET_TC_NAME_API])
        
    {
        if (statusCode == 200)
        {
            
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TC_NAME_API object:response];
                
                return;
           
        }
        else
        {
//             DDLogInfo(@"API Name = %@, Response = %@, Status Code = %d", self.downLoadEntityJobName, response, statusCode);
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
else
    if([self.downLoadEntityJobName isEqualToString:FTP_SET_VC_ID_VERIFY_API])
        
    {
        if (statusCode == 200)
        {
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FTP_SET_VC_ID_VERIFY_API object:response];
            
            return;
            
        }
        else
        {
//             DDLogInfo(@"API Name = %@, Response = %@, Status Code = %d", self.downLoadEntityJobName, response, statusCode);
        }
    }
    
    else
    if([self.downLoadEntityJobName isEqualToString:GET_SINGLE_QEURY_EXECUTE_QUERY_API])
        
    {
        if (statusCode == 200)
        {
            
          
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_SINGLE_QEURY_EXECUTE_QUERY_API object:response];
            
            return;
            
        }
        else
        {
//             DDLogInfo(@"API Name = %@, Response = %@, Status Code = %d", self.downLoadEntityJobName, response, statusCode);
        }
    }
    
    else
    if([self.downLoadEntityJobName isEqualToString:CHECK_DUPLICATE_AUDIO_FOR_DAY_API])
        
    {
        if (statusCode == 200)
        {
            
            
            NSString* audioFileName = self.audioFileName;
            
            if (![response isKindOfClass:[NSDictionary class]])
            {
                if ([response isEqualToString:@"No Records"])
                {
                    NSString* audioFilePath = self.audioFilePath;
                    
                    NSDictionary* responseDict = [[NSDictionary alloc] initWithObjectsAndKeys:response,@"response",audioFileName,@"audioFileName",audioFilePath,@"audioFilePath", nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHECK_DUPLICATE_AUDIO_FOR_DAY_API object:responseDict];
                }
            }
           
            else
            {                
                NSString* audioFilePath = self.audioFilePath;

                NSDictionary* responseDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"duplicate",@"response",audioFileName,@"audioFileName",audioFilePath,@"audioFilePath", nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHECK_DUPLICATE_AUDIO_FOR_DAY_API object:responseDict];
            }
            
           
            
            return;
            
        }
        else
        {
//             DDLogInfo(@"API Name = %@, Response = %@, Status Code = %d", self.downLoadEntityJobName, response, statusCode);
            
            NSString* audioFileName = self.audioFileName;

            NSString* audioFilePath = self.audioFilePath;

            NSDictionary* responseDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"duplicate",@"response",audioFileName,@"audioFileName",audioFilePath,@"audioFilePath", nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHECK_DUPLICATE_AUDIO_FOR_DAY_API object:responseDict];
        }
    }
    
    else
    if([self.downLoadEntityJobName isEqualToString:UPDATE_DOWNLOAD_FILE_STATUS_API])
        
    {
        if (statusCode == 200)
        {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_DOWNLOAD_FILE_STATUS_API object:response];
            
            return;
            
        }
        else
        {
//            DDLogInfo(@"API Name = %@, Response = %@, Status Code = %d", self.downLoadEntityJobName, response, statusCode);
        }
    }
    
    else
    if([self.downLoadEntityJobName isEqualToString:FTP_GET_TC_ID_VIEW_API])
        
    {
        if (statusCode == 200)
        {
            
            NSDictionary* responseDict = [[NSDictionary alloc] initWithObjectsAndKeys:response,@"response",self.audioFileName,@"audioFileName",self.audioFilePath,@"audioFilePath", nil];

            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FTP_GET_TC_ID_VIEW_API object:responseDict];
            
            return;
            
        }
        else
        {
//            DDLogInfo(@"API Name = %@, Response = %@, Status Code = %d", self.downLoadEntityJobName, response, statusCode);
        }
    }
    
    else
    if([self.downLoadEntityJobName isEqualToString:FILE_UPLOAD_API])
        
    {
        if (statusCode == 200)
        {
        
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:response];
            
            return;
            
        }
        else
        {
//            DDLogInfo(@"API Name = %@, Response = %@, Status Code = %d", self.downLoadEntityJobName, response, statusCode);
        }
    }
    
    else
    if([self.downLoadEntityJobName isEqualToString:GET_BROWSER_AUDIO_FILES_DOWNLOAD_API])
        
    {
        if (statusCode == 200)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_BROWSER_AUDIO_FILES_DOWNLOAD_API object:response];
            
            return;
            
        }
        else
        {
//            DDLogInfo(@"API Name = %@, Response = %@, Status Code = %d", self.downLoadEntityJobName, response, statusCode);
        }
    }
    
    else
    if([self.downLoadEntityJobName isEqualToString:GET_DICTATION_IDS_API])
        
    {
        if (statusCode == 200)
        {
            
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_DICTATION_IDS_API object:response];
            
            return;
            
        }
        else
        {
//            DDLogInfo(@"API Name = %@, Response = %@, Status Code = %d", self.downLoadEntityJobName, response, statusCode);
        }
    }
    
    else
    if([self.downLoadEntityJobName isEqualToString:DOWNLOAD_FILE_API])
        
    {
        if (statusCode == 200)
        {
            
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DOWNLOAD_FILE_API object:response];
            
            return;
            
        }
        else
        {
//            DDLogInfo(@"API Name = %@, Response = %@, Status Code = %d", self.downLoadEntityJobName, response, statusCode);
        }
    }
    
    else
    if([self.downLoadEntityJobName isEqualToString:GET_DICTATORS_FOLDER_API])
        
    {
        if (statusCode == 200)
        {
            
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_DICTATORS_FOLDER_API object:response];
            
            return;
            
        }
        else
        {
//            DDLogInfo(@"API Name = %@, Response = %@, Status Code = %d", self.downLoadEntityJobName, response, statusCode);
        }
    }
    
    else
    if([self.downLoadEntityJobName isEqualToString:GENERATE_FILENAME_API])
        
    {
        if (statusCode == 200)
        {
            
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GENERATE_FILENAME_API object:response];
            
            return;
            
        }
        else
        {
//            DDLogInfo(@"API Name = %@, Response = %@, Status Code = %d", self.downLoadEntityJobName, response, statusCode);
        }
    }
}

-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
//    NSLog(@"%@", challenge.error);
    DDLogInfo(@"Challenge Received");
    
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
//    NSLog(@"challenge received");
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    self.isDidReceiveDataCalled = true;
    
    if (!(data == nil))
    {

        
        NSError* error1;
        NSMutableDictionary* encryptedDict = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:NSJSONReadingAllowFragments
                                                                               error:&error1];
        NSLog(@"test dict resp = %@", encryptedDict);
        
        if ([self.downLoadEntityJobName  isEqual: FILE_UPLOAD_API])
        {
            NSLog(@"");
            
//            NSString* audioFileName = self.audioFileObject.originalFileNamePath;
            
            
            if (encryptedDict != nil)
            {
                encryptedDict = [NSMutableDictionary new];
                
                self.audioFileObject.status = @"Uploaded";
                
                [encryptedDict setObject:self.audioFileObject forKey:@"audioFileObject"];
                
            }
            else
            {
                encryptedDict = [NSMutableDictionary new];
                
                self.audioFileObject.status = @"Not Uploaded";
                
                [encryptedDict setObject:self.audioFileObject forKey:@"audioFileObject"];
                
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:encryptedDict];
        }
        else
        if ([self.downLoadEntityJobName  isEqual: GET_BROWSER_AUDIO_FILES_DOWNLOAD_API])

        {
            NSError* error1;
//            NSDictionary* encryptedDict = [NSJSONSerialization JSONObjectWithData:data
//                                                                                 options:NSJSONReadingAllowFragments
//                                                                                   error:&error1];


//             NSLog(@"jobname = %@", self.downLoadEntityJobName);
        }
        

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
    else
    {
        NSLog(@"nil data");
        
        DDLogInfo(@"Something went wrong, file not uploaded status code = %d",statusCode);
        
        NSMutableDictionary* encryptedDict = [NSMutableDictionary new];
        
        self.audioFileObject.status = @"Not Uploaded";
        
        [encryptedDict setObject:self.audioFileObject forKey:@"audioFileObject"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:encryptedDict];

//        DDLogInfo(@"API Name = %@, Data = %@, Status Code = %d", self.downLoadEntityJobName, data, statusCode);
    }
    
    
}
-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSLog(@"invalid error = %@", error.localizedDescription);
     NSLog(@"invalid");
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)dataTask didCompleteWithError:(NSError *)error
{
    //[dataTask resume];
    
    
    

    NSLog(@"error code:%ld",(long)error.code);
    
    NSLog(@"error id = %@",error.localizedDescription);
//    NSString* taskIdentifier = [[NSString stringWithFormat:@"%@",session.configuration.identifier] stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)dataTask.taskIdentifier]];
    
    if (error.code == -999)
    {
        DDLogInfo(@"cancelled from app delegate");
        
        DDLogInfo(@"Upload Audio FIle Data Task Error = %@",error.localizedDescription);
        
    }
    else // if internet is offline
        if ((error.code == -1009 || error.code == -1005) && !self.isDidReceiveDataCalled && [self.downLoadEntityJobName  isEqual: FILE_UPLOAD_API])
        {
            
            NSMutableDictionary* encryptedDict = [NSMutableDictionary new];
            
            self.audioFileObject.status = @"Not Uploaded";
            
//            NSString* audioFileName = self.audioFileObject.originalFileNamePath;
            
            [encryptedDict setObject:self.audioFileObject forKey:@"audioFileObject"];
            
            [encryptedDict setObject:[NSString stringWithFormat:@"%ld",error.code] forKey:@"errorCode"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:encryptedDict];
            
            DDLogInfo(@"%@ Audio file not uploaded filename = %@",error.localizedDescription, self.audioFileObject.fileName);
            
            DDLogInfo(@"File will be uploaded when internet connection is available.");

//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[AppPreferences sharedAppPreferences] showAlertWithTitle:@"Alert" subTitle:[NSString stringWithFormat:@"%@, Audio file(s) not uploaded",error.localizedDescription]];
//            });
        }
        else // in case didreceive data not called then set the file as "not uploaded"
            if (error.code == 0 && !self.isDidReceiveDataCalled && [self.downLoadEntityJobName  isEqual: FILE_UPLOAD_API])
            {
                NSMutableDictionary* encryptedDict = [NSMutableDictionary new];
                
                self.audioFileObject.status = @"Not Uploaded";
                
                //        NSString* audioFileName = self.audioFileObject.originalFileNamePath;
                DDLogInfo(@"Audio file not uploaded file name = %@", self.audioFileObject.fileName);

                [encryptedDict setObject:self.audioFileObject forKey:@"audioFileObject"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:encryptedDict];
            }
    else
        if (error.code != 0 && !self.isDidReceiveDataCalled && [self.downLoadEntityJobName  isEqual: FILE_UPLOAD_API])
        {
            NSMutableDictionary* encryptedDict = [NSMutableDictionary new];
            
            self.audioFileObject.status = @"Not Uploaded";
            
            //            NSString* audioFileName = self.audioFileObject.originalFileNamePath;
            
            [encryptedDict setObject:self.audioFileObject forKey:@"audioFileObject"];
            
            [encryptedDict setObject:[NSString stringWithFormat:@"%ld",error.code] forKey:@"errorCode"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:encryptedDict];
            
            DDLogInfo(@"%@ Audio file not uploaded filename = %@",error.localizedDescription, self.audioFileObject.fileName);
        }
    
    
}
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    
    if ([self.downLoadEntityJobName  isEqual: FILE_UPLOAD_API])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            float progress = (double)totalBytesSent / (double)totalBytesExpectedToSend;
            //NSLog(@"progress %f",progress);
            
            NSString* progressPercent= [NSString stringWithFormat:@"%f",progress*100];
            
            int progressPercentInInt = [progressPercent intValue];
            
            progressPercent = [NSString stringWithFormat:@"%d",progressPercentInInt];
            
            NSString* progressShow= [NSString stringWithFormat:@"%@%%",progressPercent];
            
            NSString* fileName = self.audioFileObject.fileName;
            
            NSString* totalBytesSentInString = [NSString stringWithFormat:@"%lld",totalBytesSent];
            
            // for progress bar
            [AppPreferences sharedAppPreferences].currentUploadingPercentage = progressPercentInInt;
            
            // for tableview bytesSent column
            [AppPreferences sharedAppPreferences].currentUploadingTableViewRow = self.audioFileObject.rowNumber;
            
            [[AppPreferences sharedAppPreferences].progressCountFileNameDict setObject:totalBytesSentInString forKey:self.audioFileObject.fileName];
            
            
            NSLog(@"%@ = %@", fileName,progressShow);
            
//            NSString* taskIdentifier = [[NSString stringWithFormat:@"%@",session.configuration.identifier] stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)task.taskIdentifier]];
            
        });
        
    }
//    else
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//            float progress = (double)totalBytesSent / (double)totalBytesExpectedToSend;
//            //NSLog(@"progress %f",progress);
//
//            NSString* progressPercent= [NSString stringWithFormat:@"%f",progress*100];
//
//            int progressPercentInInt = [progressPercent intValue];
//
//            progressPercent = [NSString stringWithFormat:@"%d",progressPercentInInt];
//
//            NSLog(@"%@", progressPercent);
//        });
//    }
    
    
}
-(void)uploadFileAfterGettingdatabaseValues:(ViewTCIdList*)tcList vcList:(VCIdList*)vcList audioFile:(AudioFile*)audioFile
{
    NSString* parameterString  = @"";
    
    //    -DictId,FTPAudioPath,strInhouse,ClinicName,UserID,DictatorFirstName,intTCID,intVCID
    parameterString = [parameterString stringByAppendingString:[NSString stringWithFormat:@"%ld,", tcList.UserID]];
    
    parameterString = [parameterString stringByAppendingString:[NSString stringWithFormat:@"\\%@,", tcList.TCName]];
    
    parameterString = [parameterString stringByAppendingString:[NSString stringWithFormat:@"%d,", vcList.Inhouse]];
    
    parameterString = [parameterString stringByAppendingString:[NSString stringWithFormat:@"%@,", tcList.ClinicName]];
    
    parameterString = [parameterString stringByAppendingString:[NSString stringWithFormat:@"%ld,", tcList.UserID]];
    
    parameterString = [parameterString stringByAppendingString:[NSString stringWithFormat:@"%@,", tcList.DictatorFirstName]];
    
    parameterString = [parameterString stringByAppendingString:[NSString stringWithFormat:@"%d,", tcList.TCID]];
    
    parameterString = [parameterString stringByAppendingString:[NSString stringWithFormat:@"%ld", vcList.VCID]];
    
    
    //    NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:
    //                          [NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,filename] ];
    NSLog(@"parameters = %@", parameterString);
    
    NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASE_URL_PATH, FILE_UPLOAD_API]];
    
    NSString *boundary = [self generateBoundaryString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:POST];
    
    //    long filesizelong = [[AppPreferences sharedAppPreferences] getFileSize:filePath];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // NSString* authorisation=[NSString stringWithFormat:@"%@*%d*%ld*%d*%d",macId,filesizeint,deptObj.Id,1,0];
    //    NSString* authorisation=[NSString stringWithFormat:@"%ld*%@*%d*%@*%ld*%@*%ld,%ld",dictatorId,FTPAudioPath,strInHouse,clinicName,userId,dictatorFirstName,tcId,vcId];
//    NSString* encodedUrl = [parameterString
//                            stringByAddingPercentEscapesUsingEncoding:
//                            NSUTF8StringEncoding];
    
    NSData* jsonData=[parameterString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
    
    NSString* str2 = [dataDesc base64EncodedStringWithOptions:0];
    
    NSDictionary* dict = @{
                           
                           };
    
    [request setValue:str2 forHTTPHeaderField:@"Authorization"];
    
    NSData *httpBody = [self createBodyWithBoundary:boundary parameters:dict paths:@[audioFile.originalFileNamePath] fieldName:audioFile.fileName];
    
    request.HTTPBody = httpBody;
    
//    session = [SharedSession getSharedSession:self];
    
//    if (backgroundConfig == nil)
//    {
//        backgroundConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"Xanadutec1"];
//
//    }

    session = [NSURLSession sessionWithConfiguration:backgroundConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];

//     NSURLSession *session = [NSURLSession sharedSession];
    
   NSURLSessionUploadTask* uploadTask = [session uploadTaskWithRequest:request fromData:nil];
    
    
    NSString* taskIdentifier = [[NSString stringWithFormat:@"%@",session.configuration.identifier] stringByAppendingString:[NSString stringWithFormat:@"%lu", (unsigned long)uploadTask.taskIdentifier]];
    
    self.taskIdentifier = taskIdentifier;
//    if([AppPreferences sharedAppPreferences].progressCountFileNameDict)
//    {
//        [AppPreferences sharedAppPreferences].progressCountFileNameDict = [NSMutableDictionary new];
//    }
    
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


#pragma mark: NSURLSession Download Delegate


-(void)downloadFilesUsingNSUrlSession:(NSURLRequest*) request
{
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
   
    NSURLSessionDownloadTask* dowloadTask = [session downloadTaskWithRequest:request];
    
    [dowloadTask resume];

}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    if ([self.downLoadEntityJobName isEqualToString:GET_BROWSER_AUDIO_FILES_DOWNLOAD_API])
    {
        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:location, @"downloadLocationUrl", @"Downloaded", @"downloadStatus", nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_BROWSER_AUDIO_FILES_DOWNLOAD_API object:dict];

    }
    else if ([self.downLoadEntityJobName isEqualToString:DOWNLOAD_FILE_API])
    {
        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:location, @"downloadLocationUrl", @"Downloaded", @"downloadStatus", nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DOWNLOAD_FILE_API object:dict];
    }
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{

}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
//    NSLog(@"bytesWritten = %lld", bytesWritten);

    
    DDLogInfo(@"Total bytes written in the file = %lld", totalBytesWritten);

//    NSLog(@"totalBytesExpectedToWrite = %lld", totalBytesExpectedToWrite);

//    NSLog(@"downloadTask");
}

@end

/*================================================================================================================================================*/
