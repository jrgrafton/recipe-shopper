//
//  DatabaseManager.m
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <sqlite3.h>
#import "DatabaseRequestManager.h"
#import "NSData-Extended.h"
#import "DBRecipe.h"
#import "LogManager.h"

static NSString *databaseName = @"jamesgrafton_rs.sqlite";
static sqlite3 *database = nil;

@interface DatabaseRequestManager ()
	//Private class functions
	-(void)copyDatabaseIfNeeded;
	-(NSString *)getDBPath;
	-(DBRecipe *)buildRecipeDBObjectFromRow: (sqlite3_stmt *)selectstmt;
@end

@implementation DatabaseRequestManager

- (id)init {
	if (self = [super init]) {
		[self copyDatabaseIfNeeded];
		if (sqlite3_open([[self getDBPath] UTF8String], &database) == SQLITE_OK) {
			#ifdef DEBUG
				[LogManager log:@"Successfully connected to database" withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
			#endif
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
	
	if(!success) {
		#ifdef DEBUG
			NSString *msg = [NSString stringWithFormat:@"Database %@ not found. Initiating copy...",databaseName];
			[LogManager log:msg withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
		#endif
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
		
		if (!success){
			NSString *msg = [NSString stringWithFormat:@"Failed to create writable database file with message '%@'.",[error localizedDescription]];
			[LogManager log:msg withLevel:LOG_INFO fromClass:@"DataManager"];
		}
	}else{
		#ifdef DEBUG
			NSString *msg = [NSString stringWithFormat:@"Database %@ found at path %@",databaseName,dbPath];
			[LogManager log:msg withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
		#endif
	}
	#ifdef DEBUG
		[LogManager log:@"Finished initialisation" withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
	#endif
}

- (NSString*)getDBPath {
	//Search for standard documents using NSSearchPathForDirectoriesInDomains
	//First Param = Searching the documents directory
	//Second Param = Searching the Users directory and not the System
	//Expand any tildes and identify home directories.
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	return [documentsDir stringByAppendingPathComponent:databaseName];
}

- (NSArray*)fetchLastPurchasedRecipes: (NSInteger)count {
	NSMutableArray *recipes = [[NSMutableArray alloc] init];
	NSMutableArray *recipeIDs = [[NSMutableArray alloc] init];
	
	//First get recipe ID's from 'recipeHistory' table
	const char *recipeHistoryQuery = [[NSString stringWithFormat:@"select recipeID from recipeHistory ORDER BY dateTime DESC LIMIT %d",count] UTF8String];
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
		#ifdef DEBUG
				[LogManager log:@"Recipe history table appears empty..." withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
		#endif
		return recipes;
	}
	
	//Now fetch recipe items from 'recipes' table
	#ifdef DEBUG
		[LogManager log:@"Fetching recipe history" withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
	#endif
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
	
	#ifdef DEBUG
		NSString *msg = [NSString stringWithFormat:@"Executing recipe query %@",recipeQuery];
		[LogManager log:msg withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
	#endif
	
	if(sqlite3_prepare_v2(database, [recipeQuery UTF8String], -1, &selectstmt, NULL) == SQLITE_OK) {
		while(sqlite3_step(selectstmt) == SQLITE_ROW) {
			[recipes addObject: [self buildRecipeDBObjectFromRow: selectstmt]];
		}
	}else{
		NSString *msg = [NSString stringWithFormat:@"Error executing statement %@",recipeHistoryQuery];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"DatabaseRequestManager"];
	}
	
	return [NSArray arrayWithArray:recipes];
}

- (DBRecipe *)buildRecipeDBObjectFromRow: (sqlite3_stmt *)selectstmt {
	NSInteger recipeID;
	NSString *recipeName;
	NSString *categoryName;
	NSString *description = NULL;		//Possibility of NULL
	NSArray *instructions;
	NSNumber *rating;
	NSInteger ratingCount;
	NSString *contributor = NULL;		//Possibility of NULL
	NSString *cookingTime = NULL;		//Possibility of NULL
	NSString *preparationTime = NULL;	//Possibility of NULL
	NSString *serves = NULL;			//Possibility of NULL
	NSArray *textIngredients;
	NSArray *idIngredients;
	NSArray *nutritionalInfo = NULL;	//Possibility of NULL
	UIImage *iconSmall;				
	NSString *iconLargeRaw;				//Base64 enc jpg
	
	#ifdef DEBUG
		[LogManager log:@"Preparing recipe from row" withLevel:LOG_INFO fromClass:@"DatabaseRequestManager"];
	#endif

	recipeID = sqlite3_column_int(selectstmt, 0);
	recipeName = [NSString stringWithUTF8String: (const char *)sqlite3_column_text(selectstmt, 1)];
	categoryName = [NSString stringWithUTF8String: (const char *) sqlite3_column_text(selectstmt, 2)];
	
	const char *descriptionText = (const char *)sqlite3_column_text(selectstmt, 3);
	if (descriptionText != NULL) {
		description = [NSString stringWithUTF8String: descriptionText];
	}
	
	NSString* instructionsCombined = [NSString stringWithUTF8String: (const char *) sqlite3_column_text(selectstmt, 4)];
	instructions = [instructionsCombined componentsSeparatedByString:@"|||"];
	
	rating = [NSNumber numberWithFloat: sqlite3_column_double(selectstmt, 5)];
	ratingCount = sqlite3_column_int(selectstmt, 6);
	
	const char *contributorText = (const char *)sqlite3_column_text(selectstmt, 7);
	if (contributorText != NULL) {
		contributor = [NSString stringWithUTF8String: contributorText];
	}
	
	const char *cookingTimeText = (const char *)sqlite3_column_text(selectstmt, 8);
	if (cookingTimeText != NULL) {
		cookingTime = [NSString stringWithUTF8String: cookingTimeText];
	}
	
	const char *preparationTimeText = (const char *)sqlite3_column_text(selectstmt, 9);
	if (preparationTimeText != NULL) {
		preparationTime = [NSString stringWithUTF8String: preparationTimeText];
	}
	
	const char *servesText = (const char *)sqlite3_column_text(selectstmt, 10);
	if (servesText != NULL) {
		serves = [NSString stringWithUTF8String: servesText];
	}
	
	NSString* textIngredientsCombined = [NSString stringWithUTF8String: (const char *) sqlite3_column_text(selectstmt, 11)];
	textIngredients = [textIngredientsCombined componentsSeparatedByString:@"|||"];
	
	NSString* idIngredientsCombined = [NSString stringWithUTF8String: (const char *) sqlite3_column_text(selectstmt, 12)];
	idIngredients = [idIngredientsCombined componentsSeparatedByString:@","];
	
	const char *nutritionalInfoCombinedText = (const char *)sqlite3_column_text(selectstmt, 13);
	if (nutritionalInfoCombinedText != NULL) {
		NSString* nutritionalInfoCombined = [NSString stringWithUTF8String: nutritionalInfoCombinedText];
		nutritionalInfo = [nutritionalInfoCombined componentsSeparatedByString:@"|||"];
	}
	
	NSString* iconSmallString = [NSString stringWithUTF8String: (const char *) sqlite3_column_blob(selectstmt, 14)];
	
	//Small icon is more useful as UIImage
	iconSmall = [UIImage imageWithData: [NSData dataWithBase64EncodedString: iconSmallString]];
	iconLargeRaw = [NSString stringWithUTF8String: (const char *) sqlite3_column_blob(selectstmt, 15)];
				 
    return [[DBRecipe alloc] initWithRecipeID:recipeID andRecipeName:recipeName
							  andCategoryName:categoryName andDescription:description
							  andInstructions:instructions andRating:rating 
							  andRatingCount:ratingCount andContributor:contributor
							  andCookingTime:cookingTime andPreparationTime:preparationTime
							  andServes:serves andTextIngredients:textIngredients 
							  andIDIngredients:idIngredients andNutritionalInfo:nutritionalInfo
							  andIconSmall:iconSmall andIconLargeRaw:iconLargeRaw];
}

- (void)dealloc {
	[super dealloc];
	sqlite3_close(database);
}
@end
