//
//  loginError.m
//  Omron2
//
//  Created by Justin Helmick on 11/15/13.
//  Copyright (c) 2013 Justin Helmick. All rights reserved.
//

#import "loginError.h"

@implementation loginError

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    [self setHidden:YES];
    if (self) {
        [self.layer setCornerRadius:5.0];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSColor *error_red = colorFromRGB(253, 28, 1);
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:5.0 yRadius:5.0];
    [path addClip];
    
    [error_red set];
    NSRectFill(dirtyRect);
    
    [super drawRect:dirtyRect];
}

static NSColor *colorFromRGB(unsigned char r, unsigned char g, unsigned char b)
{
    return [NSColor colorWithCalibratedRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1.0];
}

@end
