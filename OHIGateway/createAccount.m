//
//  createAccount.m
//  Omron2
//
//  Created by Justin Helmick on 12/13/13.
//  Copyright (c) 2013 Justin Helmick. All rights reserved.
//

#import "OMNumeraConnection.h"
#import "createAccount.h"
#import "NSMenuItem+extended.h"
#import "xmlObject.h"
#import "AppDelegate.h"

@implementation createAccount

NSString *error;
NSPropertyListFormat format;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void) awakeFromNib{
    NSString *timezonePath = [[NSBundle mainBundle] pathForResource:@"Timezones" ofType:@"xml"];
    NSString *countryPath = [[NSBundle mainBundle] pathForResource:@"CountryCodes" ofType:@"xml"];
    NSString *culturePath = [[NSBundle mainBundle] pathForResource:@"CultureCodes" ofType:@"xml"];
    [self fillPopUpButton:_timezone :timezonePath];
    [self fillPopUpButton:_culture :culturePath];
    [self fillPopUpButton:_country :countryPath];
}

- (void)drawRect:(NSRect)dirtyRect
{
//    [_fname setPlaceholderString:NSLocalizedString(@"createUser_firstname", @"first name")];
//    [_lname setPlaceholderString:NSLocalizedString(@"createUser_lastname", @"last name")];
//    [_email setPlaceholderString:NSLocalizedString(@"createUser_email", @"email")];
//    [_pword setPlaceholderString:NSLocalizedString(@"createUser_pword", @"password")];
//    [_confirm setPlaceholderString:NSLocalizedString(@"createUser_confirm", @"confirm password")];
//    [_username setPlaceholderString:NSLocalizedString(@"createUser_username", @"username")];
    [_country setStringValue:NSLocalizedString(@"createUser_country", @"country")];
    [_timezone setStringValue:NSLocalizedString(@"createUser_timezone", @"timezone")];
    [_culture setStringValue:NSLocalizedString(@"createUser_culture", @"culture")];
    NSMutableParagraphStyle *centredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [centredStyle setAlignment:NSCenterTextAlignment];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                           NSParagraphStyleAttributeName,
                           [NSFont fontWithName:(@"Menlo Regular") size:14],
                           NSFontAttributeName,
                           [NSColor whiteColor],
                           NSForegroundColorAttributeName,
                           nil];
    NSMutableAttributedString *attributedString =
    [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"CreateUser", @"create user")
                                           attributes:attrs];
    
    [_signin setAttributedTitle: attributedString];

    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
}

- (IBAction)createUser:(id)sender {
    
    [_createError setHidden:YES];
        @try {
            if([[_fname stringValue] isEqualToString:@""])
            {
                [_errorField setStringValue:NSLocalizedString(@"Registration_MissingFirstName_Message", @"Please fill in your First Name before continuing")];
                [_createError setHidden:NO];
                return;
            }
            if([[_lname stringValue] isEqualToString:@""])
            {
                [_errorField setStringValue:NSLocalizedString(@"Registration_MissingLastName_Message", @"Please fill in your Last Name before continuing")];
                [_createError setHidden:NO];
                return;
            }
            if([[_email stringValue] isEqualToString:@""])
            {
                [_errorField setStringValue:NSLocalizedString(@"Registration_MissingEmail_Message", @"Please fill in your Email before continuing")];
                [_createError setHidden:NO];
                return;
            }
            if([[_pword stringValue] isEqualToString:@""])
            {
                [_errorField setStringValue:NSLocalizedString(@"Registration_MissingPassword_Message", @"Please fill in your Password before continuing")];
                [_createError setHidden:NO];
                return;
            }
            if([[_confirm stringValue] isEqualToString:@""])
            {
                [_errorField setStringValue:NSLocalizedString(@"Registration_MissingPassword_Message", @"Please fill in your Password before continuing")];
                [_createError setHidden:NO];
                return;
            }
            if([[_pword stringValue] isEqualToString:[_confirm stringValue]])
            {
                if([self NSStringIsValidEmail:[_email stringValue]])
                {
                    NSString *timezoneValue = [[[_timezone selectedItem] representedObject] valueForKey:@"uploadValue"];
                    NSString *countryValue = [[[_country selectedItem] representedObject] valueForKey:@"uploadValue"];
                    NSString *cultureValue = [[[_culture selectedItem] representedObject] valueForKey:@"uploadValue"];
                    int status = [OMNumeraConnection createUserWithEmail:[_email stringValue]
                                                                Password:[_pword stringValue]
                                                               firstName:[_fname stringValue]
                                                                lastName:[_lname stringValue]
                                                                userName:[_email stringValue]
                                                                 country:countryValue
                                                                 culture:cultureValue
                                                                timezone:timezoneValue];

                
                    DDLogVerbose(@"Create User Status:%d", status);
                    switch (status)
                    {
                        case 0:
                            [_headerUserName setStringValue:[_email stringValue]];
                            [_createError setHidden:YES];
                            [_fname setStringValue:@""];
                            [_lname setStringValue:@""];
                            [_email setStringValue:@""];
                            [_pword setStringValue:@""];
                            [_confirm setStringValue:@""];
                            
                            [_deviceScroll setDocumentView:(_deviceSelect)];
                            NSPoint newOrigin = NSMakePoint(0, NSMaxY([[_deviceScroll documentView] frame]) -
                                                            [[_deviceScroll contentView] bounds].size.height);
                            [[_deviceScroll documentView] scrollPoint:newOrigin];
                            [_headerUserName setHidden:NO];
                            [_headerDropdown setHidden:NO];
                            [[_mainWindow contentView] replaceSubview:self with:_deviceScroll];
                            break;
                        case 1:
                        case 2:
                        case 3:
                        case 4:
                        case 5:
                        case 6:
                        case 7:
                        case 8:
                        case 9:
                        case 10:
                        case 11:
                            [_errorField setStringValue:NSLocalizedString(@"A user with this e-mail already exists, please use a different one.", @"Registration failed. A user with this email account already exists.")];
                            [_createError setHidden:NO];
                            break;
                        case 12:
                            [_errorField setStringValue:NSLocalizedString(@"A user with this username already exists, please use another one.", @"Registration could not be completed successfully.  Please try again later.")];
                            [_createError setHidden:NO];
                            break;
                        default:
                            [_errorField setStringValue:NSLocalizedString(@"Registration_UnexpectedError_Message", @"Registration could not be completed successfully.  Please try again later.")];
                            [_createError setHidden:NO];
                            break;
                    }
                }
                else
                {
                    [_errorField setStringValue:NSLocalizedString(@"Registration_InvalidEmailAddress_Message", @"Please enter a valid email address.")];
                    [_createError setHidden:NO];
                }
            }
            else
            {
                [_errorField setStringValue:NSLocalizedString(@"Registration_PasswordMismatch_Message" ,@"Please be sure that the Password and Confirm Password fields match.")];
                [_createError setHidden:NO];
            }
        }
        @catch (NSException *e) {
            DDLogVerbose(@"Exception: %@", e);
            DDLogVerbose(@"Stack trace: %@", [e callStackSymbols]);
        }
    }

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

-(void) fillPopUpButton:(NSPopUpButton*)popup :(NSString *)filepath
{
    NSError *error;
    NSURL *url = [NSURL fileURLWithPath:filepath];
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:url
                                                                 options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
                                                                   error:&error];
    NSArray *children = [[xmlDoc rootElement] children];
    //NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMenu *popupMenu = [[NSMenu alloc] init];
    NSInteger i, count = [children count];
    for (i=0; i < count; i++)
    {
        xmlObject *xmlobj = [[xmlObject alloc] init];
        NSXMLElement *child = [children objectAtIndex:i];
        NSString *normString = [child stringValue];
        NSXMLNode *valueAttribute = [child attributeForName:@"value"];
        NSString *valueString = [valueAttribute stringValue];
        NSMenuItem *menuitem = [[NSMenuItem alloc] init];
        xmlobj.displayValue = normString;
        xmlobj.uploadValue = valueString;
        [menuitem setTitle:normString];
        [menuitem setRepresentedObject:xmlobj];
        [popupMenu addItem:menuitem];
    }
    [popup setMenu:popupMenu];
    
}


        
@end
