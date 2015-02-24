//
//  createAccount.h
//  Omron2
//
//  Created by Justin Helmick on 12/13/13.
//  Copyright (c) 2013 Justin Helmick. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface createAccount : NSView<NSWindowDelegate>

- (IBAction)createUser:(id)sender;
-(BOOL) NSStringIsValidEmail:(NSString *)checkString;

@property (weak) IBOutlet NSWindow *mainWindow;
@property (weak) IBOutlet NSTextField *fname;
@property (weak) IBOutlet NSTextField *lname;
@property (weak) IBOutlet NSTextField *email;
@property (weak) IBOutlet NSTextField *pword;
@property (weak) IBOutlet NSTextField *confirm;
@property (weak) IBOutlet NSScrollView *deviceScroll;
@property (weak) IBOutlet NSView *deviceSelect;
@property (weak) IBOutlet NSTextField *username;
@property (weak) IBOutlet NSButton *signin;
@property (weak) IBOutlet NSView *mainMenu;
@property (weak) IBOutlet NSPopUpButton *culture;
@property (weak) IBOutlet NSPopUpButton *country;
@property (weak) IBOutlet NSPopUpButton *timezone;
@property (weak) IBOutlet NSTextField *errorField;
@property (weak) IBOutlet NSView *createError;

@end