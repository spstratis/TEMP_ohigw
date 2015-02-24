//
//  HJ322UDriver.h
//  Omron Bi-LINK Gateway
//
//  Created by S.Stratis on 12/17/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWDriver.h"

@interface HJ322UDriver : NSObject<GWDriver>

@property (nonatomic, readwrite) NSString *deviceData;

@end
