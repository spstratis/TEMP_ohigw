//
//  mainMenu.m
//  Omron2
//
//  Created by Justin Helmick on 12/13/13.
//  Copyright (c) 2013 Justin Helmick. All rights reserved.
//

#import "mainMenu.h"

@implementation mainMenu

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
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
    
    _createAccountLabel.stringValue = NSLocalizedString(@"Create Account", @"Main Menu Create account label");
    _createAccountLabel.textColor = [NSColor grayColor];
    _loginWithUserLabel.stringValue = NSLocalizedString(@"Log In Using Existing Account", @"log in with account menu item label");
    _loginWithUserLabel.textColor = [NSColor grayColor];
}

@end
