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
#import <Cocoa/Cocoa.h>
#import "BaseLogFileManager.h"


@protocol AppPreferencesDelegate;

@interface AppPreferences : NSObject 
{
    id<AppPreferencesDelegate> alertDelegate;
    
    NSAlert *alert;

    
}

@property (nonatomic,strong)    id<AppPreferencesDelegate> alertDelegate;

@property (nonatomic)           int     currentSelectedItem;

@property (nonatomic,assign)    BOOL                        isReachable;

@property(nonatomic) BOOL isLoggerAdded;




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
@property(nonatomic, strong) NSMutableArray* nextBlockToBeUploadPoolArray;
@property(nonatomic, strong) NSMutableArray* nextBlockToBeDownloadPoolArray;
@property(nonatomic, strong) NSOperationQueue *audioUploadQueue;
@property(nonatomic, strong) NSOperationQueue *docDownloadQueue;
@property (nonatomic) long totalFilesToBeAddedInTableView;
@property (nonatomic) long currentUploadingTableViewRow;

-(void) startReachabilityNotifier;

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

-(NSString*)getDateWiseBackUpAudioFolderPath;

-(NSString*)getDateWiseTranscriptionFolderPath;

-(void)showAlertWithTitle:(NSString*)title subTitle:(NSString*)subTitle;

-(void)addLoggerOnce;

@end


@protocol AppPreferencesDelegate

@optional
-(void) appPreferencesAlertButtonWithIndex:(int) buttonIndex withAlertTag:(int) alertTag;
@end
