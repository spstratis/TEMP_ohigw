//
//  EulaView.m
//  Bi-LINK Gateway
//
//  Created by S.Stratis on 6/16/14.
//  Copyright (c) 2014 Justin Helmick. All rights reserved.
//

#import "EulaView.h"

@implementation EulaView


-(void)awakeFromNib
{
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"EULA_Bi-LINK.pdf" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    PDFDocument *pdfDoc = [[PDFDocument alloc] initWithURL:url];
    [_pdfView setDocument:pdfDoc];
    
}

@end
