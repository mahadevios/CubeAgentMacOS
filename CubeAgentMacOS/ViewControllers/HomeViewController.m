//
//  HomeViewController.m
//  CubeAgentMacOS
//
//  Created by Martina Makasare on 11/29/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//
//com.apple.security.temporary-exception.files.home-relative-path.read-write
#import "HomeViewController.h"
#import "APIManager.h"
#import "Constants.h"
#import "AppPreferences.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateSingleQueryReponse:) name:NOTIFICATION_GET_SINGLE_QEURY_EXECUTE_QUERY_API
                                               object:nil];
    
    NSString* StrSQL = [NSString stringWithFormat:@"Select d.DictatorFirstName  + ' ' + d.DictatorLastName as DictatorFullName from Users a inner join Clinics b on a.ParentCompanyID=b.ClinicID INNER JOIN Dictators d on d.DictatorID=a.UserID WHERE a.UserID=%ld",[AppPreferences sharedAppPreferences].loggedInUser.userId];
   
//    NSString *escaped = [StrSQL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [[APIManager sharedManager] getSingleQueryValueComment:StrSQL];

    [self getFilesToBeUploadFromUploadFilesFolder];

//    [[APIManager sharedManager] getEncryptDecryptString];
}

-(void)validateSingleQueryReponse:(NSNotification*)notification
{
    NSString* responseString = notification.object;
    
    NSLog(@"");
}

-(void)getFilesToBeUploadFromUploadFilesFolder
{
    [AppPreferences sharedAppPreferences].loggedInUser = [User new];
    
    [AppPreferences sharedAppPreferences].loggedInUser.userName = @"Sanjay";
    
    NSString* filePath =  [[AppPreferences sharedAppPreferences] getUsernameUploadAudioDirectoryPath];
    
    NSError * error;
    
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:&error];
    
   
    NSLog(@"directoryContents ====== %@",directoryContents);
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:&error] ;
    
    NSMutableArray *listOfAudioFiles = [NSMutableArray arrayWithCapacity:0];
    
    // Check for Images of supported type
    for(NSString *filepath in contents)
    {
        if ([[AppPreferences sharedAppPreferences].supportedAudioFileExtensions containsObject:[filepath pathExtension]])
        {
            // Found Image File
            [listOfAudioFiles addObject:filepath];
        }
    }
    NSLog(@"directoryContents ====== %@",directoryContents);

    [self getAllFiles:filePath];
}

-(void)getAllFiles:(NSString*)documentsDir
{
    NSFileManager *fileMgr;
    NSString *entry;
    NSDirectoryEnumerator *enumerator;
    BOOL isDirectory;
    
    // Create file manager
    fileMgr = [NSFileManager defaultManager];
    
    // Path to documents directory
    
    // Change to Documents directory
    [fileMgr changeCurrentDirectoryPath:documentsDir];
    
    // Enumerator for docs directory
    enumerator = [fileMgr enumeratorAtPath:documentsDir];
    
    NSMutableArray *contents = [NSMutableArray new] ;

    // Get each entry (file or folder)
    while ((entry = [enumerator nextObject]) != nil)
    {
        // File or directory
        if ([fileMgr fileExistsAtPath:entry isDirectory:&isDirectory] && isDirectory)
            NSLog (@"Directory - %@", entry);
        else
        {
            NSLog (@"  File - %@", entry.lastPathComponent);

            [contents addObject:entry.lastPathComponent];
        }
    }
    
    listOfAudioToUploadFiles = [NSMutableArray new];

    for(NSString *filepath in contents)
    {
        if ([[AppPreferences sharedAppPreferences].supportedAudioFileExtensions containsObject:[filepath pathExtension]])
        {
            // Found Image File
            [listOfAudioToUploadFiles addObject:filepath];
        }
    }
    NSLog(@"directoryContents ====== %@",@"ds");

}

@end

