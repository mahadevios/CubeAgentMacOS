//
//  ViewController.h
//  CubeAgent
//
//  Created by mac on 20/11/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "APIManager.h"
#import "AppPreferences.h"
#import "MBProgressHUD.h"


@interface ViewController : NSViewController<NSWindowDelegate>
{
    MBProgressHUD* hud;
    NSAlert *alert;
    NSOpenPanel* openDlg;
}
@property (weak) IBOutlet NSButton *autoModeCheckBox;
- (IBAction)autoModeCheckBoxClicked:(id)sender;
@property (weak) IBOutlet NSButton *rememberMeCheckBox;
- (IBAction)rememberMeCheckBoxClicked:(id)sender;
@property (weak) IBOutlet NSButton *submitButton;
- (IBAction)submitButtonClicked:(id)sender;
@property (weak) IBOutlet NSTextField *loginTextField;
@property (weak) IBOutlet NSSecureTextField *paswordTextField;
@property (weak) IBOutlet NSTextField *macIdLabel;
@property (weak) IBOutlet NSTextField *versionLabel;
@property(nonatomic, strong)NSSavePanel* savePanel;
@property (weak) IBOutlet NSView *backgroundView;

@end

