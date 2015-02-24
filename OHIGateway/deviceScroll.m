//
//  deviceScroll.m
//  Omron2
//
//  Created by Justin Helmick on 1/14/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import "deviceScroll.h"

@implementation deviceScroll

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
}

@end
