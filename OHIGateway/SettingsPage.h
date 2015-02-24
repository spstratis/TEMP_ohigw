//
//  SettingsPage.h
//  Omron2
//
//  Created by justin helmick on 5/23/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SettingsPage : NSView

@property (weak) IBOutlet NSTextField *name_settings;
@property (weak) IBOutlet NSTextField *email_settings;
@property (weak) IBOutlet NSButton *uploadhistory;
@property (weak) IBOutlet NSButton *rememberme_toggle;

@property (unsafe_unretained) IBOutlet NSWindow *mainWindow;
@property (weak) IBOutlet NSView *UnregisterDeviceView;
@property (weak) IBOutlet NSTextField *remembermeLabel;
@property (weak) IBOutlet NSTextField *removeuserLabel;

- (IBAction)sendlog:(id)sender;



@end
