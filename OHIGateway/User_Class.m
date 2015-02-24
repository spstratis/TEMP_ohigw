//
//  User_Class.m
//  Omron
//
//  Created by Justin Helmick on 11/1/13.
//  Copyright (c) 2013 Justin Helmick. All rights reserved.
//

#import "User_Class.h"

@implementation User_Class

@synthesize FirstName, LastName, AccountId, AccountNumber, Email, Token, UserName, UserSetting, RememberMe, Country, Culture, Timezone;

+ (id)sharedUser {
    static User_Class *sharedUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUser = [[self alloc] init];
    });
    return sharedUser;
}

@end
