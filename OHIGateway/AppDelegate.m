//
//  AppDelegate.m
//  Omron2
//
//  Created by Justin Helmick on 11/1/13.
//  Copyright (c) 2013 Justin Helmick. All rights reserved.
//

#import "AppDelegate.h"
#import "User_Class.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"
#import "serializeUser.h"
#import "OMNumeraConnection.h"

@implementation AppDelegate

#pragma mark - Instance Variables

NSString *deviceID = nil;

#pragma mark - Functions

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Configure the logging to xcode console & file framework
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Set directory for logging files user/documents directory
    NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains
                                    (NSCachesDirectory, NSLocalDomainMask, YES)
                                    objectAtIndex:0];
    DDLogFileManagerDefault* logFileManager = [[DDLogFileManagerDefault alloc]
                                               initWithLogsDirectory:documentsDirectory];
    DDFileLogger *fileLogger = [[DDFileLogger alloc]
                                initWithLogFileManager:logFileManager];
    
    // Set File logger properties
    [fileLogger setMaximumFileSize:(1024 * 1024)];
    [fileLogger setRollingFrequency:(3600.0 * 24.0)];
    [[fileLogger logFileManager] setMaximumNumberOfLogFiles:7];
    [DDLog addLogger:fileLogger];
    
    // Keep back button hidden temporarily & Load main menu first
    [_backButton setHidden:YES];
    
    NSString *string = [serializeUser checkXML];
    if([string isEqualToString:@"1"]) {
        [serializeUser fillUserClass];
        [_rememberme_toggle setState:NSOnState];
        NSString *namelabel = [NSString stringWithFormat:@"%@ %@", [[User_Class sharedUser] valueForKey:@"FirstName"], [[[User_Class sharedUser] valueForKey:@"LastName"] substringToIndex:1]];
        [_accountName setStringValue:namelabel];
        [_accountName setHidden:NO];
        [_menuButton setHidden:NO];
        [_deviceScroll setDocumentView:(_uploadPage)];
        [[_window contentView] addSubview:_deviceScroll];
    } else {
        [[_window contentView] addSubview:_mainMenu];
    }
    
    // Quite event handler...in progress
    NSAppleEventManager* appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self andSelector:@selector(handleQuitEvent:withReplyEvent:) forEventClass:kCoreEventClass andEventID:kAEQuitApplication];
    
    
}


- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag{
    [_window setIsVisible:YES];
    return YES;
}


- (void)handleQuitEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    if([_rememberme_toggle state] == NSOffState)
        [[User_Class sharedUser] setRememberMe:@"0"];
    if([[[User_Class sharedUser] valueForKey:@"RememberMe"]  isEqual: @"1"]) {
        [serializeUser createXML];
        [NSApp terminate: nil];
    } else {
        [serializeUser clear_serialized];
        [NSApp terminate: nil];
    }
}


- (void)awakeFromNib
{
    
    // Setup EULA PDF view
    // TODO: Move to seperate file.
    NSString *eulaPath = NSLocalizedString(@"EULA_path", nil);
    [_EulaAcceptButton setStringValue:NSLocalizedString(@"eulaAccept", @"Accept")];
    [_eulaDeclineButton setStringValue:NSLocalizedString(@"eulaDecline", @"Decline")];
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:eulaPath ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    PDFDocument *pdfDoc = [[PDFDocument alloc] initWithURL:url];
    [_pdfView setDocument:pdfDoc];
}


#pragma mark - Actions

- (IBAction)gotodevice1:(id)sender
{
    //switch to upload page
    [[_window contentView] replaceSubview:_deviceScroll with:_uploadPage];
    [_uploadDeviceTitle setStringValue:@"Alvita USB Pedometer"];
    [_uploadDeviceCode setStringValue:@"HJ-323U / HJ-322U"];
}

// Depricated
- (IBAction)gotodevice2:(id)sender
{
    [[_window contentView] replaceSubview:_deviceScroll with:_uploadPage];
    [_uploadDeviceTitle setStringValue:@"Alvita USB Pedometer Four Mode"];
    [_uploadDeviceCode setStringValue:@"HJ-322U"];
}

- (IBAction)gotodevice3:(id)sender
{
    [[_window contentView] replaceSubview:_deviceScroll with:_uploadPage];
    [_uploadDeviceTitle setStringValue:@"Tri-Axis USB Pedometer"];
    [_uploadDeviceCode setStringValue:@"HJ-324U"];
}

- (IBAction)gotodevice4:(id)sender
{
    [[_window contentView] replaceSubview:_deviceScroll with:_uploadPage];
    [_uploadDeviceTitle setStringValue:@"Walking Style Pro"];
    [_uploadDeviceCode setStringValue:@"HJ-720IT"];
}

-(IBAction)signin:(id)sender
{
    if([[_Usern stringValue] isEqualToString:@""] || [[_Pass stringValue] isEqualToString:@""]) {
        [_loginError setHidden:NO];
        
        return;
    }
    NSInteger status = [OMNumeraConnection authenticateUser:[_Usern stringValue] withPassword:[_Pass stringValue]];
    //getUser([_Usern stringValue], [_Pass stringValue]);
    [[User_Class sharedUser]  setUserName:[_Usern stringValue]];
    DDLogVerbose(@"%ld", (long)status);
    
    if(status!=0) {
        [_loginError setHidden:NO];
        DDLogVerbose(@"login failed, error: %ld", (long)status);
    } else {
        if([_remember_me state] == NSOnState) {
            [[User_Class sharedUser] setRememberMe:@"1"];
            [_rememberme_toggle setState:NSOnState];
        } else {
            [[User_Class sharedUser] setRememberMe:@"0"];
        }
        
        [_deviceScroll setDocumentView:(_deviceSelect)];
        NSPoint newOrigin = NSMakePoint(0, NSMaxY([[_deviceScroll documentView] frame]) -
                                        [[_deviceScroll contentView] bounds].size.height);
        [[_deviceScroll documentView] scrollPoint:newOrigin];
        NSString *namelabel = [NSString stringWithFormat:@"%@ ", [[User_Class sharedUser] valueForKey:@"Email"]];
        [_accountName setStringValue:namelabel];
        [_accountName setHidden:NO];
        [_menuButton setHidden:NO];
        [[_window contentView] replaceSubview:_loginView with:_deviceScroll];
        [_Usern setStringValue:@""];
        [_Pass setStringValue:@""];
        [_loginError setHidden:YES];
    }
}


- (IBAction)createAccount:(id)sender
{
    [[_window contentView] replaceSubview:_eulaView with:_createAccount];
}


- (IBAction)loginAccount:(id)sender
{
    [[_window contentView] replaceSubview:_mainMenu with:_loginView];
}


- (IBAction)toUpload:(id)sender
{
    [_deviceScroll setDocumentView:(_uploadPage)];
}


- (IBAction)showWindow:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    [_window makeKeyAndOrderFront:nil];
}


- (IBAction)backToMainFromLogin:(id)sender
{
    [[_window contentView] replaceSubview:_loginView with:_mainMenu];
}


- (IBAction)backToMainFromCreateAccount:(id)sender
{
    [[_window contentView] replaceSubview:_createAccount with:_mainMenu];
}


- (IBAction)goto_eula:(id)sender
{
    [[_window contentView] replaceSubview:_mainMenu with:_eulaView];
}

- (IBAction)backFromUpload:(id)sender
{
    [[_window contentView] replaceSubview:_uploadPage with:_deviceScroll];
    [_deviceScroll setDocumentView:(_deviceSelect)];
    NSPoint newOrigin = NSMakePoint(0, NSMaxY([[_deviceScroll documentView] frame]) -
                                    [[_deviceScroll contentView] bounds].size.height);
    [[_deviceScroll documentView] scrollPoint:newOrigin];
    [_reviewData setHidden:YES];
    [_uploadMore setHidden:YES];
    [_retryUpload setHidden:YES];
    [_startUpload setHidden:NO];
}

- (IBAction)backFromUserSelect:(id)sender {
    [_deviceScroll setDocumentView:(_deviceSelect)];
    NSPoint newOrigin = NSMakePoint(0, NSMaxY([[_deviceScroll documentView] frame]) -
                                    [[_deviceScroll contentView] bounds].size.height);
    [[_deviceScroll documentView] scrollPoint:newOrigin];
}


- (IBAction)declineEula:(id)sender {
    [[_window contentView] replaceSubview:_eulaView with:_mainMenu];
}

#pragma mark - Menu Bar Actions

- (IBAction)quit:(id)sender {
    [NSApp terminate: nil];
}


- (IBAction)showGateway:(id)sender {
    [NSApp unhide:nil];
    [NSApp activateIgnoringOtherApps:YES];
}


- (IBAction)hideGateway:(id)sender {
    [NSApp hide: nil];
}


- (IBAction)linkToWebApp:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://omronwellness.com"]];
}

- (IBAction)logout:(id)sender {
    [[User_Class sharedUser] setFirstName:nil];
    [[User_Class sharedUser] setLastName:nil];
    [[User_Class sharedUser] setAccountId:nil];
    [[User_Class sharedUser] setAccountNumber:nil];
    [[User_Class sharedUser] setEmail:nil];
    [[User_Class sharedUser] setToken:nil];
    [[User_Class sharedUser] setUserName:nil];
    [_accountName setHidden:YES];
    [_menuButton setHidden:YES];
    [serializeUser clear_serialized];
    [[_window contentView] replaceSubview:_deviceScroll with:_loginView];
    [[_window contentView] replaceSubview:_uploadPage with:_loginView];
    [[_window contentView] replaceSubview:_settingsPage with:_loginView];
}

- (IBAction)dropMenu:(id)sender {
    [NSMenu popUpContextMenu:_settingsMenu withEvent:[[NSApplication sharedApplication] currentEvent] forView:(NSButton *)sender];
}

- (IBAction)settingsto_upload:(id)sender {
    [[_window contentView] replaceSubview:_settingsPage with:_deviceScroll];
}

- (IBAction)settings_sendfeedback:(id)sender {
    NSString* toAddress = @"information@omron.com";
    NSString* subject = @"Send Feedback";
    NSString* bodyText = @"";
    NSString *mailtoAddress = [[NSString stringWithFormat:@"mailto:%@?Subject=%@&body=%@",toAddress,subject,bodyText] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:mailtoAddress]];
}

- (IBAction)goto_settings:(id)sender {
    [[_window contentView] replaceSubview:_deviceScroll with:_settingsPage];
    [[_window contentView] replaceSubview:_uploadPage with:_settingsPage];
}

#pragma mark - Settings View Actions

- (IBAction)goToUnregisterView:(id)sender {
    [[_window contentView] replaceSubview:_settingsPage with:_deviceScroll];
    [_deviceScroll setDocumentView:(_UnregisterDeviceView)];
    NSPoint newOrigin = NSMakePoint(0, NSMaxY([[_deviceScroll documentView] frame]) -
                                    [[_deviceScroll contentView] bounds].size.height);
    [[_deviceScroll documentView] scrollPoint:newOrigin];
}

#pragma mark - User Selection Actions

- (IBAction)userSelectionA:(id)sender {
    [[User_Class sharedUser] setUserSetting:1];
    if ([[_uploadDeviceCode stringValue] isEqual: @"HEM-6310F-E"]) {
        deviceID = @"40005";
        [OMNumeraConnection registerDevice:deviceID asUser:1];
        [[_window contentView] replaceSubview:_deviceScroll with:_uploadPage];
        [_uploadDeviceTitle setStringValue:@"RS8 Blood Pressure Monitor"];
        [_uploadDeviceCode setStringValue:@"HEM-6310F-E"];

    } else if ([[_uploadDeviceCode stringValue] isEqual: @"HEM-7131U-E"]) {
        deviceID = @"40017";
        [OMNumeraConnection registerDevice:deviceID asUser:1];
        [[_window contentView] replaceSubview:_deviceScroll with:_uploadPage];
        [_uploadDeviceTitle setStringValue:NSLocalizedString(@"M3_BloodPressure_Monitor", @"M3 IT Blood Pressure Monitor (HEM-7131U-E)")];
        [_uploadDeviceCode setStringValue:@"HEM-7131U-E"];

    } else if ([[_uploadDeviceCode stringValue] isEqual: @"HEM-7322U-E"]) {
        deviceID = @"40016";
        [OMNumeraConnection registerDevice:deviceID asUser:1];
        [[_window contentView] replaceSubview:_deviceScroll with:_uploadPage];
        [_uploadDeviceTitle setStringValue:NSLocalizedString(@"M6_BloodPressure_Monitor", @"M6 IT Blood Pressure Monitor (HEM-7322U-E)")];
        [_uploadDeviceCode setStringValue:@"HEM-7322U-E"];
    }
}

- (IBAction)userSelectionB:(id)sender {
    NSLog(@"USer two clicked");
    
    [[User_Class sharedUser] setUserSetting:2];
    if ([[_uploadDeviceCode stringValue] isEqual: @"HEM-6310F-E"]) {
        deviceID = @"40005";
        [OMNumeraConnection registerDevice:deviceID asUser:2];
        [[_window contentView] replaceSubview:_deviceScroll with:_uploadPage];
        [_uploadDeviceTitle setStringValue:@"RS8 Blood Pressure Monitor"];
        [_uploadDeviceCode setStringValue:@"HEM-6310F-E"];

    } else if ([[_uploadDeviceCode stringValue] isEqual: @"HEM-7131U-E"]) {
        deviceID = @"40017";
        [OMNumeraConnection registerDevice:deviceID asUser:2];
        [[_window contentView] replaceSubview:_deviceScroll with:_uploadPage];
        [_uploadDeviceTitle setStringValue:NSLocalizedString(@"M3_BloodPressure_Monitor", @"M3 IT Blood Pressure Monitor (HEM-7131U-E)")];
        [_uploadDeviceCode setStringValue:@"HEM-7131U-E"];
        
    } else if ([[_uploadDeviceCode stringValue] isEqual: @"HEM-7322U-E"]) {
        deviceID = @"40016";
        [OMNumeraConnection registerDevice:deviceID asUser:2];
        [[_window contentView] replaceSubview:_deviceScroll with:_uploadPage];
        [_uploadDeviceTitle setStringValue:NSLocalizedString(@"M6_BloodPressure_Monitor", @"M6 IT Blood Pressure Monitor (HEM-7322U-E)")];        
        [_uploadDeviceCode setStringValue:@"HEM-7322U-E"];        
    }
}

#pragma mark - Unregister Device Actions

- (IBAction)unregisterDeviceOne:(id)sender {
    [OMNumeraConnection registerDevice:@"40005" asUser:-1];
    [_deviceScroll setDocumentView:(_deviceSelect)];
    NSPoint newOrigin = NSMakePoint(0, NSMaxY([[_deviceScroll documentView] frame]) -
                                    [[_deviceScroll contentView] bounds].size.height);
    [[_deviceScroll documentView] scrollPoint:newOrigin];
}

- (IBAction)unregisterDeviceTwo:(id)sender {
    [OMNumeraConnection registerDevice:@"40017" asUser:-1];
    [_deviceScroll setDocumentView:(_deviceSelect)];
    NSPoint newOrigin = NSMakePoint(0, NSMaxY([[_deviceScroll documentView] frame]) -
                                    [[_deviceScroll contentView] bounds].size.height);
    [[_deviceScroll documentView] scrollPoint:newOrigin];
}

- (IBAction)unregisterDeviceThree:(id)sender {
    [OMNumeraConnection registerDevice:@"40016" asUser:-1];
    [_deviceScroll setDocumentView:(_deviceSelect)];
    NSPoint newOrigin = NSMakePoint(0, NSMaxY([[_deviceScroll documentView] frame]) -
                                    [[_deviceScroll contentView] bounds].size.height);
    [[_deviceScroll documentView] scrollPoint:newOrigin];
}
@end
