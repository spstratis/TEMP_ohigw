//
//  HEM6310FDriver.h
//  Omron2
//
//  Created by S.Stratis on 3/12/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "GWDriver.h"

@interface HEM6310FDriver : NSObject <GWDriver>

@property (nonatomic, readwrite) NSString *deviceData;

@end