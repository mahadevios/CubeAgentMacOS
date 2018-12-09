//
//  AppPreferences.h
//  Communicator
//
//  Created by mac on 05/04/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Reachability.h"
#import "CubeConfig.h"
#import "User.h"


@protocol AppPreferencesDelegate;

@interface AppPreferences : NSObject 
{
    id<AppPreferencesDelegate> alertDelegate;
    
    
}

@property (nonatomic,strong)    id<AppPreferencesDelegate> alertDelegate;

@property (nonatomic)           int     currentSelectedItem;

@property (nonatomic,assign)    BOOL                        isReachable;






//@property(nonatomic,strong)NSURLSessionUploadTask *uploadTask;
+(AppPreferences *) sharedAppPreferences;

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;

@property (nonatomic, strong) User *loggedInUser;
@property (nonatomic, strong) CubeConfig *cubeConfig;
@property (nonatomic, strong) NSMutableArray *supportedAudioFileExtensions;
@property (nonatomic, strong) NSString *transCompanyName;
@property (nonatomic, strong) NSMutableDictionary* progressCountFileNameDict;
@property (nonatomic, strong) NSString *currentUploadingFileName;
@property (nonatomic) int currentUploadingPercentage;
@property (nonatomic) long totalUploadedCount;
@property (nonatomic) NSUInteger     uploadFilesQueueCount;
@property(nonatomic, strong) NSMutableArray* nextToBeUploadedPoolArray;
@property(nonatomic, strong) NSOperationQueue *audioUploadQueue;

-(void) startReachabilityNotifier;
-(void)createDatabaseReplica;

-(NSString*)getUsernameInregrationDirectoryPath;

-(NSString*)getUsernameUploadAudioDirectoryPath;

-(NSString*)getUsernameTranscriptionDirectoryPath;

-(NSString*)getUsernameBacupAudioDirectoryPath;

-(NSString*)getCubeTempDirectoryPath;

-(NSString*)getCubeLogDirectoryPath;

-(NSString*)getCubeFilesDirectoryPath;

-(void)deleteFileAtPath:(NSString*)filePath;

-(void)moveAudioFileToBackup:(NSString*)filePath;

-(uint64_t)getFileSize:(NSString*)filePath;

@end


@protocol AppPreferencesDelegate

@optional
-(void) appPreferencesAlertButtonWithIndex:(int) buttonIndex withAlertTag:(int) alertTag;
@end
