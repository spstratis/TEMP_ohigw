//
//  NSButton+GWButton.m
//  Bi-LINK Gateway
//
//  Created by S.Stratis on 6/12/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import "NSButton+GWButton.h"

@implementation NSButton (GWButton)

-(NSColor *)titleColor
{
    NSColor *l_textColor = [NSColor controlTextColor];
    
    NSAttributedString *l_attributedTitle = [self attributedTitle];
    NSUInteger l_len = [l_attributedTitle length];
    
    if (l_len)
    {
        NSDictionary *l_attrs = [l_attributedTitle fontAttributesInRange:NSMakeRange(0, 1)];
        
        if (l_attrs)
        {
            l_textColor = [l_attrs objectForKey:NSForegroundColorAttributeName];
        }
    }
    
    return l_textColor;
}

-(void) setTitleColor:(NSColor *)color
{
    NSMutableAttributedString *l_attributedTitle = [[NSMutableAttributedString alloc]
                                                    initWithAttributedString:[self attributedTitle]];
    
    NSUInteger l_len = [l_attributedTitle length];
    NSRange l_range = NSMakeRange(0, l_len);
    [l_attributedTitle addAttribute:NSForegroundColorAttributeName
                              value:color
                              range:l_range];
    [l_attributedTitle fixAttributesInRange:l_range];
    
    [self setAttributedTitle:l_attributedTitle];
                                                
}
@end
