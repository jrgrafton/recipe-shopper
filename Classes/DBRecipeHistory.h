//
//  RecipeHistory.h
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

//Use below code to convert from SQLLite to NSDate format

/*NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //this is the sqlite's format
NSDate *date = [formatter dateFromString:score.datetime];*/

@interface DBRecipeHistory : NSObject {
	NSString *recipeID;
	NSDate *dateTime;
}

@property (readonly,copy) NSString *recipeID;
@property (readonly,copy) NSDate *dateTime;

- (id)initWithRecipeID: (NSString*)inRecipeID andDateTime:(NSDate*)inDateTime;

@end
