//
//  CubeConfig.h
//  CubeAgentMacOS
//
//  Created by mac on 30/11/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CubeConfig : NSObject

@property (nonatomic, strong) NSString*  hashAlgorithm;
@property (nonatomic, strong) NSString*  EncPassWord;
@property (nonatomic, strong) NSString*  FTPAudioDirectory;
@property (nonatomic, strong) NSString*  FTPDocDirectory;
@property (nonatomic, strong) NSString*  FTPIP;
@property (nonatomic, strong) NSString*  FTPPassword;
@property (nonatomic, strong) NSString*  FTPUser;
@property (nonatomic, strong) NSString*  GroupID;
@property (nonatomic) int  ParentCompanyID;
@property (nonatomic, strong) NSString*  SQLIP;
@property (nonatomic, strong) NSString*  SQLPassword;
@property (nonatomic, strong) NSString*  SQLUser;
@property (nonatomic) long  SchedularTime;
@property (nonatomic, strong) NSString*  ServerCubeDirectory;


@end

NS_ASSUME_NONNULL_END
