//
//  HJ720ITDriver.h
//  Omron Bi-LINK Gateway
//
//  Created by S.Stratis on 12/18/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWDriver.h"

@interface HJ720ITDriver : NSObject<GWDriver>

@property (nonatomic, readwrite) NSString *deviceData;

@end
