//
//  serializeUser.h
//  Omron2
//
//  Created by Justin Helmick on 3/3/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface serializeUser : NSObject
+(void)createXML;
+(void)fillUserClass;
+(void)clear_serialized;
+(NSString*)checkXML;
@end
