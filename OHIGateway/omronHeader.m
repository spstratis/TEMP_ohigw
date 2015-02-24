//
//  loginHeader.m
//  Omron
//
//  Created by Justin Helmick on 4/9/13.
//  Copyright (c) 2013 Justin Helmick. All rights reserved.
//

#import "omronHeader.h"

@implementation omronHeader

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
    [omronBlue set];
    NSRectFill([self bounds]);
}

@end
