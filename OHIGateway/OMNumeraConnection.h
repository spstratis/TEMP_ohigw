//
//  OMNumeraConnection.h
//  Bi-LINK Gateway
//
//  Created by S.Stratis on 9/7/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OMNumeraConnection : NSObject

@property (retain, nonatomic) NSURLConnection *connection;



#pragma mark - Enums

typedef enum
{
    ConnectionError = -2,           //all
    Success = 0,                    //all
    SuccessfulNoNewItems = 1,       //measurements
    SomeInvalidItems = 2,           //measurements
    CorruptData = 3,                //measurements
    IncorrectDeviceType = 4,        //measurements
    InvalidToken = 5,               //measurements
    ExpiredToken = 6,               //measurements
    InvalidAllItemsFutureDated = 7, //measurements
    InvalidSomeItemsFutureDated = 8,//measurements
    InvalidUser = 10,               //UpdateProfile,//Register
    DuplicateEmail = 11,            //Register
    DuplicateUserName = 12,         //Register
    DuplicateIdentityProvider = 13, //Register
    InvalidEmail = 14,
    InvalidDomain = 15,
    InvalidAppKey = 16,             //Invalid Gateway Type
    InvalidDevice = 20,             //Device Registration
    Invalid_UserToken = 24,
    Invalid_UserPassword = 25,
    API_UnexpectedError = 26,
    User_DoesNotExist = 27,         //Email Recovery
    Domain_DoesNotMatch = 28,
    Invalid_UserName = 29,
    InvalidCreditionals = 30,
    Invalid_RegistrationParameters = 30,
    API_SetUserDeviceError = 31,
    API_UnableToCreateUploadToken = 32
} APIResponseCode;


#pragma mark - Class Methods

/**
 *
 * Helper method used to encode URL parameters
 */
+ (NSString *)urlEncode:(NSString *)input;


/**
 * registerDevice
 *
 * Used to register a device to a user so it can be referenced later on.
 * return eReigsterErrorCodes to be used as a status
 */
+ (APIResponseCode)registerDevice:(NSString *)deviceID asUser:(int)userRegistration;


/**
 * retrieveDeviceRegistration
 *
 * Used to find which deivice the user has registed
 * return -2 = failure, -1 = not registered, 1 = user #1, 2 = user #2
 */
+ (int)getDeviceRegistrationFor:(NSString *)deviceID;


/**
 * createUserWithEmail
 *
 * Creates a user in NIS.
 * Returns eRegisterErrorCodes enum which can be used to display errors to user
 */
+ (APIResponseCode)createUserWithEmail:(NSString *)email
                                  Password:(NSString *)password
                                 firstName:(NSString *)firstName
                                  lastName:(NSString *)lastName
                                  userName:(NSString *)userName
                                   country:(NSString *)country
                                   culture:(NSString *)culture
                                  timezone:(NSString *)timezone;


/**
 * authenticateUser
 *
 * Checks NIS for a user based off the passed in params
 *
 * @param userName: the username to validate against
 * @param password: the password assicuated with this user.
 *
 * Returns a status number from server, 4 being invalid user.
 */
+ (NSInteger)authenticateUser:(NSString *)userName withPassword:(NSString *)password;

@end
