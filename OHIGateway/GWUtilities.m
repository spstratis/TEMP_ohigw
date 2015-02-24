//
//  GWUtilities.m
//  Omron2
//
//  Created by S.Stratis (SS) on 3/13/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

/**
 *   Utilities class for us to use for any global
 *   utility methods we may want to use between the application
 *   and the drivers. (SS)
 */

#include <openssl/bio.h>
#include <openssl/evp.h>
#import "GWUtilities.h"

@implementation GWUtilities

// Utility method to convert a NSData object to a base64
// encoded string.

+(NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

+(id)readPlist:(NSString *)fileName
{
    NSData *plistData;
    NSString *error;
    NSPropertyListFormat format;
    id plist;
    
    NSString *localizedPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    plistData = [NSData dataWithContentsOfFile:localizedPath];
                               
    plist = [NSPropertyListSerialization propertyListFromData:plistData
                                             mutabilityOption:NSPropertyListImmutable
                                                       format:&format
                                             errorDescription:&error];
    if(!plist)
    {
        NSLog(@"Error reading plist from file '%s', error = '%s'", [localizedPath UTF8String], [error UTF8String]);
    }
                               
    return plist;
    
}

// Utility method to get custom plist
// as an array

+(NSArray *)getPlistArray:(NSString *)filename
{
    return (NSArray *)[self readPlist:filename];
}

// Utility method to get custom plist
// as a dictionary

+(NSDictionary *)getPlistDictionary:(NSString *)filename
{
    return (NSDictionary *)[self readPlist:filename];
}

@end
