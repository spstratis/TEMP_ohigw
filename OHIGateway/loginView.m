//
//  loginView.m
//  Omron
//
//  Created by Justin Helmick on 4/5/13.
//  Copyright (c) 2013 Justin Helmick. All rights reserved.
//

#import "loginView.h"
#import "NSButton+GWButton.h"

@implementation loginView

- (id)initWithFrame:(NSRect)frame
{

    self = [super initWithFrame:frame];
    if (self) {
        }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSColor *omronBlue = [NSColor colorWithCalibratedRed:(10/255.0f) green:(114/255.0f) blue:(188/255.0f) alpha:1.0];
    NSMutableParagraphStyle *centredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [centredStyle setAlignment:NSCenterTextAlignment];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                           NSParagraphStyleAttributeName,
                           [NSFont fontWithName:(@"Menlo Regular") size:14],
                           NSFontAttributeName,
                           [NSColor whiteColor],
                           NSForegroundColorAttributeName,
                           nil];
    NSMutableAttributedString *attributedString =
    [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"SIGN_IN", @"sign in text")
                                           attributes:attrs];

    [_forgotPW setTitleColor: omronBlue];
    [_signin setAttributedTitle: attributedString];
    
    [_usernameLabel setStringValue:NSLocalizedString(@"LoginView_Username", @"Username")];
    [_passwordLabel setStringValue:NSLocalizedString(@"LoginView_Password", @"Password")];
    [_rememberMeLabel setStringValue:NSLocalizedString(@"LoginView_RememberMe", @"Remember Me")];
    [_forgotPW setStringValue:NSLocalizedString(@"LoginView_ForgotPassword", @"Forgot Password?")];
    _usernameLabel.textColor = [NSColor grayColor];
    _passwordLabel.textColor = [NSColor grayColor];
    _rememberMeLabel.textColor = [NSColor grayColor];

    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
}



-(IBAction)forgotPW:(id)sender
{
    
    [[NSWorkspace sharedWorkspace]
        openURL:[NSURL URLWithString:@"https://my.numera-staging.com/nis/index?wa=wsignin1.0&wctx=nis.forgot&wtrealm=http://OHI.Staging&wreply=https://ohi.numerasocial.com/Dashboard/Overview&wauth=http://swt"]];
}

@end
