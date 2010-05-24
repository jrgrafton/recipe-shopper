//
//  NSData-Extended.h
//  RecipeShopper
//
//  Created by James Grafton on 5/23/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (MBBase64)

+ (NSData *)dataWithBase64EncodedString:(NSString *)string;     //  Padding '=' characters are optional. Whitespace is ignored.
- (NSString *)base64Encoding;

@end

