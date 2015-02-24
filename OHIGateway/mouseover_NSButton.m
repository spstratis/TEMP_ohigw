//
//  mouseover_NSButton.m
//  Omron2
//
//  Created by Justin Helmick on 4/17/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import "mouseover_NSButton.h"

@implementation mouseover_NSButton

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
    [super drawRect:dirtyRect];
    NSTrackingArea* trackingArea = [[NSTrackingArea alloc]
                                    initWithRect:[self bounds]
                                    options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                    owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
    // Drawing code here.
}

- (void)mouseEntered:(NSEvent *)theEvent{
    [[self cell] setHighlighted:YES];
}

- (void)mouseExited:(NSEvent *)theEvent{
    [[self cell] setHighlighted:NO];
}

@end
