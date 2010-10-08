//
//  NSData-Extended.h
//  RecipeShopper
//
//  Created by James Grafton on 5/23/10.
//  Copyright 2010 Assentec Global. All rights reserved.
//  
//  Extends the NSData class allowing us to create an NSData object from
//  a base64 encoded NSString
//

#import <Foundation/Foundation.h>

@interface NSData (MBBase64)

+ (NSData *)dataWithBase64EncodedString:(NSString *)string;     //  Padding '=' characters are optional. Whitespace is ignored.

@end

