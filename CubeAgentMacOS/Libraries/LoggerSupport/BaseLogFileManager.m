
#import "BaseLogFileManager.h"
#import "AppPreferences.h"


@implementation BaseLogFileManager

-(NSString *)newLogFileName
{
//    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    NSString *timeStamp = [self getTimestamp];
    
    return [NSString stringWithFormat:@"%@.log", timeStamp];

//    return [NSString stringWithFormat:@"%@%@.log", appName, timeStamp];
}

-(BOOL)isLogFile:(NSString *)fileName
{
    NSString* todaysDate = [self getTimestamp];
    
    NSString* logDirectoryPath = [[AppPreferences sharedAppPreferences] getCubeLogDirectoryPath];
    
    NSString* todaysLogFileName = [todaysDate stringByAppendingString:@".log"];
    
    NSString* logFilePath = [logDirectoryPath stringByAppendingPathComponent:todaysLogFileName];
    
    BOOL fileExist = [self isLogFileExist:logFilePath];
    
    return fileExist;
}

-(BOOL)isLogFileExist:(NSString*)logFilePath
{
    
    //    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    return [[NSFileManager defaultManager] fileExistsAtPath:logFilePath];
    
    //    return [NSString stringWithFormat:@"%@%@.log", appName, timeStamp];
}
-(NSString *)getTimestamp {
    static dispatch_once_t onceToken;
    static NSDateFormatter *dateFormatter;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"ddMMYY"];

//        [dateFormatter setDateFormat:@"YYYY.MM.dd-HH.mm.ss"];
    });
    
    return [dateFormatter stringFromDate:NSDate.date];
}

@end
