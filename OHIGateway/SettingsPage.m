//
//  SettingsPage.m
//  Omron2
//
//  Created by justin helmick on 5/23/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import "SettingsPage.h"
#import "User_Class.h"
#import "OMNumeraConnection.h"

@implementation SettingsPage

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSString *namelabel = [NSString stringWithFormat:@"%@ %@", [[User_Class sharedUser] valueForKey:@"FirstName"], [[[User_Class sharedUser] valueForKey:@"LastName"] substringToIndex:1]];
    [_remembermeLabel setStringValue:NSLocalizedString(@"Remember Me", @"Remember Me")];
    [_removeuserLabel setStringValue:NSLocalizedString(@"Unregister Device", @"Remove User")];
    [_name_settings setStringValue:namelabel];
    [_email_settings setStringValue:[[User_Class sharedUser] valueForKey:@"Email"]];
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
}

#pragma mark - Functions


#pragma mark - Actions

- (IBAction)sendlog:(id)sender {
    NSString *bodyText = @"Log \n\r";
    NSString *subject = @"Send Feedback";
    NSString *toAddress = @"jfhelmick@gmail.com";
    NSString *emailString = [NSString stringWithFormat:@"\
                             tell application \"Mail\"\n\
                             set newMessage to make new outgoing message with properties {subject:\"%@\", content:\"%@\" & return} \n\
                             tell newMessage\n\
                             set visible to false\n\
                             set sender to \"%@\"\n\
                             make new to recipient at end of to recipients with properties {name:\"%@\", address:\"%@\"}\n\
                             tell content\n\
                             ",subject, bodyText, @"McAlarm alert", @"McAlarm User", toAddress ];
    //add attachments to script
    NSString* attachment = @"~/Library/Logs/stackshot.log";
    emailString = [emailString stringByAppendingFormat:@"make new attachment with properties {file name:\"%@\"} at after the last paragraph\n\
                       ",attachment];
    
    //finish script
    emailString = [emailString stringByAppendingFormat:@"\
                   end tell\n\
                   send\n\
                   end tell\n\
                   end tell"];
    
    
    
    //NSLog(@"%@",emailString);
    NSAppleScript *emailScript = [[NSAppleScript alloc] initWithSource:emailString];
    [emailScript executeAndReturnError:nil];
    
    /* send the message */
    NSLog(@"Message passed to Mail");
}

- (IBAction)unregisterDevice:(id)sender
{
    [OMNumeraConnection registerDevice:@"40005" asUser:-1];
    NSAlert *unregisterAlert =[[NSAlert alloc] init];
    [unregisterAlert runModal];
    
}

@end
