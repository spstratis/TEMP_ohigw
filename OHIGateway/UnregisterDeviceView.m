//
//  UnregisterDeviceView.m
//  Bi-LINK Gateway
//
//  Created by S.Stratis on 9/9/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import "UnregisterDeviceView.h"
#import "OMNumeraConnection.h"

@implementation UnregisterDeviceView

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
    // Drawing code here.
}

- (IBAction)deviceOneButton:(id)sender {
    [OMNumeraConnection registerDevice:@"40005" asUser:-1];
    
}

- (IBAction)deviceTwoButton:(id)sender {
    [OMNumeraConnection registerDevice:@"40017" asUser:-1];
}

- (IBAction)device3Button:(id)sender {
    [OMNumeraConnection registerDevice:@"40016" asUser:-1];
}
@end
