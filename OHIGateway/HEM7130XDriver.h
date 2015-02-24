//
//  HEM7130XDriver.h
//  Bi-LINK Gateway
//
//  Created by S.Stratis on 8/21/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWDriver.h"

@interface HEM7130XDriver : NSObject <GWDriver>

/**
 * @property deviceData
 *
 * Stores and allows access to the data pulled from the device
 */
@property (nonatomic, readwrite) NSString *deviceData;

/**
 * getData Method conforms to GWDriver interface
 *
 * Pulls data from device and stores it in the deviceData property
 */

-(enum Status)getData:(char *)encodedBuffer user:(int)user;

/**
 * closeDevice Method conforms to GWDriver interface
 *
 * Sends command to close the connection to the device.
 */
-(enum Status) closeDevice: (BOOL)success user: (int)user;
@end
