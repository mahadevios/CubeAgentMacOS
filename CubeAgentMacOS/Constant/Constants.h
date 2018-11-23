//
//  Header.h
//  Cube
//
//  Created by mac on 13/08/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#ifndef Header_h
#define Header_h

//#define  BASE_URL_PATH                        @"http://www.xanadutec.net/cubeagent_webapi/api"
//
//#define  BASE_URL_PATH                        @"http://192.168.3.150:8081/CubeAPI/api"
//#define  CHECK_DEVICE_REGISTRATION            @"MobileCheckDeviceRegistration"
//#define  AUTHENTICATE_API                     @"MobileAuthenticate"
//#define  ACCEPT_PIN_API                       @"MobileAcceptPIN"
//#define  VALIDATE_PIN_API                     @"MobileValidatePIN"
//#define  DICTATIONS_INSERT_API                @"MobileDictationsInsert"
//#define  DATA_SYNCHRONISATION_API             @"MobileDataSynchronisation"
//#define  FILE_UPLOAD_API                      @"MobileFileUpload"
//#define  PIN_CANGE_API                        @"MobilePINChange"

#define  BASE_URL_PATH                        @"http://192.168.3.156:8081/CubeAPI/api"
//#define  BASE_URL_PATH                        @"https://www.cubescribe.com/cubeagent_webapi/api"

//#define  BASE_URL_PATH                        @"http://192.168.3.150:8081/CubeAPI/api"
#define UPDATE_MAC_ID                         @"MacBook_UpdateMACID"

#define  CHECK_DEVICE_REGISTRATION            @"encrdecr_MobileCheckDeviceRegistration"
//DDCF3B2D-362B-4C81-8AB3-DD56D49E5365
//#define  AUTHENTICATE_API                     @"UpdateMACID"
#define  AUTHENTICATE_API                     @"encrdecr_MobileAuthenticate"


#define  ACCEPT_PIN_API                       @"encrdecr_MobileAcceptPIN"
#define  VALIDATE_PIN_API                     @"encrdecr_MobileValidatePIN"
#define  DICTATIONS_INSERT_API                @"encrdecr_MobileDictationsInsert"
#define  DATA_SYNCHRONISATION_API             @"encrdecr_MobileDataSynchronisation"
#define  FILE_UPLOAD_API                      @"encrdecr_MobileFileUpload"
#define  PIN_CANGE_API                        @"encrdecr_MobilePINChange"
#define  SECRET_KEY                           @"cubemob"
#define  POST                           @"POST"
#define  GET                            @"GET"
#define  PUT                            @"PUT"
#define  REQUEST_PARAMETER              @"requestParameter"
#define  SUCCESS                        @"1000"
#define  FAILURE                        @"1001"


//NSNOTIFICATION

#define NOTIFICATION_CHECK_DEVICE_REGISTRATION      @"notificationForMobileCheckDeviceRegistration"




#define CURRENT_VESRION                        @"currentVersion"
#define IS_DATE_FORMAT_UPDATED                 @"dateFormatUpdated"

#define RECORDING_LIMIT                        3600

#define PURGE_DATA_DATE                        @"purgeDataDate"

#define ALERT_TAB_LOCATION                     3

//#define APPLICATION_TERMINATE_CALLED           @"applicationTerminate"


#define INCOMPLETE_TRANSFER_COUNT_BADGE        @"Incomplete Count"
#define SELECTED_DEPARTMENT_NAME               @"Selected Department"
#define SELECTED_DEPARTMENT_NAME_COPY          @"Selected Department Copy"
#define AUDIO_FILES_FOLDER_NAME                @"Audio files"
//#define DATE_TIME_FORMAT                       @"MM-dd-yyyy HH:mm:ss"
#define DATE_TIME_FORMAT                       @"yyyy-MM-dd HH:mm:ss"

#define RESPONSE_CODE                          @"code"
#define RESPONSE_PIN_VERIFY                    @"pinverify"


#define SHARED_GROUP_IDENTIFIER                @"group.com.coreFlexSolutions.CubeDictate"
//#define MAC_ID                                 @"e0:2c:b2:eb:5a:8e"
//#define MAC_ID                                 @"e0:2c:b2:ec:5a:8e"

//#define MAC_ID                                 @"e0:2c:b2:ec:5a:8f"

#endif /* Header_h */
