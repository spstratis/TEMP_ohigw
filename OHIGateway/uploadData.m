//
//  uploadData.m
//  Omron2
//
//  Created by Justin Helmick on 2/21/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import "uploadData.h"
#import "User_Class.h"
#import "uploadReturn.h"

@implementation uploadData

// TODO: Refactor and add to the OMNumeraConnection class.

-(uploadReturn*) upload:(NSString *)base64String deviceID:(NSString *)deviceID
{
    //NSString *usertoken;
    uploadReturn *returnInfo = [[uploadReturn alloc]init];
    int statusnum = 1;
    int numItems = 0;
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"OHI" forKey:@"Domain"];
    [parameters setObject:@"Numera.Gateway.PC" forKey:@"GatewayType"];
    [parameters setObject:[[User_Class sharedUser] valueForKey:@"Token"] forKey:@"UserToken"];
    [parameters setObject:deviceID forKey:@"DeviceTypeId"];
    [parameters setObject:base64String forKey:@"DeviceDataBase64"];
    NSMutableArray * encodedParameters = [NSMutableArray array];
    
    for (NSString * key in parameters)
    {
        NSString * value = [parameters objectForKey:key];
        NSString * encoded = [NSString stringWithFormat:@"%@=%@", [key stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], [value stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        NSString *encodedtoken = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                       NULL,
                                                                                                       (CFStringRef)encoded,
                                                                                                       NULL,
                                                                                                       (CFStringRef)@"!*'();:@&+$,/?%#[]",
                                                                                                       kCFStringEncodingUTF8 ));
        [encodedParameters addObject:encodedtoken];
    }
    
    NSString * post = [encodedParameters componentsJoinedByString:@"&"];
    //NSLog(@"%@", post);
    NSData * postData = [post dataUsingEncoding:NSASCIIStringEncoding];
    
    NSArray *plistinfo = [GWUtilities getPlistArray:@"app_config"];
    NSString *serviceURL = [plistinfo valueAtIndex:0 inPropertyWithKey:@"ServicesURL"];
    
    NSString *tokenizedURLString = [NSString stringWithFormat:@"%@/measurements", serviceURL];
    NSURL * url = [NSURL URLWithString:tokenizedURLString];
    
    NSMutableURLRequest * r = [[NSMutableURLRequest alloc] initWithURL:url];
    [r setHTTPMethod:@"POST"];
    [r setHTTPBody:postData];
    [r setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSHTTPURLResponse * response = nil;
    NSError * error = nil;
    NSData * responseData = [NSURLConnection sendSynchronousRequest:r returningResponse:&response error:&error];
    NSString * responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    //NSLog(@"Response: %@", responseString);
    if(NSClassFromString(@"NSJSONSerialization"))
    {
        NSError *error = nil;
        id status = [NSJSONSerialization
                     JSONObjectWithData:responseData
                     options:0
                     error:&error];
        if(error){
            NSAlert *anAlert = [NSAlert alertWithError:error];
            [anAlert runModal];
        }
        if([status isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dicStatus = status;
            NSDictionary *result = [dicStatus objectForKey:@"result"];
            NSLog(@"%@", result);
            statusnum = [[result objectForKey:@"Status"] intValue];
            numItems = [[result objectForKey:@"ItemCount"] intValue] ;
            returnInfo.numItems = numItems;
            returnInfo.status = statusnum;
            NSLog(@"Items uploaded: %d, status: %d", numItems, statusnum);
        }
        else{
            
        }
    }
    else{
        
    }
    return returnInfo;
}

@end
