//
//  UserPreference.h
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Assentec Global. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DBUserPreference : NSObject {
	NSString *key;
	NSString *value;
}

@property (readonly, copy) NSString *key;
@property (readonly, copy) NSString *value;

- (id)initWithKey: (NSString*)inKey andValue:(NSString*)inValue;
@end
