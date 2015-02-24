//
//  GWDriver.h
//  Omron2
//
//  Created by S.Stratis on 3/12/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum Status : NSInteger {
    Success,
    Cancelled,
    DeviceNotFound,
    DeviceError,
    UnkownModel,
    TimedOut
} Status;

@protocol GWDriver <NSObject>

-(enum Status) getData: (char*)encodedBuffer user: (int)user;

-(enum Status) closeDevice: (BOOL)success user: (int)user;

@end