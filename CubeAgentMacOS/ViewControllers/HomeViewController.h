//
//  HomeViewController.h
//  CubeAgentMacOS
//
//  Created by Martina Makasare on 11/29/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : NSViewController
{
    NSMutableArray *listOfAudioToUploadFiles;
}
@property (weak) IBOutlet NSTextField *finishedCheckingFilesLabel;
@property (weak) IBOutlet NSScrollView *logTextView;
@property (weak) IBOutlet NSScrollView *fileListingTableView;
@property (weak) IBOutlet NSScrollView *directoryOutline;

@end

NS_ASSUME_NONNULL_END
