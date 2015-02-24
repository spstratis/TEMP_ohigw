//
//  serializeUser.m
//  Omron2
//
//  Created by Justin Helmick on 3/3/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import "serializeUser.h"
#import "User_Class.h"

@implementation serializeUser

id plist;
NSString *error;
NSPropertyListFormat format;

+(void)createXML
{
    NSXMLElement *root = (NSXMLElement *)[NSXMLNode elementWithName:@"User"];
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithRootElement:root];
    [xmlDoc setVersion:@"1.0"];
    [xmlDoc setCharacterEncoding:@"UTF-8"];
    NSXMLElement *FirstName = [NSXMLElement elementWithName:@"FirstName"];
    NSXMLElement *LastName = [NSXMLElement elementWithName:@"LastName"];
    NSXMLElement *UserName = [NSXMLElement elementWithName:@"UserName"];
    NSXMLElement *Token = [NSXMLElement elementWithName:@"Token"];
    NSXMLElement *AccountId = [NSXMLElement elementWithName:@"AccountId"];
    NSXMLElement *Email = [NSXMLElement elementWithName:@"Email"];
    NSXMLElement *AccountNumber = [NSXMLElement elementWithName:@"AccountNumber"];
    NSXMLElement *RememberMe = [NSXMLElement elementWithName:@"RememberMe"];
    [FirstName addChild:[NSXMLNode textWithStringValue:[[User_Class sharedUser] valueForKey:@"FirstName"]]];
    [LastName addChild:[NSXMLNode textWithStringValue:[[User_Class sharedUser] valueForKey:@"LastName"]]];
    [UserName addChild:[NSXMLNode textWithStringValue:[[User_Class sharedUser] valueForKey:@"UserName"]]];
    [Token addChild:[NSXMLNode textWithStringValue:[[User_Class sharedUser] valueForKey:@"Token"]]];
    [AccountId addChild:[NSXMLNode textWithStringValue:[[User_Class sharedUser] valueForKey:@"AccountId"]]];
    [Email addChild:[NSXMLNode textWithStringValue:[[User_Class sharedUser] valueForKey:@"Email"]]];
    [AccountNumber addChild:[NSXMLNode textWithStringValue:[[User_Class sharedUser] valueForKey:@"AccountNumber"]]];
    [RememberMe addChild:[NSXMLNode textWithStringValue:[[User_Class sharedUser] valueForKey:@"RememberMe"]]];
    [root addChild:FirstName];
    [root addChild:LastName];
    [root addChild:UserName];
    [root addChild:Token];
    [root addChild:AccountId];
    [root addChild:Email];
    [root addChild:AccountNumber];
    [root addChild:RememberMe];
    [self createFile:xmlDoc];
}

+(void)createFile:(NSXMLDocument*)xmlDoc
{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"xmltest.xml"];
    NSData *xmlData = [xmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
    [xmlData writeToFile:filePath atomically:YES];
}

+(NSString*)checkXML
{
    NSError *error;
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"xmltest.xml"];
    if ([filemanager fileExistsAtPath:filePath])
    {}
    else
        return 0;
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:fileURL
                                                                 options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
                                                                   error:&error];
    NSXMLNode *rootNode = [xmlDoc rootElement];
    NSXMLNode *RememberMe_node = [rootNode childAtIndex:7];
    NSString *string = [RememberMe_node stringValue];
    NSLog(@"%@",string);
    return string;
}

+(void)fillUserClass
{
    NSError *error;
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"xmltest.xml"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:fileURL
                                                                 options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
                                                                   error:&error];
    NSXMLNode *rootNode = [xmlDoc rootElement];
    [[User_Class sharedUser]  setFirstName:[[rootNode childAtIndex:0] stringValue]];
    [[User_Class sharedUser]  setLastName:[[rootNode childAtIndex:1] stringValue]];
    [[User_Class sharedUser]  setUserName:[[rootNode childAtIndex:2] stringValue]];
    [[User_Class sharedUser]  setToken:[[rootNode childAtIndex:3] stringValue]];
    [[User_Class sharedUser]  setAccountId:[[rootNode childAtIndex:4] stringValue]];
    [[User_Class sharedUser]  setEmail:[[rootNode childAtIndex:5] stringValue]];
    [[User_Class sharedUser]  setAccountNumber:[[rootNode childAtIndex:6] stringValue]];
    [[User_Class sharedUser]  setRememberMe:[[rootNode childAtIndex:7] stringValue]];
}

+(void)clear_serialized
{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"xmltest.xml"];
    if([filemanager fileExistsAtPath:filePath])
        [filemanager removeItemAtPath:filePath error:nil];
}
@end
