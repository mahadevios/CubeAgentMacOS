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


-(void) startReachabilityNotifier;
-(void)createDatabaseReplica;

-(NSString*)getUsernameInregrationDirectoryPath;

-(NSString*)getUsernameUploadAudioDirectoryPath;

-(NSString*)getUsernameTranscriptionDirectoryPath;

-(NSString*)getUsernameBacupAudioDirectoryPath;

-(NSString*)getCubeTempDirectoryPath;

-(NSString*)getCubeLogDirectoryPath;

-(NSString*)getCubeFilesDirectoryPath;

@end


@protocol AppPreferencesDelegate

@optional
-(void) appPreferencesAlertButtonWithIndex:(int) buttonIndex withAlertTag:(int) alertTag;
@end
