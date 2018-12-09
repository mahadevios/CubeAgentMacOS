//
//  AudioFile.h
//  CubeAgentMacOS
//
//  Created by mac on 09/12/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioFile : NSObject

@property (nonatomic, strong) NSString*  fileName;
@property (nonatomic, strong) NSString*  originalFileName;
@property (nonatomic, strong) NSString*  originalFileNamePath;
@property (nonatomic, strong) NSString*  status;
@property (nonatomic) long    fileSize;
@property (nonatomic) long    totalBytesSent;

@end

NS_ASSUME_NONNULL_END
