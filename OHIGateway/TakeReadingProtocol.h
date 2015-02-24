//
//  TakeReadingProtocol.h
//  Omron2
//
//  Created by S.Stratis on 4/10/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <utilities/GWUtilities.h>

typedef enum TakeReadingResponse: NSInteger {
    Success = 0,
    NetworkException = 1,
    ServiceException = 2,
    UnableToLoadDeviceDriver = 3,
    DeviceNotFoundInConfig = 4,
    DeviceAssemblyNotFound = 5,
    DeviceClassNotLoaded = 6,
    UserCancelled = 7,
    DeviceError = 8,
    DeviceNotFound = 9,
    UnsupportedFirmware = 10,
    NoRecordsFound = 11,
    InvalidUploadToken = 12,
    DataUploadFailed = 13,
    SuccessNoNewItems = 14,
    SuccessSomeInvalidItems = 15,
    IncorrectDeviceType = 16,
    CorruptData = 17,
    InvalidAllItemsFutureDated = 18,
    SuccessSomeInvalidItemsFutureDated = 19,
    UnexpectedError = 100
} TakeReadingResponse;

@protocol TakeReading <NSObject>

-(enum TakeReadingResponse) UploadData: (NSString)base64String;

@end

