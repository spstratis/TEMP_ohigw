//
//  uploadPage.h
//  Omron2
//
//  Created by Justin Helmick on 1/24/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface uploadPage : NSView


@property (weak) IBOutlet NSButton *startUpload;
@property (weak) IBOutlet NSProgressIndicator *loader;
@property (weak) IBOutlet NSTextField *uploadMessage;
@property (weak) IBOutlet NSTextField *deviceSerialNumber;
@property (weak) IBOutlet NSButton *viewDataButton;
@property (weak) IBOutlet NSView *controlSection;
@property (weak) IBOutlet NSTextField *sectionHeaderLabel;
@property (weak) IBOutlet NSTextField *startUploadLabel;
@property (weak) IBOutlet NSButton *uploadMore;
@property (weak) IBOutlet NSButton *reviewUpload;
@property (weak) IBOutlet NSButton *retryUpload;


- (IBAction)uploadEvent:(id)sender;
- (IBAction)viewData:(id)sender;

typedef enum{
    ServiceException = -1,
    UploadSuccess = 0,
    NoNewItems = 1,
    SomeNewItems = 2,
    CorruptData = 3,
    IncorrectDevice = 4,
    InvalidToken = 5,
    ExpiredToken = 6,
    FutureDated = 7,
    SomeFutureDated = 8
} uploadErrors;
@end
