//
//  UIImage-Extended.h
//  RecipeShopper
//
//  Created by James Grafton on 5/24/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (UIImageWithCopy) 

// Extend UIImage so that we can copy it rather than assign
- (id) copyWithZone: (NSZone *) zone;

@end
