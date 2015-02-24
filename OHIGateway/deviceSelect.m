//
//  deviceSelect.m
//  Omron2
//
//  Created by Justin Helmick on 12/11/13.
//  Copyright (c) 2013 Justin Helmick. All rights reserved.
//

#import "deviceSelect.h"
#import "window.h"

@implementation deviceSelect

NSTrackingArea *trackingArea1, *trackingArea2, *trackingArea3;

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
    [_chooseLabel setStringValue:NSLocalizedString(@"DeviceSelect_ChooseLabel", @"Choose a device to upload data from")];
}

@end
