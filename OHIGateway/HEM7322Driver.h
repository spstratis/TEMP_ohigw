//
//  HEM7322Driver.h
//  Bi-LINK Gateway
//
//  Created by S.Stratis on 9/3/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWDriver.h"

@interface HEM7322Driver : NSObject <GWDriver>

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


/**
 * closeDevice Method conforms to GWDriver interface
 *
 * Sends command to close the connection to the device.
 */


@end
