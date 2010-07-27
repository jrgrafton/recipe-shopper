//
//  UIImage-Extended.h
//  RecipeShopper
//
//  Created by James Grafton on 5/24/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//
//  Extends UIImage adding resize and image pasting functionality

#import <Foundation/Foundation.h>

@interface UIImage (UIImageExtended) 

// Extend UIImage so that we can copy it rather than assign
- (id) copyWithZone: (NSZone *) zone;
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality;
+ (UIImage *)pasteImage:(UIImage *)im1 intoImage:(UIImage *)im2 atOffset:(CGPoint)offset;

@end
