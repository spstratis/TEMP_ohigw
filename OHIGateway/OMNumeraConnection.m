//
//  OMNumeraConnection.m
//  Bi-LINK Gateway
//
//  Created by S.Stratis on 9/7/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import "OMNumeraConnection.h"
#import "GWUtilities.h"
#import "User_Class.h"
#import "NMReachability.h"

@implementation OMNumeraConnection

static NSString *domain = @"OHI";
static NSString *gatewayType = @"Numera.Gateway.PC";
static NSString *userToken = nil;
static NSString *userTokenURL = nil;
static NSString *baseURL = @"https://apps1.numerasocial.com/gatewayrestservices201/api/";


#pragma mark - Class Methods

+ (void)storeUserLogin {
    [[NSUserDefaults standardUserDefaults] setObject:userToken forKey:@"UserToken"];
    [[NSUserDefaults standardUserDefaults] setObject:userTokenURL forKey:@"UserTokenURL"];
}


+ (APIResponseCode)createUserWithEmail:(NSString *)email
                                  Password:(NSString *)password
                                 firstName:(NSString *)firstName
                                  lastName:(NSString *)lastName
                                  userName:(NSString *)userName
                                   country:(NSString *)country
                                   culture:(NSString *)culture
                                  timezone:(NSString *)timezone; {

    /** Check network availability before all else **/
    if ([self isNetworkAvailable] == FALSE) {
        DDLogError(@"[OMNumeraConnection registerUser] - Network is unavailable");
        return ConnectionError;
    }
    
    NSString *endPoint = [NSString stringWithFormat:@"%@nisperson", baseURL];
    
    /** Build out the payload dictionary for the request url **/
    NSMutableDictionary *payloadDictionary = [NSMutableDictionary new];
    [payloadDictionary setObject:email forKey:@"Email"];
    [payloadDictionary setObject:domain forKey:@"Domain"];
    [payloadDictionary setObject:password forKey:@"Password"];
    [payloadDictionary setObject:firstName forKey:@"FirstName"];
    [payloadDictionary setObject:lastName forKey:@"LastName"];
    [payloadDictionary setObject:userName forKey:@"UserName"];
    [payloadDictionary setObject:gatewayType forKey:@"GatewayType"];
    [payloadDictionary setObject:country forKey:@"Country"];
    [payloadDictionary setObject:culture forKey:@"Culture"];
    [payloadDictionary setObject:timezone forKey:@"Timezone"];
        
    /** Check payload is valid else return error **/
    if ([NSJSONSerialization isValidJSONObject:payloadDictionary]) {
        
        /** start the encoding process **/
        NSMutableString *parameterString = [NSMutableString new];
        BOOL first = YES;
        for (NSString *key in payloadDictionary) {
            if (!first) {
                [parameterString appendString:@"&"];
            }
            first = NO;
            
            [parameterString appendString:[self urlEncode:key]];
            [parameterString appendString:@"="];
            [parameterString appendString:[self urlEncode:[payloadDictionary valueForKey:key]]];
        }
        
        /** Set up the request **/
        NSURL *url = [NSURL URLWithString:endPoint];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSHTTPURLResponse *response;
        NSError *error;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&error];
        
        /** If no connection errors parse the response **/
        if (!error) {
            if (response.statusCode != 200) {
                return ConnectionError;
            }
            id foundationObject = [NSJSONSerialization JSONObjectWithData:responseData
                                                                  options:0
                                                                    error:&error];
            
            if ([foundationObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *responseDictionary = foundationObject;
                DDLogVerbose(@"[OMNumeraConnection createUserWithEmail] - responseDictionary: %@", responseDictionary);
                NSInteger status = [[responseDictionary objectForKey:@"status"] intValue];
                NSDictionary *resultObject = [responseDictionary objectForKey:@"Result"];
                NSInteger resultStatus = [[resultObject objectForKey:@"status"] intValue];
                
                /** Immediately return error if registration was not succesful **/
                if (status != Success) {
                    NSLog(@"[OMNumeraConnection createUserWithEmail] - register user was unsuccessful, status = %ld", (long)status);
                    return (int)status;
                }
                
                /** Check Results Status **/
                if (resultStatus != Success) {
                    return (int)resultStatus;
                } else {
                    /** Store the returned user info **/
                    NSDictionary *result = [responseDictionary objectForKey:@"result"];
                    //NSDictionary *profile = [result objectForKey:@"Profile"];
                    [[User_Class sharedUser]  setFirstName:[result objectForKey:@"FirstName"]];
                    [[User_Class sharedUser]  setLastName:[result objectForKey:@"LastName"]];
                    [[User_Class sharedUser]  setEmail:[result objectForKey:@"Email"]];
                    [[User_Class sharedUser]  setAccountId:[result objectForKey:@"AccountId"]];
                    [[User_Class sharedUser]  setAccountNumber:[result objectForKey:@"AccountNumber"]];
                    [[User_Class sharedUser]  setToken:[result objectForKey:@"UserToken"]];
                    
                    userToken = [result objectForKey:@"UserToken"];
                    userTokenURL = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                         NULL,
                                                                                                         (CFStringRef)[[User_Class sharedUser] valueForKey:@"Token"],
                                                                                                         NULL,
                                                                                                         (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                         kCFStringEncodingUTF8 ));
                    [self storeUserLogin];
                    
                    return Success;
                }
            }
        } else {
            DDLogError(@"[OMNumeraConnection createUserWithEmail] - sendSynchronusRequest Error");
            return ConnectionError;
        }
    }
    DDLogError(@"[OMNumeraConnection createUserWithEmail] - Unexpected API Error, JSON Response object was invalid.");
    return API_UnexpectedError;
}


+ (NSInteger)authenticateUser:(NSString *)userName withPassword:(NSString *)password {
    
    /** Check network availability before all else **/
    if ([self isNetworkAvailable] == FALSE) {
        DDLogError(@"[OMNumeraConnection registerUser] - Network is unavailable");
        return ConnectionError;
    }
    
    NSString *endPoint = [NSString stringWithFormat:@"%@nisperson", baseURL];
    NSError * error;
    NSHTTPURLResponse *response;
    NSInteger status = 1;
    
    /** Build out payload dictionary **/
    NSMutableDictionary *payloadDictionary = [NSMutableDictionary new];
    [payloadDictionary setObject:domain forKey:@"Domain"];
    [payloadDictionary setObject:password forKey:@"Password"];
    [payloadDictionary setObject:userName forKey:@"UserName"];
    [payloadDictionary setObject:gatewayType forKey:@"GatewayType"];
    
    /** Start encoding process **/
    NSMutableString *urlStringWithParams = [NSMutableString stringWithString:endPoint];
    if (payloadDictionary != nil && payloadDictionary.count > 0) {
        BOOL first = YES;
        for (NSString *key in payloadDictionary) {
            [urlStringWithParams appendString:(first ? @"?" : @"&")];
            [urlStringWithParams appendString:[self urlEncode:key]];
            [urlStringWithParams appendString:@"="];
            [urlStringWithParams appendString:[self urlEncode:[payloadDictionary valueForKey:key]]];
            first = NO;
        }
    }
    
    /** Send the request **/
    NSURL *url = [NSURL URLWithString:urlStringWithParams];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPMethod:@"GET"];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    DDLogVerbose(@"[OMNumeraConnection authenticateUser] - Response data: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
    
    /** Parse the response **/
    if (response.statusCode != 200) {
        DDLogError(@"[OMNumeraConnection authenticateUser] - Connection error occured when registering device, status code:%ld",(long)response.statusCode);
        NSAlert *anAlert = [NSAlert alertWithError:error];
        [anAlert runModal];
        return -1;
    } else {
        id foundationObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
        if ([foundationObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *responseDictionary = foundationObject;
            DDLogVerbose(@"[OMNumeraConnection authenticateUser] - responseDictionary from server: %@", responseDictionary);
            
            status = [[responseDictionary valueForKey:@"status"] intValue];
            if (status != Success) {
                DDLogError(@"[OMNumeraConnection authenticateUser:] - Login failed, status code = %d", (int)status);
                return -1;
            } else {
                /** Store the returned user info **/
                NSDictionary *result = [responseDictionary objectForKey:@"result"];
                //NSDictionary *profile = [result objectForKey:@"Profile"];
                [[User_Class sharedUser]  setFirstName:[result objectForKey:@"FirstName"]];
                [[User_Class sharedUser]  setLastName:[result objectForKey:@"LastName"]];
                [[User_Class sharedUser]  setEmail:[result objectForKey:@"Email"]];
                [[User_Class sharedUser]  setAccountId:[result objectForKey:@"AccountId"]];
                [[User_Class sharedUser]  setAccountNumber:[result objectForKey:@"AccountNumber"]];
                [[User_Class sharedUser]  setToken:[result objectForKey:@"UserToken"]];
                
                userToken = [result objectForKey:@"UserToken"];
                userTokenURL = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                     NULL,
                                                                                                     (CFStringRef)[[User_Class sharedUser] valueForKey:@"Token"],
                                                                                                     NULL,
                                                                                                     (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                     kCFStringEncodingUTF8 ));
                [self storeUserLogin];
                DDLogVerbose(@"CURRENT USER: %@ \n",[[User_Class sharedUser] valueForKey:@"Email"]);
            }
            
        }
    }
    return status;
}


+ (APIResponseCode)registerDevice:(NSString *)deviceID asUser:(int)userRegistration {
    
    /** Check network availability before all else **/
    if ([self isNetworkAvailable] == FALSE) {
        DDLogError(@"[OMNumeraConnection registerUser] - Network is unavailable");
        return ConnectionError;
    }
    
    NSString *endPoint = [NSString stringWithFormat: @"%@deviceregistration", baseURL];
    
    NSMutableDictionary *payloadDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    NSString *deviceIDString = nil;
    
    userToken = [[User_Class sharedUser] valueForKey:@"Token"];
    [payloadDict setObject:userToken forKey:@"UserToken"];
    
    if(userRegistration == -1) {
        [payloadDict setObject:@"1" forKey:@"Action"];
    } else {
        [payloadDict setObject:@"0" forKey:@"Action"];
    }
    
    [payloadDict setObject:[NSString stringWithFormat:@"%d", (userRegistration -1)] forKey:@"DeviceActiveUser"];
    
    deviceIDString = deviceID;
    [payloadDict setObject:deviceIDString forKey:@"DeviceId"];
    
    if( [NSJSONSerialization isValidJSONObject:payloadDict]) {
        NSError *error;
        NSHTTPURLResponse *response;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payloadDict options:NSJSONWritingPrettyPrinted error:&error];
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endPoint]];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setHTTPBody:jsonData];
        NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        DDLogDebug(@"[OMNumeraConnection registerDevice] - Response: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        
        if(response.statusCode != 200) {
            DDLogError(@"[OMNumeraConnection registerDevice] - Error occured when registering device - response status code: %d", ConnectionError);
            return ConnectionError;
        } else {
            id foundationObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
            if([foundationObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *responseDict = foundationObject;
                int status = [[responseDict objectForKey:@"status"] intValue];
                
                /* Immediately return an error code if registration was not successful */
                if(status != 0) {
                    DDLogError(@"[OMNumeraConnection registerDevice] - InvalidData error occured when registering device - code: %d", status);
                    return API_UnexpectedError;
                } else {
                    return Success;
                }
            }
        }
    }
    DDLogError(@"[OMNumeraConnection registerDevice] - Unexpected API Error, Invalid JSON Object");
    return API_UnexpectedError;
}


+ (int)getDeviceRegistrationFor:(NSString *)deviceID {
    NSString *endPoint = [NSString stringWithFormat: @"%@deviceregistration", baseURL];
    
    NSError * error;
    NSHTTPURLResponse *response;
    NSString *deviceIDString = deviceID;
    NSString *userTokenURL = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                         NULL,
                                                                                         (CFStringRef)[[User_Class sharedUser] valueForKey:@"Token"],
                                                                                         NULL,
                                                                                         (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                         kCFStringEncodingUTF8 ));
    
    NSString *deviceRegistrationURL = [NSString stringWithFormat:@"%@?UserToken=%@&DeviceId=%@", endPoint, userTokenURL, deviceIDString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:deviceRegistrationURL]];
    [urlRequest setHTTPMethod:@"GET"];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    DDLogVerbose(@"[OMNumeraConnection getDeviceRegistrationFor] - Response: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
    
    if(response.statusCode != 200) {
        DDLogError(@"[OMNumeraConnection getDeviceRegistrationFor] - Connection error occured when registering device - status code : %ld" , (long)response.statusCode);
        return -2;
    } else {
        id foundationObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
        if([foundationObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *responseDict = foundationObject;
            
            int status = [[responseDict objectForKey:@"status"] intValue];
            if(status == 0) {
                NSDictionary *resultDict = [responseDict objectForKey:@"result"];
                [[User_Class sharedUser] setUserSetting:[[resultDict objectForKey:@"DeviceActiveUser"] intValue] + 1];
                if([[resultDict objectForKey:@"DeviceActiveUser"] intValue] == -1) {
                    return -1;
                } else {
                    return ([[resultDict objectForKey:@"DeviceActiveUser"] intValue] + 1);
                }
            } else {
                DDLogError(@"[OMNumeraConnection getDeviceRegistrationFor] - Error getting deivce registration");
                return -2;
            }
        }
    }
    DDLogError(@"[OMNumeraConnection getDeviceRegistrationFor] - Unexpected API Error, no response.");
    return -2;
}


#pragma mark - Helpers Methods

+ (NSString *)urlEncode:(NSString *)input {
    const char *input_c = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSMutableString *result = [NSMutableString new];
    for (NSInteger i = 0, length = strlen(input_c); i < length; i++) {
        unsigned char c = input_c[i];
        if (
            (c >= '0' && c <= '9')
            || (c >= 'A' && c <= 'Z')
            || (c >= 'a' && c <= 'z')
            || (c == '-' || c == '.' || c == '_' || c == '~'))
        {
            [result appendFormat:@"%c", c];
        } else {
            [result appendFormat:@"%%%02X", c];
        }
    }
    return result;
}

+ (BOOL)isNetworkAvailable {
    NMReachability *reachability = [NMReachability reachabilityWithHostName:@"staging.numerasocial.com"];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if(internetStatus == NotReachable){
        DDLogError(@"OMNumeraConnection - Network is currently not available");
        return FALSE;
    } else {
        return TRUE;
    }
}

@end
