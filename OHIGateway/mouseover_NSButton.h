//
//  mouseover_NSButton.h
//  Omron2
//
//  Created by Justin Helmick on 4/17/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface mouseover_NSButton : NSButton

- (void)mouseEntered:(NSEvent *)theEvent;
- (void)mouseExited:(NSEvent *)theEvent;
//- (void)addTrackingArea;

@end
