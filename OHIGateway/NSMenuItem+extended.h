//
//  NSMenuItem+extended.h
//  Bi-LINK Gateway
//
//  Created by justin helmick on 7/7/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSMenuItem (extended)

@property (nonatomic, strong) NSString *attribute;
-(NSString *)attributeValue;
-(void)setAttribute:(NSString *)attributeString;

@end
