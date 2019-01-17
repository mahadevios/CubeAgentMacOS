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

@interface HomeViewController : NSViewController<NSTableViewDataSource,NSTableViewDelegate,NSOutlineViewDataSource,NSOutlineViewDelegate>
{
    NSMutableArray *listOfAudioToUploadFiles;
    NSMutableDictionary *listOfAudioFilesToUploadDict;

    ViewTCIdList* tcIdList;
    VCIdList* vcIdList1;
    NSTimer* progressTimer;
    NSTimer* checkForNewFilesTimer;
    NSTimer* folderGeneratedTimer;
    int totalFilesToBeAddedInTableView;
    
    NSArray* dataSource;
    NSDictionary *firstParent;
    
    NSDictionary *secondParent;
     NSOpenPanel* openDlg;
    NSArray *list;
    bool isTimerStartedFirstTime;
    NSWindow *window ;
    ;
}
@property (weak) IBOutlet NSTableView *tableView;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;

@property (weak) IBOutlet NSScrollView *fileListingTableView;
@property (weak) IBOutlet NSScrollView *directoryOutline;
- (IBAction)pasteAudioFilesButtonClicked:(id)sender;
- (IBAction)getDownloadedFilesButtonClicked:(id)sender;
- (IBAction)getBackupFilesButtonClicked:(id)sender;
@property (weak) IBOutlet NSButton *backupFileButton;
@property (weak) IBOutlet NSButton *getDownloadFileButton;
@property (weak) IBOutlet NSButton *pasteAudioFileButton;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSTextField *uploadingCountLabel;
@property (weak) IBOutlet NSTextField *checkingFilesLabel;
@property (nonatomic, strong) NSMutableArray*  uploadedAudioFilesArrayForTableView;
@property (nonatomic, strong) NSMutableArray*  queueAudioFilesArrayForTableView;
@property (nonatomic, strong) NSMutableArray*  dictationIdsArrayForDownload;
@property (nonatomic, strong) NSMutableArray*  audioFileAddedInQueueArray;
@property (nonatomic, strong) NSMutableArray*  duplicateFileCheckArray;
@property (nonatomic, strong) NSMutableArray*  validForTCIdCallNonDuplicateAudioArray;

@property (weak) IBOutlet NSView *homeBackgroundView;
@property (weak) IBOutlet NSOutlineView *outlineView;
// ---> decalring method for setting background color of the buttons and view
-(void) setBackgroundColorOFButtonsAndView;

@end

NS_ASSUME_NONNULL_END
