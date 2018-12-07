//
//  HomeViewController.h
//  CubeAgentMacOS
//
//  Created by Martina Makasare on 11/29/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViewTCIdList.h"
#import "VCIdList.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : NSViewController
{
    NSMutableArray *listOfAudioToUploadFiles;
    NSMutableDictionary *listOfAudioFilesToUploadDict;

    ViewTCIdList* tcIdList;
    VCIdList* vcIdList;
    NSOperationQueue *queue;
}
@property (weak) IBOutlet NSTextField *finishedCheckingFilesLabel;
@property (weak) IBOutlet NSScrollView *logTextView;
@property (weak) IBOutlet NSScrollView *fileListingTableView;
@property (weak) IBOutlet NSScrollView *directoryOutline;
- (IBAction)pasteAudioFilesButtonClicked:(id)sender;
- (IBAction)getDownloadedFilesButtonClicked:(id)sender;
- (IBAction)getBackupFilesButtonClicked:(id)sender;
@property (weak) IBOutlet NSButton *backupFileButton;
@property (weak) IBOutlet NSButton *getDownloadFileButton;
@property (weak) IBOutlet NSButton *pasteAudioFileButton;

@end

NS_ASSUME_NONNULL_END
