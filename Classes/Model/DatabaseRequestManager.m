//
//  DatabaseRequestManager.m
//  RecipeShopper
//
//  Created by Simon Barnett on 06/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "DatabaseRequestManager.h"
#import <sqlite3.h>
#import "Recipe.h"
#import "Product.h"
#import "NSData-Extended.h"
#import "LogManager.h"

static sqlite3 *database = nil;

@interface DatabaseRequestManager()

- (Recipe *)createRecipe:(sqlite3_stmt *)selectstmt;
- (Product *)createProduct:(sqlite3_stmt *)selectstmt;

@end

@implementation DatabaseRequestManager

- (id)init {
	if (self = [super init]) {
		NSString *databaseName = @"recipeshopper.sqlite";
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
		NSString *dbPath = [[docPaths objectAtIndex:0] stringByAppendingPathComponent:databaseName];
				
		if ([fileManager fileExistsAtPath:dbPath]) {
			[LogManager log:[NSString stringWithFormat:@"Database %@ found at path %@", databaseName, dbPath] withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
		} else {
			[LogManager log:[NSString stringWithFormat:@"Database %@ not found. Initiating copy to %@", databaseName, dbPath] withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
			
			NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:databaseName];
			NSError *error;
			
			if ([fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error] != YES) {
				[LogManager log:[NSString stringWithFormat:@"Failed to create writable database file with message '%@'", [error localizedDescription]] withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
			}
		}
				
		if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
			[LogManager log:@"Successfully connected to database" withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
		} else {
			sqlite3_close(database);
			[LogManager log:@"Error connecting to database" withLevel:LOG_ERROR fromClass:@"DatabaseRequestManager"];
		}
	}
	
	return self;
}

- (NSArray *)getAllRecipesInCategory:(NSString *)categoryName {
	NSMutableArray *recipes = [NSMutableArray array];
	sqlite3_stmt *selectstmt;
	
	/* create the query based on the category name */
	const char *recipeQuery = [[NSString stringWithFormat:@"select * from recipes WHERE categoryName = '%@'", categoryName] UTF8String];
	
	/* execute the query on the database */
	if (sqlite3_prepare_v2(database, recipeQuery, -1, &selectstmt, NULL) == SQLITE_OK) {
		/* add each recipe found to the recipes array */
		while (sqlite3_step(selectstmt) == SQLITE_ROW) {
			[recipes addObject:[self createRecipe:selectstmt]];
		}
	} else {
		const char *thing = sqlite3_errmsg(database);
		[LogManager log:[NSString stringWithFormat:@"Select query failed: %s", thing] withLevel:LOG_ERROR fromClass:@"DatabaseRequestManager"];
	}
	
	return [NSArray arrayWithArray:recipes];
}

- (void)fetchExtendedDataForRecipe:(Recipe *)recipe {
	sqlite3_stmt *selectstmt;
	
	const char *recipeIngredientsQuery = [[NSString stringWithFormat:@"Select ingredientText from recipeIngredients where recipeID = %@", [recipe recipeID]] UTF8String];
	
	NSMutableArray *textIngredients = [NSMutableArray array];
	
	if (sqlite3_prepare_v2(database, recipeIngredientsQuery, -1, &selectstmt, NULL) == SQLITE_OK) {
		while(sqlite3_step(selectstmt) == SQLITE_ROW) {
			[textIngredients addObject:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(selectstmt, 0)]];
		}
	}
	
	sqlite3_reset(selectstmt);
	
	const char *recipeProductsQuery = [[NSString stringWithFormat:@"Select productID,productQuantity from recipeProducts where recipeID = %@", [recipe recipeID]] UTF8String];
	
	NSMutableDictionary *recipeProducts = [[[NSMutableDictionary alloc] init] autorelease];
	
	if (sqlite3_prepare_v2(database, recipeProductsQuery, -1, &selectstmt, NULL) == SQLITE_OK) {
		while(sqlite3_step(selectstmt) == SQLITE_ROW) {
			NSString *productID =[NSString stringWithUTF8String:(const char *)sqlite3_column_text(selectstmt, 0)];
			NSString *productQuantity = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(selectstmt, 1)];
			[recipeProducts setObject:productQuantity forKey:productID];
		}
	}
	
	sqlite3_reset(selectstmt);
	
	const char *recipeInstructionsQuery = [[NSString stringWithFormat:@"Select instruction, instructionNumber from recipeInstructions where recipeID = %@ ORDER BY instructionNumber ASC", [recipe recipeID]] UTF8String];
	
	NSMutableArray *instructions = [NSMutableArray array];
	
	if (sqlite3_prepare_v2(database, recipeInstructionsQuery, -1, &selectstmt, NULL) == SQLITE_OK) {
		while(sqlite3_step(selectstmt) == SQLITE_ROW) {
			[instructions addObject:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(selectstmt, 0)]];
		}
	}
	
	sqlite3_reset(selectstmt);
	
	const char *recipeNutritionQuery = [[NSString stringWithFormat:@"Select * from recipeNutrition where recipeID = %@", [recipe recipeID]] UTF8String];
	
	NSMutableArray *nutritionalInfo = [NSMutableArray array];
	NSMutableArray *nutritionalInfoPercent = [NSMutableArray array];
	
	if (sqlite3_prepare_v2(database, recipeNutritionQuery, -1, &selectstmt, NULL) == SQLITE_OK) {
		while(sqlite3_step(selectstmt) == SQLITE_ROW) {
			[nutritionalInfo addObject:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(selectstmt, 1)]];
			[nutritionalInfo addObject:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(selectstmt, 2)]];
			[nutritionalInfo addObject:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(selectstmt, 3)]];
			[nutritionalInfo addObject:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(selectstmt, 4)]];
			[nutritionalInfo addObject:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(selectstmt, 5)]];
			
			[nutritionalInfoPercent addObject:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(selectstmt, 6)]];
			[nutritionalInfoPercent addObject:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(selectstmt, 7)]];
			[nutritionalInfoPercent addObject:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(selectstmt, 8)]];
			[nutritionalInfoPercent addObject:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(selectstmt, 9)]];
			[nutritionalInfoPercent addObject:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(selectstmt, 10)]];
		}
	}
	
	/* augment the recipe object with the extra info */
	[recipe setRecipeProducts:recipeProducts];
	[recipe setTextIngredients:textIngredients];
	[recipe setInstructions:instructions];
	[recipe setNutritionalInfo:nutritionalInfo];
	[recipe setNutritionalInfoPercent:nutritionalInfoPercent];
}

- (NSString *)getUserPreference:(NSString *)prefName {
	const char *userPreferencesQuery = [[NSString stringWithFormat:@"select value from userPreferences where key = '%@'", prefName] UTF8String];
	sqlite3_stmt *selectstmt;
	NSString *prefValue = NULL;
	
	if (sqlite3_prepare_v2(database, userPreferencesQuery, -1, &selectstmt, NULL) == SQLITE_OK) {
		if (sqlite3_step(selectstmt) == SQLITE_ROW) {
			prefValue = [[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(selectstmt, 0)] autorelease];	
		}
	}
	
	return prefValue;
}

- (void)setUserPreference:(NSString *)prefName andValue:(NSString *)prefValue {
	const char *userPreferencesQuery = [[NSString stringWithFormat:@"select * from userPreferences where key = '%@'", prefName] UTF8String];
	sqlite3_stmt *updatestmt;
	
	if (sqlite3_prepare_v2(database, userPreferencesQuery, -1, &updatestmt, NULL) == SQLITE_OK) {
		if (sqlite3_step(updatestmt) == SQLITE_ROW) {
			userPreferencesQuery = [[NSString stringWithFormat:@"update userPreferences set value = '%@' WHERE key = '%@'", prefValue, prefName] UTF8String];
		} else {
			userPreferencesQuery = [[NSString stringWithFormat:@"insert into userPreferences values ('%@','%@')", prefName, prefValue] UTF8String];
		}
	}
	
	if (sqlite3_prepare_v2(database, userPreferencesQuery, -1, &updatestmt, NULL) == SQLITE_OK) {
		sqlite3_step(updatestmt);
	}
	
	sqlite3_reset(updatestmt);
}

- (void)addRecipeToHistory:(NSNumber *)recipeID {
	const char *recipeHistoryQuery = [[NSString stringWithFormat:@"insert into recipeHistory (recipeID) values (%@)", recipeID] UTF8String];
	
	sqlite3_stmt *updatestmt;
	
	if (sqlite3_prepare_v2(database, recipeHistoryQuery, -1, &updatestmt, NULL) == SQLITE_OK) {
		if (sqlite3_step(updatestmt) == SQLITE_DONE) {
			NSString *msg = [NSString stringWithFormat:@"Successfully inserted recipe history using query %s", recipeHistoryQuery];
			[LogManager log:msg withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
		} else {
			NSString *msg = [NSString stringWithFormat:@"Error executing statement %s", recipeHistoryQuery];
			[LogManager log:msg withLevel:LOG_ERROR fromClass:@"DatabaseRequestManager"];
		}
	}
	
	sqlite3_reset(updatestmt);
}

- (NSArray *)getRecipeHistory {
	NSMutableArray *recipes = [[[NSMutableArray alloc] init] autorelease];
		
	const char *recipeHistoryQuery = [[NSString stringWithFormat:@"select * from recipes join recipeHistory on recipes.recipeID = recipeHistory.recipeID GROUP BY recipeHistory.recipeID ORDER BY dateTime DESC"] UTF8String];
	
	sqlite3_stmt *selectstmt;
	
	if (sqlite3_prepare_v2(database, recipeHistoryQuery, -1, &selectstmt, NULL) == SQLITE_OK) {
		while (sqlite3_step(selectstmt) == SQLITE_ROW) {
			[recipes addObject:[self createRecipe:selectstmt]];
		}
	}
	
	if ([recipes count] == 0){
		[LogManager log:@"Recipe history table appears empty..." withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
		return [NSArray arrayWithArray:recipes];
	}
	
	sqlite3_reset(selectstmt);
		
	return [NSArray arrayWithArray:recipes];
}

- (void)clearRecipeHistory {
	const char *clearRecipeHistoryCmd = [[NSString stringWithFormat:@"delete from recipeHistory"] UTF8String];
	
	sqlite3_stmt *selectstmt;
	
	if (sqlite3_prepare_v2(database, clearRecipeHistoryCmd, -1, &selectstmt, NULL) == SQLITE_OK) {
		if (sqlite3_step(selectstmt) == SQLITE_DONE) {
			[LogManager log:@"Successfully deleted recipe history" withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
		} else {
			[LogManager log:@"Failed to delete recipe history" withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
		}
	}
	
	sqlite3_reset(selectstmt);	
}

- (Product *)createProductFromProductBaseID:(NSString *)productBaseID {
    NSString *productQuery = [NSString stringWithFormat:@"select * from products WHERE productBaseID = %@", productBaseID];
	
    sqlite3_stmt *selectstmt;
    
    if (sqlite3_prepare_v2(database, [productQuery UTF8String], -1, &selectstmt, NULL) == SQLITE_OK) {
        if (sqlite3_step(selectstmt) == SQLITE_ROW) {
            return [self createProduct:selectstmt];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

- (Recipe *)createRecipe:(sqlite3_stmt *)selectstmt {
	NSNumber *recipeID = [NSNumber numberWithInt:sqlite3_column_int(selectstmt, 0)];
	NSString *recipeName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(selectstmt, 1)];
	NSString *categoryName = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(selectstmt, 2)];
	
	const char *descriptionText = (const char *)sqlite3_column_text(selectstmt, 3);
	NSString *recipeDescription = nil;
	
	if (descriptionText != NULL) {
		recipeDescription = [NSString stringWithUTF8String:descriptionText];
	}
	
	NSNumber *rating = [NSNumber numberWithFloat:sqlite3_column_double(selectstmt, 4)];
	NSInteger ratingCount = sqlite3_column_int(selectstmt, 5);
	
	const char *contributorText = (const char *)sqlite3_column_text(selectstmt, 6);
	NSString *contributor = nil;
	
	if (contributorText != NULL) {
		contributor = [NSString stringWithUTF8String:contributorText];
	}
	
	const char *cookingTimeText = (const char *)sqlite3_column_text(selectstmt, 7);
	NSString *cookingTime = nil;
	
	if (cookingTimeText != NULL) {
		cookingTime = [NSString stringWithUTF8String:cookingTimeText];
	}
	
	const char *preparationTimeText = (const char *)sqlite3_column_text(selectstmt, 8);
	NSString *preparationTime = nil;
	
	if (preparationTimeText != NULL) {
		preparationTime = [NSString stringWithUTF8String: preparationTimeText];
	}
	
	const char *servesText = (const char *)sqlite3_column_text(selectstmt, 9);
	NSString *serves = nil;
	
	if (servesText != NULL) {
		serves = [NSString stringWithUTF8String:servesText];
	}
	
	NSString *smallRecipeImageRaw = [NSString stringWithUTF8String:(const char *)sqlite3_column_blob(selectstmt, 10)];
	UIImage *smallRecipeImage = [UIImage imageWithData:[NSData dataWithBase64EncodedString:smallRecipeImageRaw]];
	
	NSString *largeRecipeImageRaw = [NSString stringWithUTF8String:(const char *)sqlite3_column_blob(selectstmt, 11)];
	UIImage *largeRecipeImage = [UIImage imageWithData:[NSData dataWithBase64EncodedString:largeRecipeImageRaw]];
	
    return [[[Recipe alloc] initWithRecipeID:recipeID andRecipeName:recipeName
							 andCategoryName:categoryName andRecipeDescription:recipeDescription
								   andRating:rating andRatingCount:ratingCount 
							  andContributor:contributor andCookingTime:cookingTime 
						  andPreparationTime:preparationTime andServes:serves
						 andSmallRecipeImage:smallRecipeImage andLargeRecipeImageRaw:largeRecipeImageRaw
						 andLargeRecipeImage:largeRecipeImage] autorelease];
}

- (Product *)createProduct:(sqlite3_stmt *)selectstmt {
	NSNumber *productBaseID = [NSNumber numberWithInt:sqlite3_column_int(selectstmt, 0)];
	NSString *productName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(selectstmt, 1)];
	NSString *productPrice = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(selectstmt, 2)];
	NSString *productImageString = [NSString stringWithUTF8String:(const char *)sqlite3_column_blob(selectstmt, 3)];
	UIImage *productImage = [UIImage imageWithData:[NSData dataWithBase64EncodedString:productImageString]];
	
	return [[[Product alloc] initWithProductBaseID:productBaseID andProductID:[NSNumber numberWithInt:0] andProductName:productName
							   andProductPrice:productPrice andProductOffer:@""
							   andProductImage:productImage andProductOfferImage:NULL] autorelease];
}

@end
