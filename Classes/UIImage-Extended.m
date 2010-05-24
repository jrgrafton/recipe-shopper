//
//  UIImage-Extended.m
//  RecipeShopper
//
//  Created by James Grafton on 5/24/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "UIImage-Extended.h"


@implementation UIImage (UIImageWithCopy)

- (id) copyWithZone: (NSZone *) zone
{
    return [[UIImage allocWithZone: zone] initWithCGImage: self.CGImage];
}

@end
