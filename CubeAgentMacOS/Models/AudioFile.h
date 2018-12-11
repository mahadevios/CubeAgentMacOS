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
@property (nonatomic, strong) NSString*  fileType;
@property (nonatomic) long    fileSize;
@property (nonatomic) long    totalBytesSent;
@property (nonatomic) long    bytesSent;
@property (nonatomic) int    rowNumber;

//    DictationID = 652543;
//    DictationStatus = 9;
//    DictatorID = 407;
//    FileData
//    FileName = "407_652543.wav.fcfe";
//    FileServerPath = "D:\\tempuploadAPI\\Inhouse-TC-test-clinic\\test-clinic\\Sanjay_407\\100616";
//    FileSize = 1048192;
//    OriginalFileName = "MOB-1465553738974.wav";
//    id
@end

NS_ASSUME_NONNULL_END
