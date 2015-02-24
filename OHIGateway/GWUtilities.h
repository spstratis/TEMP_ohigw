//
//  GWUtilities.h
//  Omron2
//
//  Created by S.Stratis on 3/13/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GWUtilities : NSObject

// Converts data to base 64
+(NSString*)base64forData:(NSData*)theData;

// reads custom plist files
+(id)readPlist:(NSString *)fileName;

// Reads and returns custom plist as a array
+(NSArray *)getPlistArray:(NSString *)filename;

// Reads and returns custom plist as a dictionary
+(NSDictionary *)getPlistDictionary:(NSString *)filename;

@end
