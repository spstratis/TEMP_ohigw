//
//  User_Class.h
//  Omron
//
//  Created by Justin Helmick on 11/1/13.
//  Copyright (c) 2013 Justin Helmick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User_Class : NSObject

@property (nonatomic, readwrite) NSString *FirstName;
@property (nonatomic, readwrite) NSString *LastName;
@property (nonatomic, readwrite) NSString *AccountId;
@property (nonatomic, readwrite) NSString *AccountNumber;
@property (nonatomic, readwrite) NSString *Email;
@property (nonatomic, readwrite) NSString *Token;
@property (nonatomic, readwrite) NSString *UserName;
@property (nonatomic, readwrite) NSInteger UserSetting;
@property (nonatomic, readwrite) NSString *RememberMe;
@property (nonatomic, readwrite) NSString *Country;
@property (nonatomic, readwrite) NSString *Culture;
@property (nonatomic, readwrite) NSString *Timezone;

+ (id)sharedUser;

@end

