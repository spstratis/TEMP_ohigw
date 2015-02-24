//
//  UserSelectionView.m
//  Bi-LINK Gateway
//
//  Created by S.Stratis on 9/9/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import "UserSelectionView.h"

@implementation UserSelectionView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [_userBSerial setStringValue:[_userASerial stringValue]];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
    [_selectLabel setStringValue:NSLocalizedString(@"UserSelection_SelectLabel", @"Select the default user of the device")];
    [_userA setStringValue:NSLocalizedString(@"UserSelection_UserA", @"User A")];
    [_userB setStringValue:NSLocalizedString(@"UserSelection_UserB", @"User B")];
    // Drawing code here.
}

@end
