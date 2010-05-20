//
//  UserPreference.h
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DBUserPreference : NSObject {
	NSString *key;
	NSString *value;
}

@property (nonatomic, readonly) NSString *key;
@property (nonatomic, readonly) NSString *value;

-(id)initWithKey: (NSString*)inKey andValue:(NSString*)inValue;
@end
