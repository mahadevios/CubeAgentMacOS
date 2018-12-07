//
//  ViewTCIdList.h
//  CubeAgentMacOS
//
//  Created by mac on 05/12/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewTCIdList : NSObject

@property(nonatomic, strong) NSString* ClientName;
@property(nonatomic, strong) NSString* ClinicName;
@property(nonatomic, strong) NSString* DictatorFirstName;
@property(nonatomic, strong) NSString* DictatorLastName;
@property(nonatomic) int ParentCompanyID;
@property(nonatomic) int TCID;
@property(nonatomic, strong) NSString* TCName;
@property(nonatomic) long UserID;
@property(nonatomic, strong) NSString* UserName;
@property(nonatomic, strong) NSString* Verify;


@end

NS_ASSUME_NONNULL_END
