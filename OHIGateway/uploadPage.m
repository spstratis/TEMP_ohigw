//
//  uploadPage.m
//  Omron2
//
//  Created by Justin Helmick on 1/24/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import "uploadPage.h"
#import "uploadData.h"
#import "HJ322UDriver.h"
#import "HJ720ITDriver.h"
#import "uploadReturn.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"
#import "User_Class.h"
#import "NMReachability.h"


@implementation uploadPage

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
    NSColor *omronBlue = [NSColor colorWithCalibratedRed:(10/255.0f) green:(114/255.0f) blue:(188/255.0f) alpha:1.0];
    [_controlSection setWantsLayer:YES];
    _controlSection.layer.backgroundColor = omronBlue.CGColor;
    
    _uploadMessage.textColor = [NSColor whiteColor];
    [_uploadMessage setStringValue:NSLocalizedString(@"Please be sure your device is connected and in the proper mode. To initiate the reading, click the Start Upload button above.", @"initial upload message prior to uploading.")];
    
    _sectionHeaderLabel.stringValue = NSLocalizedString(@"Upload Data", @"Section header label");
    _sectionHeaderLabel.textColor = [NSColor grayColor];
    
    _startUploadLabel.stringValue = NSLocalizedString(@"Start Upload", @"label");
    _startUploadLabel.textColor = [NSColor whiteColor];
    
    [[_startUpload cell] setBackgroundColor:[NSColor whiteColor]];
}


- (IBAction)uploadEvent:(id)sender
{
    
    NSInteger defaultUser = 1;
    NSLog(@"default user : %ld", (long)defaultUser);
    uploadReturn *returnData = [[uploadReturn alloc]init];
    uploadData *uploader = [[uploadData alloc]init];
    char *encodedBuffer = NULL;
    NSInteger itemcount = 0;
    [_uploadMessage setStringValue:NSLocalizedString(@"Default_UploadMessage", @"Please be sure your device is connected and in the proper mode. To initiate the reading, click the Start Upload button above.")];
    long status = -2;

    [_startUpload setHidden:YES];
    [_loader startAnimation:self];
    [_retryUpload setHidden:YES];
    [_uploadMore setHidden:YES];
    [_reviewUpload setHidden:YES];
    
    NSInteger getDataFromDevice;
    NSString *deviceSerialNumber = [_deviceSerialNumber stringValue];
    NSString *deviceID;
    NSString *deviceData;
    
    /** Check network availability before all else **/
    if ([self isNetworkAvailable] == FALSE) {
        DDLogError(@"[OMNumeraConnection registerUser] - Network is unavailable");
        [_uploadMessage setStringValue:NSLocalizedString(@"You're not currently connected to the internet, please connect with a network and try agian.", @"Please be sure your device is connected and in the proper mode. To initiate the reading, click the Start Upload button above.")];
        [_startUpload setHidden:YES];
        [_loader startAnimation:self];
        [_retryUpload setHidden:NO];
        [_uploadMore setHidden:YES];
        [_reviewUpload setHidden:YES];
        return;
    }
    
    if ([deviceSerialNumber  isEqual: @"HJ-323U / HJ-322U"]) {
        HJ322UDriver *driver = [[HJ322UDriver alloc] init];
        getDataFromDevice = [driver getData:encodedBuffer user:(int)defaultUser];
        deviceData = driver.deviceData;
        deviceID = @"40002";
    } else if ([deviceSerialNumber  isEqual: @"HJ-324U"]) {
        HJ322UDriver *driver = [[HJ322UDriver alloc] init];
        getDataFromDevice = [driver getData:encodedBuffer user:(int)defaultUser];
        deviceData = driver.deviceData;
        deviceID = @"40002";
    } else if ([deviceSerialNumber  isEqual: @"HJ-720IT"]) {
        HJ720ITDriver *driver = [[HJ720ITDriver alloc] init];
        getDataFromDevice = [driver getData:encodedBuffer user:(int)defaultUser];
        deviceData = driver.deviceData;
        deviceID = @"40003";
    }
    switch (getDataFromDevice)
    {
        case Success: {
            if ([deviceSerialNumber  isEqual: @"HJ-323U / HJ-322U"]) {
                returnData = [uploader upload:deviceData deviceID:deviceID];
            } else if ([deviceSerialNumber  isEqual: @"HJ-324U"]) {
                returnData = [uploader upload:deviceData deviceID:deviceID];
            } else if ([deviceSerialNumber  isEqual: @"HJ-720IT"]) {
                returnData = [uploader upload:deviceData deviceID:deviceID];
            }
            status = returnData.status;
            itemcount = returnData.numItems;
            [_loader stopAnimation:self];
            break; }
        case Cancelled: {
            [_uploadMessage setStringValue:NSLocalizedString(@"TakeReading_StatusMessage_UserCancelled", @"The device reading was cancelled by the user. Please retry when you are ready to upload your reading.")];
            [_loader stopAnimation:self];
            [_retryUpload setHidden:NO];
            [_uploadMore setHidden:YES];
            [_reviewUpload setHidden:YES];
            break; }
        case DeviceNotFound: {
            [_uploadMessage setStringValue:NSLocalizedString(@"TakeReading_StatusMessage_DeviceNotFound", @"The device could not be found. Please be sure that it is connected properly with any necessary cables secured and attempt the reading again.")];
            [_loader stopAnimation:self];
            [_retryUpload setHidden:NO];
            [_uploadMore setHidden:YES];
            [_reviewUpload setHidden:YES];
            break; }
        case DeviceError: {
            [_uploadMessage setStringValue:NSLocalizedString(@"TakeReading_StatusMessage_DeviceError", @"An error occurred while communicating with your device. Please remove the device, reconnect, ensure that any required cable is connected tightly and atempt the reading again.")];
            [_loader stopAnimation:self];
            [_retryUpload setHidden:NO];
            [_uploadMore setHidden:YES];
            [_reviewUpload setHidden:YES];
            break; }
        case UnkownModel: {
            [_uploadMessage setStringValue:NSLocalizedString(@"TakeReading_StatusMessage_UnableToLoadDeviceDriver", @"An unexpected error occurred while loading your device's driver. If this issue continues, please submit a support ticket.")];
            [_loader stopAnimation:self];
            [_retryUpload setHidden:NO];
            [_uploadMore setHidden:YES];
            [_reviewUpload setHidden:YES];
            break; }
        case TimedOut: {
            [_uploadMessage setStringValue:NSLocalizedString(@"TakeReading_StatusMessage_UnexpectedError", @"An unexpected error occurred while communicating with your device. Please remove the device, recconect, ensure that any required cable is connected tightly and attempt the reading again.")];
            [_loader stopAnimation:self];
            [_retryUpload setHidden:NO];
            [_uploadMore setHidden:YES];
            [_reviewUpload setHidden:YES];
            break; }
            
    }
    if(status != -2)
    {
        switch (status)
        {
            case ServiceException:{
                [_uploadMessage setStringValue:NSLocalizedString(@"TakeReading_StatusMessage_ServiceException", @"The Upload Service is not currently available. Please try again in a few minutes. If you continue experiencing issues, please submit a support ticket.")];
            [_retryUpload setHidden:NO];
                break;
            }
            case Success:{
                [_uploadMessage setStringValue:[NSString stringWithFormat:NSLocalizedString(@"TakeReading_StatusMessage_Success", @"Your information was successfully uploaded."), itemcount]];
                [_uploadMore setHidden:NO];
                [_reviewUpload setHidden:NO];
                [_retryUpload setHidden:YES];
                break;
            }
            case NoNewItems:{
                [_uploadMessage setStringValue:NSLocalizedString(@"TakeReading_StatusMessage_SuccessNoNewItems", @"Your readings were successfully uploaded. However, there were no new readings to process.")];
                [_uploadMore setHidden:NO];
                [_reviewUpload setHidden:NO];
                [_retryUpload setHidden:YES];
                break;
            }
            case SomeNewItems:{
                [_uploadMessage setStringValue:[NSString stringWithFormat:NSLocalizedString(@"TakeReading_StatusMessage_Success", @"Your information was successfully uploaded."), itemcount]];
                [_uploadMore setHidden:NO];
                [_reviewUpload setHidden:NO];
                [_retryUpload setHidden:YES];
                break;
            }
            case CorruptData:{
                [_uploadMessage setStringValue:[NSString stringWithFormat:NSLocalizedString(@"TakeReading_StatusMessage_Success", @"Your information was successfully uploaded."), itemcount]];
                [_retryUpload setHidden:NO];
                break;
            }
            case IncorrectDevice:{
                [_uploadMessage setStringValue:NSLocalizedString(@"TakeReading_StatusMessage_IncorrectDeviceType", @"An error occurred. An invalid device was identified in the upload token. Please retry your upload at a later time.")];
                [_retryUpload setHidden:NO];
                break;
            }
            case InvalidToken:{
                [_uploadMessage setStringValue:NSLocalizedString(@"TakeReading_StatusMessage_InvalidUploadToken", @"An error occurred. An invalid upload token was processed. Please retry your upload at a later time.")];
                [_retryUpload setHidden:NO];
                break;
            }
            case ExpiredToken:{
                [_uploadMessage setStringValue:NSLocalizedString(@"TakeReading_StatusMessage_InvalidUploadToken", @"An error occurred. An invalid upload token was processed. Please retry your upload at a later time.")];
                [_retryUpload setHidden:NO];
                break;
            }
            case FutureDated:{
                [_uploadMessage setStringValue:NSLocalizedString(@"TakeReading_StatusMessage_InvalidItemsFutureDated", @"Your readings could not be uploaded. All measurements on the device were found to have a date or time in the future. Please check your device settings.")];
                [_retryUpload setHidden:NO];
                break;
            }
            case SomeFutureDated:{
                [_uploadMessage setStringValue:[NSString stringWithFormat:NSLocalizedString(@"TakeReading_StatusMessage_SuccessSomeInvalidItemsFutureDated", @"Your readings were successfully uploaded. However, there were some invalid measurements with dates or times that are in the future. Measurements with dates in the future are rejected - please check your device."), itemcount]];
                [_retryUpload setHidden:NO];
                break;
            }
        }
    }
    
    if (getDataFromDevice == Success) {
        @try {
            if ((status != 0) && (status != 1) && (status != 2) && (status != 8)) {
                if ([deviceSerialNumber  isEqual: @"HJ-323U / HJ-322U"]) {
                    HJ322UDriver *driver = [[HJ322UDriver alloc] init];
                    [driver closeDevice:false user:1];
                } else if ([deviceSerialNumber  isEqual: @"HJ-324U"]) {
                    HJ322UDriver *driver = [[HJ322UDriver alloc] init];
                    [driver closeDevice:false user:1];
                } else if ([deviceSerialNumber  isEqual: @"HJ-720IT"]) {
                    HJ720ITDriver *driver = [[HJ720ITDriver alloc] init];
                    [driver closeDevice:false user:1];
                }
            }
            else{
                if ([deviceSerialNumber  isEqual: @"HJ-323U / HJ-322U"]) {
                    HJ322UDriver *driver = [[HJ322UDriver alloc] init];
                    [driver closeDevice:true user:1];
                } else if ([deviceSerialNumber  isEqual: @"HJ-324U"]) {
                    HJ322UDriver *driver = [[HJ322UDriver alloc] init];
                   [driver closeDevice:true user:1];
                } else if ([deviceSerialNumber  isEqual: @"HJ-720IT"]) {
                    HJ720ITDriver *driver = [[HJ720ITDriver alloc] init];
                    [driver closeDevice:true user:1];
                }
            }
        }
        @catch (NSException *exception) {
            DDLogVerbose(@"Upload issue from upload page, Exception: %@", exception);
        }
    }
}

- (IBAction)viewData:(id)sender {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://omronwellness.com"]];
}

- (BOOL)isNetworkAvailable {
    NMReachability *reachability = [NMReachability reachabilityWithHostName:@"staging.numerasocial.com"];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if(internetStatus == NotReachable){
        DDLogError(@"OMNumeraConnection - Network is currently not available");
        return FALSE;
    } else {
        return TRUE;
    }
}
@end
