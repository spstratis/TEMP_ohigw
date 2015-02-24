//
//  UserSelectionView.h
//  Bi-LINK Gateway
//
//  Created by S.Stratis on 9/9/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface UserSelectionView : NSView

@property (weak) IBOutlet NSTextField *userASerial;
@property (weak) IBOutlet NSTextField *userBSerial;
@property (weak) IBOutlet NSTextField *selectLabel;
@property (weak) IBOutlet NSTextField *userA;
@property (weak) IBOutlet NSTextField *userB;

@end
