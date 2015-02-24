//
//  NSMenuItem+extended.m
//  Bi-LINK Gateway
//
//  Created by justin helmick on 7/7/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import "NSMenuItem+extended.h"

@implementation NSMenuItem (extended)

@dynamic attribute;

-(NSString *)attributeValue
{
    return self.attribute;
}

-(void)setAttribute:(NSString *)attributeString
{
    self.attribute = attributeString;
}
@end
