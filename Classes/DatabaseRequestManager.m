//
//  DatabaseManager.m
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Assentec Global. All rights reserved.
//

#import <sqlite3.h>
#import "DatabaseRequestManager.h"
#import "DataManager.h"
#import "NSData-Extended.h"
#import "DBProduct.h"
#import "LogManager.h"

static NSString *databaseName = @"jamesgrafton_rs.sqlite";
static sqlite3 *database = nil;

@interface DatabaseRequestManager ()
	//Private class functions
	-(void)copyDatabaseIfNeeded;
	-(NSString *)getDBPath;
	-(DBRecipe *)buildRecipeDBObjectFromRow: (sqlite3_stmt *)selectstmt;
	-(DBProduct *)buildProductDBObjectFromRow: (sqlite3_stmt *)selectstmt;
@end

@implementation DatabaseRequestManager

- (id)init {
	if (self = [super init]) {
		[self copyDatabaseIfNeeded];
		if (sqlite3_open([[self getDBPath] UTF8String], &database) == SQLITE_OK) {
			[LogManager log:@"Successfully connected to database" withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
		}else{
			sqlite3_close(database);
			[LogManager log:@"Error connecting to database" withLevel:LOG_ERROR fromClass:@"DatabaseRequestManager"];
		}
	}
	return self;
}

- (void)copyDatabaseIfNeeded {
	//Using NSFileManager we can perform many file system operations.
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSString *dbPath = [self getDBPath];
	BOOL success = [fileManager fileExistsAtPath:dbPath];
	
	/*
	#ifdef DEBUG
	//Always copy database when in debug mode
	if (success) {
		success = [fileManager removeItemAtPath:dbPath error:&error];
		if (!success){
			NSString *msg = [NSString stringWithFormat:@"error removing old database: '%@'.",[error localizedDescription]];
			[LogManager log:msg withLevel:LOG_ERROR fromClass:@"DataManager"];
		}
		success = FALSE;
	}
	#endif DEBUG*/
	
	if(!success) {
		NSString *msg = [NSString stringWithFormat:@"Database %@ not found. Initiating copy to %@",databaseName,dbPath];
		[LogManager log:msg withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
		
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
		
		if (!success){
			NSString *msg = [NSString stringWithFormat:@"Failed to create writable database file with message '%@'.",[error localizedDescription]];
			[LogManager log:msg withLevel:LOG_INFO fromClass:@"DataManager"];
		}
	}else{
		
			NSString *msg = [NSString stringWithFormat:@"Database %@ found at path %@",databaseName,dbPath];
			[LogManager log:msg withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
		
	}
	[LogManager log:@"Finished initialisation" withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
	
}

- (NSString*)getDBPath {
	return [[DataManager fetchUserDocumentsPath] stringByAppendingPathComponent:databaseName];
}

- (NSString*) fetchUserPreference: (NSString*) key {
	//First get recipe ID's from 'recipeHistory' table
	const char *userPreferencesQuery = [[NSString stringWithFormat:@"select value from userPreferences where key = '%@';",key] UTF8String];

	NSString *msg = [NSString stringWithFormat:@"Executing user preference query %s",userPreferencesQuery];
	[LogManager log:msg withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];	
	
	sqlite3_stmt *selectstmt;
	NSString *result = NULL;
	if(sqlite3_prepare_v2(database, userPreferencesQuery, -1, &selectstmt, NULL) == SQLITE_OK) {
		if(sqlite3_step(selectstmt) == SQLITE_ROW) {
			result = [[[NSString alloc] initWithUTF8String: (const char *)sqlite3_column_text(selectstmt, 0)] autorelease];	
		}
	}else{
		NSString *msg = [NSString stringWithFormat:@"Error executing statement %s",userPreferencesQuery];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"DatabaseRequestManager"];
	}
	if (result == NULL) {
		
		NSString *msg = [NSString stringWithFormat:@"No userPreference values found to match key %@",key];
		[LogManager log:msg withLevel:LOG_WARNING fromClass:@"DatabaseRequestManager"];
		
	}
	
	return result;
}

- (void)putUserPreference: (NSString*)key andValue:(NSString*)value {
	const char *userPreferencesQuery = [[NSString stringWithFormat:@"SELECT * FROM userPreferences WHERE key = '%@'",key] UTF8String];
	
		NSString *msg = [NSString stringWithFormat:@"Executing user preference query %s",userPreferencesQuery];
		[LogManager log:msg withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
	
	
	sqlite3_stmt *updatestmt;
	if(sqlite3_prepare_v2(database, userPreferencesQuery, -1, &updatestmt, NULL) == SQLITE_OK) {
		if(sqlite3_step(updatestmt) == SQLITE_ROW) {
			userPreferencesQuery = [[NSString stringWithFormat:@"UPDATE userPreferences SET value = '%@' WHERE key = '%@'",value,key] UTF8String];
		}else {
			userPreferencesQuery = [[NSString stringWithFormat:@"INSERT INTO userPreferences VALUES ('%@','%@')",key,value] UTF8String];
		}
	}else {
		NSString *msg = [NSString stringWithFormat:@"Error executing statement %s",userPreferencesQuery];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"DatabaseRequestManager"];
	}

	if(sqlite3_prepare_v2(database, userPreferencesQuery, -1, &updatestmt, NULL) == SQLITE_OK) {
		if(SQLITE_DONE == sqlite3_step(updatestmt)){
			NSString *msg = [NSString stringWithFormat:@"Successfully inserted user preference using query %s",userPreferencesQuery];
			[LogManager log:msg withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
		}
	
	}else {
		NSString *msg = [NSString stringWithFormat:@"Error executing statement %s",userPreferencesQuery];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"DatabaseRequestManager"];
	}
	
	sqlite3_reset(updatestmt);
}

- (void)putRecipeHistory: (NSNumber*)recipeID {
	const char *recipeHistoryQuery = [[NSString stringWithFormat:@"INSERT INTO recipeHistory (recipeID) VALUES (%@)",recipeID] UTF8String];

	sqlite3_stmt *updatestmt;
	if(sqlite3_prepare_v2(database, recipeHistoryQuery, -1, &updatestmt, NULL) == SQLITE_OK) {
		if(SQLITE_DONE == sqlite3_step(updatestmt)){
			NSString *msg = [NSString stringWithFormat:@"Successfully inserted recipe history using query %s",recipeHistoryQuery];
			[LogManager log:msg withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
		
		}else {
			NSString *msg = [NSString stringWithFormat:@"Error executing statement %s",recipeHistoryQuery];
			[LogManager log:msg withLevel:LOG_ERROR fromClass:@"DatabaseRequestManager"];
		}
	}else {
		NSString *msg = [NSString stringWithFormat:@"Error executing statement %s",recipeHistoryQuery];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"DatabaseRequestManager"];
	}

	sqlite3_reset(updatestmt);
}

- (NSArray*)fetchLastPurchasedRecipes: (NSInteger)count {
	NSMutableArray *recipes = [[[NSMutableArray alloc] init] autorelease];
	NSMutableArray *recipeIDs = [NSMutableArray array];
	
	//First get recipe ID's from 'recipeHistory' table
	const char *recipeHistoryQuery = [[NSString stringWithFormat:@"select recipeID from recipeHistory ORDER BY dateTime DESC LIMIT %d",count] UTF8String];
	sqlite3_stmt *selectstmt;
	if(sqlite3_prepare_v2(database, recipeHistoryQuery, -1, &selectstmt, NULL) == SQLITE_OK) {
		while(sqlite3_step(selectstmt) == SQLITE_ROW) {
			[recipeIDs addObject: [NSNumber numberWithInt: sqlite3_column_int(selectstmt, 0)]];
		}
	}else{
		NSString *msg = [NSString stringWithFormat:@"Error executing statement %@",recipeHistoryQuery];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"DatabaseRequestManager"];
	}
	if ([recipeIDs count] == 0){
		[LogManager log:@"Recipe history table appears empty..." withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
		return [NSArray arrayWithArray:recipes];
	}
	sqlite3_reset(selectstmt);
	
	//Now fetch recipe items from 'recipes' table
	[LogManager log:@"Fetching recipe history" withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
	
	int i = [recipeIDs count];
	int j = i - 1;
	NSString *recipeQuery = @"select * from recipes WHERE ";
	while ( i-- ) {
		recipeQuery = [NSString stringWithFormat:@"%@recipeID = %@", recipeQuery,[recipeIDs objectAtIndex:j - i]]; 
		if (i > 0) {
			recipeQuery = [NSString stringWithFormat:@"%@%@", recipeQuery, @" or "];
		}
	}
	recipeQuery = [NSString stringWithFormat:@"%@%@", recipeQuery, @";"];
	NSString *msg = [NSString stringWithFormat:@"Executing recipe query %@",recipeQuery];
	[LogManager log:msg withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
	
	if(sqlite3_prepare_v2(database, [recipeQuery UTF8String], -1, &selectstmt, NULL) == SQLITE_OK) {
		while(sqlite3_step(selectstmt) == SQLITE_ROW) {
			[recipes addObject: [self buildRecipeDBObjectFromRow: selectstmt]];
		}
	}else{
		NSString *msg = [NSString stringWithFormat:@"Error executing statement %@",recipeHistoryQuery];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"DatabaseRequestManager"];
	}
	
	//Release original recipeIDs array since we explicitly alloc'd
	return [NSArray arrayWithArray:recipes];
}

- (NSArray*)fetchAllRecipesInCategory: (NSString*) category {
	NSMutableArray *recipes = [NSMutableArray array];
   //First get recipe ID's from 'recipeHistory' table
   const char *recipeQuery = [[NSString stringWithFormat:@"select * from recipes WHERE categoryName = '%@'",category] UTF8String];
 
   sqlite3_stmt *selectstmt;
   if(sqlite3_prepare_v2(database, recipeQuery, -1, &selectstmt, NULL) == SQLITE_OK) {
	   while(sqlite3_step(selectstmt) == SQLITE_ROW) {
		   DBRecipe *recipe = [self buildRecipeDBObjectFromRow: selectstmt];
		   [recipes addObject: recipe];
	   }
   }else{
	   NSString *msg = [NSString stringWithFormat:@"Error executing statement %@",recipeQuery];
	   [LogManager log:msg withLevel:LOG_ERROR fromClass:@"DatabaseRequestManager"];
   }
							   
	return [NSArray arrayWithArray:recipes];
}

- (NSArray*)fetchProductsFromIDs: (NSArray*) productIDs{
	NSMutableArray *products = [NSMutableArray array];	
	
	int i = [productIDs count];
	int j = i - 1;
	NSString *productQuery = @"select * from products WHERE ";
	while ( i-- ) {
		productQuery = [NSString stringWithFormat:@"%@ productBaseID = %@", productQuery,[productIDs objectAtIndex:j - i]]; 
		if (i > 0) {
			productQuery = [NSString stringWithFormat:@"%@%@", productQuery, @" or "];
		}
	}
	productQuery = [NSString stringWithFormat:@"%@%@", productQuery, @";"];
	
	
	NSString *msg = [NSString stringWithFormat:@"Executing product query %@",productQuery];
	[LogManager log:msg withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
	
	
	sqlite3_stmt *selectstmt;
	if(sqlite3_prepare_v2(database, [productQuery UTF8String], -1, &selectstmt, NULL) == SQLITE_OK) {
		while(sqlite3_step(selectstmt) == SQLITE_ROW) {
			DBProduct *product = [self buildProductDBObjectFromRow: selectstmt];
			[products addObject: product];
		}
	}else{
		NSString *msg = [NSString stringWithFormat:@"Error executing statement %@",productQuery];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"DatabaseRequestManager"];
	}
	
	return products;
}

-(DBProduct *)buildProductDBObjectFromRow: (sqlite3_stmt *)selectstmt {
	NSNumber *productID;
	NSNumber *productBaseID;
	NSString *productName;
	NSString *productPrice;
	UIImage *productIcon;
	NSDate *lastUpdated;
	
	//We dont store productID in DB at this point...
	productID = [NSNumber numberWithInt:0];
	productBaseID = [NSNumber numberWithInt: sqlite3_column_int(selectstmt, 0)];
	productName = [NSString stringWithUTF8String: (const char *)sqlite3_column_text(selectstmt, 1)];
	productPrice = [NSString stringWithUTF8String: (const char *) sqlite3_column_text(selectstmt, 2)];
	NSString* productIconString = [NSString stringWithUTF8String: (const char *) sqlite3_column_blob(selectstmt, 3)];
	productIcon = [UIImage imageWithData: [NSData dataWithBase64EncodedString: productIconString]];
	lastUpdated =[NSDate dateWithTimeIntervalSinceNow: sqlite3_column_double(selectstmt, 4)];
	
	return [[[DBProduct alloc] initWithProductID:productID andProductBaseID: productBaseID andProductName:productName
							  andProductPrice:productPrice andProductIcon:productIcon
								 andLastUpdated:lastUpdated andUserAdded:NO] autorelease];
}

- (DBRecipe *)buildRecipeDBObjectFromRow: (sqlite3_stmt *)selectstmt {
	NSNumber *recipeID;
	NSString *recipeName;
	NSString *categoryName;
	NSString *recipeDescription = nil;		//Possibility of NULL
	NSMutableArray *instructions = [NSMutableArray array];
	NSNumber *rating;
	NSInteger ratingCount;
	NSString *contributor = nil;		//Possibility of NULL
	NSString *cookingTime = nil;		//Possibility of NULL
	NSString *preparationTime = nil;	//Possibility of NULL
	NSString *serves = nil;			//Possibility of NULL
	NSMutableArray *textIngredients = [NSMutableArray array];
	NSMutableArray *idProducts = [NSMutableArray array];
	NSMutableArray *idProductsQuantity = [NSMutableArray array];
	NSMutableArray *nutritionalInfo = [NSMutableArray array];			//Possibility of Empty
	NSMutableArray *nutritionalInfoPercent = [NSMutableArray array];	//Possibility of Empty
	UIImage *iconSmall;	
	UIImage *iconLarge;	
	NSString *iconLargeRaw;				//Base64 enc jpg
	
	
		[LogManager log:@"Preparing recipe from row" withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
	

	recipeID = [NSNumber numberWithInt: sqlite3_column_int(selectstmt, 0)];
	recipeName = [NSString stringWithUTF8String: (const char *)sqlite3_column_text(selectstmt, 1)];
	categoryName = [NSString stringWithUTF8String: (const char *) sqlite3_column_text(selectstmt, 2)];
	
	const char *descriptionText = (const char *)sqlite3_column_text(selectstmt, 3);
	if (descriptionText != NULL) {
		recipeDescription = [NSString stringWithUTF8String: descriptionText];
	}
	
	rating = [NSNumber numberWithFloat: sqlite3_column_double(selectstmt, 4)];
	ratingCount = sqlite3_column_int(selectstmt, 5);
	
	const char *contributorText = (const char *)sqlite3_column_text(selectstmt, 6);
	if (contributorText != NULL) {
		contributor = [NSString stringWithUTF8String: contributorText];
	}
	
	const char *cookingTimeText = (const char *)sqlite3_column_text(selectstmt, 7);
	if (cookingTimeText != NULL) {
		cookingTime = [NSString stringWithUTF8String: cookingTimeText];
	}
	
	const char *preparationTimeText = (const char *)sqlite3_column_text(selectstmt, 8);
	if (preparationTimeText != NULL) {
		preparationTime = [NSString stringWithUTF8String: preparationTimeText];
	}
	
	const char *servesText = (const char *)sqlite3_column_text(selectstmt, 9);
	if (servesText != NULL) {
		serves = [NSString stringWithUTF8String: servesText];
	}
	
	NSString* iconSmallString = [NSString stringWithUTF8String: (const char *) sqlite3_column_blob(selectstmt, 10)];
	
	//Small icon is more useful as UIImage
	iconSmall = [UIImage imageWithData: [NSData dataWithBase64EncodedString: iconSmallString]];
	iconLargeRaw = [NSString stringWithUTF8String: (const char *) sqlite3_column_blob(selectstmt, 11)];
	iconLarge = [UIImage imageWithData: [NSData dataWithBase64EncodedString: iconLargeRaw]];
	//iconLarge = [iconLarge resizedImage:CGSizeMake(66,66) interpolationQuality:kCGInterpolationHigh];		 
	
    return [[[DBRecipe alloc] initWithRecipeID:recipeID andRecipeName:recipeName
							  andCategoryName:categoryName andRecipeDescription:recipeDescription
							  andInstructions:instructions andRating:rating 
							  andRatingCount:ratingCount andContributor:contributor
							  andCookingTime:cookingTime andPreparationTime:preparationTime
							  andServes:serves andTextIngredients:textIngredients 
							  andIDProducts:idProducts andIDProductsQuantity:idProductsQuantity
							  andNutritionalInfo:nutritionalInfo andNutritionalInfoPercent:nutritionalInfoPercent 
							  andIconSmall:iconSmall andIconLarge:iconLarge andIconLargeRaw:iconLargeRaw] autorelease];
}

- (void)fetchExtendedDataForRecipe: (DBRecipe*) recipe {
	NSNumber *recipeID = [recipe recipeID];
	NSMutableArray *idProducts = [NSMutableArray array];
	NSMutableArray *idProductsQuantity = [NSMutableArray array];
	NSMutableArray *textIngredients = [NSMutableArray array];
	NSMutableArray *instructions = [NSMutableArray array];
	NSMutableArray *nutritionalInfo = [NSMutableArray array];
	NSMutableArray *nutritionalInfoPercent = [NSMutableArray array];
	
	//Get multi part data from rest of tables...starting with ingredient text
	sqlite3_stmt *selectstmt2;
	const char *ingredientTextQuery = [[NSString stringWithFormat:@"Select ingredientText from recipeIngredients where recipeID = %@",recipeID] UTF8String];
	if(sqlite3_prepare_v2(database, ingredientTextQuery, -1, &selectstmt2, NULL) == SQLITE_OK) {
		while(sqlite3_step(selectstmt2) == SQLITE_ROW) {
			[textIngredients addObject: [NSString stringWithUTF8String: (const char *) sqlite3_column_text(selectstmt2, 0)]];
		}
	}else{
		NSString *msg = [NSString stringWithFormat:@"Error executing statement %s",ingredientTextQuery];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"DatabaseRequestManager"];
	}	
	sqlite3_reset(selectstmt2);
	//Recipe products query
	const char *idProductsQuery = [[NSString stringWithFormat:@"Select productID,productQuantity from recipeProducts where recipeID = %@",recipeID] UTF8String];
	if(sqlite3_prepare_v2(database, idProductsQuery, -1, &selectstmt2, NULL) == SQLITE_OK) {
		while(sqlite3_step(selectstmt2) == SQLITE_ROW) {
			[idProducts addObject: [NSString stringWithUTF8String: (const char *) sqlite3_column_text(selectstmt2, 0)]];
			[idProductsQuantity addObject: [NSString stringWithUTF8String: (const char *) sqlite3_column_text(selectstmt2, 1)]];
		}
	}else{
		NSString *msg = [NSString stringWithFormat:@"Error executing statement %s",idProductsQuery];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"DatabaseRequestManager"];
	}
	sqlite3_reset(selectstmt2);	
	//Recipe instructions query
	const char *recipeInstructionsQuery = [[NSString stringWithFormat:@"Select instruction,instructionNumber from recipeInstructions where recipeID = %@ ORDER BY instructionNumber ASC",recipeID] UTF8String];
	if(sqlite3_prepare_v2(database, recipeInstructionsQuery, -1, &selectstmt2, NULL) == SQLITE_OK) {
		while(sqlite3_step(selectstmt2) == SQLITE_ROW) {
			[instructions addObject: [NSString stringWithUTF8String: (const char *) sqlite3_column_text(selectstmt2, 0)]];
		}
	}else{
		NSString *msg = [NSString stringWithFormat:@"Error executing statement %s",recipeInstructionsQuery];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"DatabaseRequestManager"];
	}
	sqlite3_reset(selectstmt2);
	//Recipe nutritional info query
	const char *recipeNutritionQuery = [[NSString stringWithFormat:@"Select * from recipeNutrition where recipeID = %@",recipeID] UTF8String];
	if(sqlite3_prepare_v2(database, recipeNutritionQuery, -1, &selectstmt2, NULL) == SQLITE_OK) {
		while(sqlite3_step(selectstmt2) == SQLITE_ROW) {
			[nutritionalInfo addObject: [NSString stringWithUTF8String: (const char *) sqlite3_column_text(selectstmt2, 1)]];
			[nutritionalInfo addObject: [NSString stringWithUTF8String: (const char *) sqlite3_column_text(selectstmt2, 2)]];
			[nutritionalInfo addObject: [NSString stringWithUTF8String: (const char *) sqlite3_column_text(selectstmt2, 3)]];
			[nutritionalInfo addObject: [NSString stringWithUTF8String: (const char *) sqlite3_column_text(selectstmt2, 4)]];
			[nutritionalInfo addObject: [NSString stringWithUTF8String: (const char *) sqlite3_column_text(selectstmt2, 5)]];
			
			[nutritionalInfoPercent addObject: [NSString stringWithUTF8String: (const char *) sqlite3_column_text(selectstmt2, 6)]];
			[nutritionalInfoPercent addObject: [NSString stringWithUTF8String: (const char *) sqlite3_column_text(selectstmt2, 7)]];
			[nutritionalInfoPercent addObject: [NSString stringWithUTF8String: (const char *) sqlite3_column_text(selectstmt2, 8)]];
			[nutritionalInfoPercent addObject: [NSString stringWithUTF8String: (const char *) sqlite3_column_text(selectstmt2, 9)]];
			[nutritionalInfoPercent addObject: [NSString stringWithUTF8String: (const char *) sqlite3_column_text(selectstmt2, 10)]];
		}
	}else{
		NSString *msg = [NSString stringWithFormat:@"Error executing statement %s",recipeNutritionQuery];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"DatabaseRequestManager"];
	}
	
	//Set the recipe extended instance variables
	[recipe setIdProducts:idProducts];
	[recipe setIdProductsQuantity:idProductsQuantity];
	[recipe setTextIngredients:textIngredients];
	[recipe setInstructions:instructions];
	[recipe setNutritionalInfo:nutritionalInfo];
	[recipe setNutritionalInfoPercent:nutritionalInfoPercent];
}

- (void)dealloc {
	[super dealloc];
	sqlite3_close(database);
}
@end
