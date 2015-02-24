//
//  loginView.h
//  Omron
//
//  Created by Justin Helmick on 4/5/13.
//  Copyright (c) 2013 Justin Helmick. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface loginView : NSView{
}

@property (weak) IBOutlet NSButton *signin;
@property (weak) IBOutlet NSButton *forgotPW;
@property (weak) IBOutlet NSTextField *usernameLabel;
@property (weak) IBOutlet NSTextField *passwordLabel;
@property (weak) IBOutlet NSTextField *rememberMeLabel;

-(IBAction)forgotPW:(id)sender;

@end
