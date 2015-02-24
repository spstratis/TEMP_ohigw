//
//  AppDelegate.h
//  Omron2
//
//  Created by Justin Helmick on 11/1/13.
//  Copyright (c) 2013 Justin Helmick. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {

#pragma mark - Instasnce Variables
    NSStatusItem *statusItem;
    NSImage *systrayIcon;
    IBOutlet NSMenu *menu;
    IBOutlet NSMenuItem *submenu;
}

#pragma mark - Main App
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSView *omronHeader;
@property (weak) IBOutlet NSButton *menuButton;
@property (weak) IBOutlet NSButton *backButton;
@property (weak) IBOutlet NSTextField *accountName;
@property (weak) IBOutlet NSView *UnregisterDeviceView;

#pragma mark - Login & Account Creation
@property (weak) IBOutlet NSView *loginError;
@property (weak) IBOutlet NSView *loginView;
@property (weak) IBOutlet NSView *mainMenu;
@property (weak) IBOutlet NSButton *createAccountBack;
@property (weak) IBOutlet NSButton *loginPageBack;
@property (weak) IBOutlet NSTextField *Usern;
@property (weak) IBOutlet NSTextField *Pass;
@property (weak) IBOutlet NSView *createAccount;

#pragma mark - Upload Data View
@property (weak) IBOutlet NSTextField *uploadDeviceTitle;
@property (weak) IBOutlet NSTextField *uploadDeviceCode;
@property (weak) IBOutlet NSView *uploadPage;

#pragma mark - Eula View 
@property (weak) IBOutlet NSView *eulaView;
@property(assign) IBOutlet PDFView *pdfView;
@property (weak) IBOutlet NSButton *EulaAcceptButton;
@property (weak) IBOutlet NSButton *eulaDeclineButton;

#pragma mark - User & Device Select View
@property (weak) IBOutlet NSView *userSelectionPage;
@property (weak) IBOutlet NSTextField *userASerial;
@property (weak) IBOutlet NSTextField *userBSerial;
@property (weak) IBOutlet NSView *deviceSelect;
@property (weak) IBOutlet NSScrollView *deviceScroll;
@property (weak) IBOutlet NSTextField *userSelectDeviceSerial;

#pragma mark - Settings View
@property (weak) IBOutlet NSMenu *settingsMenu;
@property (weak) IBOutlet NSView *settingsPage;
@property (weak) IBOutlet NSButton *remember_me;
@property (weak) IBOutlet NSButton *rememberme_toggle;
@property (weak) IBOutlet NSButton *reviewData;
@property (weak) IBOutlet NSButton *uploadMore;
@property (weak) IBOutlet NSButton *startUpload;
@property (weak) IBOutlet NSButton *retryUpload;


- (IBAction)gotodevice1:(id)sender;
- (IBAction)gotodevice2:(id)sender;
- (IBAction)gotodevice3:(id)sender;
- (IBAction)signin:(id)sender;
- (IBAction)createAccount:(id)sender;
- (IBAction)loginAccount:(id)sender;
- (IBAction)toUpload:(id)sender;
- (IBAction)linkToWebApp:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)backToMainFromCreateAccount:(id)sender;
- (IBAction)backToMainFromLogin:(id)sender;
- (IBAction)dropMenu:(id)sender;
- (IBAction)settingsto_upload:(id)sender;
- (IBAction)settings_sendfeedback:(id)sender;
- (IBAction)goto_settings:(id)sender;
- (IBAction)goto_eula:(id)sender;
- (IBAction)backFromUpload:(id)sender;
- (IBAction)backFromUserSelect:(id)sender;
- (IBAction)goToUnregisterView:(id)sender;
- (IBAction)userSelectionA:(id)sender;
- (IBAction)userSelectionB:(id)sender;
- (IBAction)unregisterDeviceOne:(id)sender;
- (IBAction)unregisterDeviceTwo:(id)sender;
- (IBAction)unregisterDeviceThree:(id)sender;


@end