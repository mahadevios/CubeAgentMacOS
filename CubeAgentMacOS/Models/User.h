//
//  User.h
//  CubeAgentMacOS
//
//  Created by mac on 30/11/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject

@property (nonatomic) long  userId;
@property (nonatomic, strong) NSString*  userName;
@property (nonatomic, strong) NSString*  macId;
@property (nonatomic, strong) NSString*  password;

//+(User*)getLoggedInUser;

@end

NS_ASSUME_NONNULL_END
