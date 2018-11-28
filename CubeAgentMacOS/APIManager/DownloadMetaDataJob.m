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
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:array options:kNilOptions error:&error];
    
    
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
    
    
    if ([self.downLoadEntityJobName isEqualToString:CHECK_DEVICE_REGISTRATION])
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
    
    
    NSString *encryptedResponse = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:NSUTF8StringEncoding
                                                               error:&error];
    
    
//    if ([encryptedResponse containsString:@"ExceptionMessage"] || [encryptedResponse containsString:@"ExceptionType"] || [encryptedResponse containsString:@"Message"] || [encryptedResponse containsString:@"StackTrace"])
//    {
////         [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"Something went wrong, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
//
//        return;
//    }
//            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encryptedResponse options:0];
//            NSData* data=[decodedData AES256DecryptWithKey:SECRET_KEY];
//            NSString* responseString=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
//    NSDictionary *response;
//    if (responseString!=nil)
//    {
//        responseString=[responseString stringByReplacingOccurrencesOfString:@"True" withString:@"1"];
//        responseString=[responseString stringByReplacingOccurrencesOfString:@"False" withString:@"0"];
//
//        NSData *responsedData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
//
//        response = [NSJSONSerialization JSONObjectWithData:responsedData
//                                                                 options:NSJSONReadingAllowFragments
//                                                                   error:&error];
//
//    }




if([self.downLoadEntityJobName isEqualToString:CHECK_DEVICE_REGISTRATION])

{
    
//    if (response != nil)
//    {
//
////        NSString* code=[response objectForKey:RESPONSE_CODE];
////        NSString* pinVerify=[response objectForKey:RESPONSE_PIN_VERIFY];
//
//        
//    }
}




if ([self.downLoadEntityJobName isEqualToString:AUTHENTICATE_API])
{
    
//    if (response != nil)
//    {
//    [response objectForKey:@"code"];
//        if ([[response objectForKey:@"code"]intValue]==200)
//        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AUTHENTICATE_API object:response];
//            
//            
//        }else
//        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AUTHENTICATE_API object:response];
//
//        }
//    }else
//    {
//        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"Something went wrong, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
//    }
}


 


}

@end

/*================================================================================================================================================*/
