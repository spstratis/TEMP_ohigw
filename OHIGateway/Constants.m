//
//  Constants.m
//  Bi-LINK Gateway
//
//  Created by S.Stratis on 10/17/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import "Constants.h"
#import "DDLog.h"

@implementation Constants


#ifdef DEBUG
    int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
    int ddLogLevel = LOG_LEVEL_ERROR;
#endif

@end
