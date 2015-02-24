//
//  uploadData.h
//  Omron2
//
//  Created by Justin Helmick on 2/21/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uploadReturn.h"

@interface uploadData : NSObject

- (uploadReturn*)upload:(NSString *)base64String deviceID:(NSString*)deviceID;

@end
