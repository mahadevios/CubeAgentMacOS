//
//  DownloadMetaDataJob.h
//  Communicator
//
//  Created by mac on 05/04/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//
/*================================================================================================================================================*/

#import <Foundation/Foundation.h>
#import "SBJson4.h"
#import "objc/runtime.h"
#import "Constants.h"
#import "NSData+AES256.h"
#import "AudioFile.h"
#import "VCIdList.h"
#import "ViewTCIdList.h"

@protocol DownloadMetaDataJobDelegate;

@interface DownloadMetaDataJob : NSObject<NSURLSessionDataDelegate,NSURLSessionDownloadDelegate>
{
    NSString        *downLoadEntityJobName;
    NSString        *downLoadResourcePath;
    NSString        *httpMethod;
    
    NSMutableData   *responseData;
    
    NSDictionary      *requestParameter;
    
    float				bytesReceived;
	long long			expectedBytes;
    float               percentComplete;
    float               progress;
    
    id<DownloadMetaDataJobDelegate> downLoadJobDelegate;
    
    NSDate          *startDate;
    
    int             statusCode;
    
    NSURLSessionUploadTask* uploadTask;
    NSURLSession* session;
    NSURLConnection *urlConnection;
}

/*================================================================================================================================================*/

@property (nonatomic,strong)  NSString              *downLoadEntityJobName;
@property (nonatomic,strong)  NSString              *downLoadResourcePath;
@property (nonatomic,strong)  NSDictionary          *requestParameter;
@property (nonatomic,strong)  NSMutableArray        *dataArray;
@property (nonatomic,strong)  AudioFile              *audioFileObject;
@property (nonatomic,strong)  NSString              *audioFileName;

@property (nonatomic,strong)  NSString              *httpMethod;
@property (nonatomic,strong)  id<DownloadMetaDataJobDelegate> downLoadJobDelegate;

@property (nonatomic,strong)  NSTimer               *addTrintsAfterSomeTimeTimer;

@property (nonatomic,assign)  int                   currentSaveTrintIndex;
@property (nonatomic,assign)  NSNumber              *isNewMatchFound;

@property (nonatomic,strong)  NSString* firstUploadingFile;

-(id) initWithdownLoadEntityJobName:(NSString *) jobName withRequestParameter:(id) localRequestParameter withResourcePath:(NSString *) resourcePath withHttpMethd:(NSString *) httpMethodParameter;
-(void) startMetaDataDownLoad;
-(void)uploadFileAfterGettingdatabaseValues:(ViewTCIdList*)tcList vcList:(VCIdList*)vcList audioFile:(AudioFile*)audioFile;

@end

/*================================================================================================================================================*/

@protocol DownloadMetaDataJobDelegate

- (void) messageSentResponseDidReceived:(NSDictionary *) responseDic;

@end

/*================================================================================================================================================*/
