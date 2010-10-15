//
//  UIImage-Extended.h
//  RecipeShopper
//
//  Created by James Grafton on 5/24/10.
//  Copyright 2010 Assentec Global. All rights reserved.
//
//  Extends UIImage adding resize and image pasting functionality

#import <Foundation/Foundation.h>

@interface UIImage (UIImageExtended) 

// Extend UIImage so that we can copy it rather than assign
- (id)copyWithZone:(NSZone *)zone;
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality andScale:(CGFloat)inScale;

@end
