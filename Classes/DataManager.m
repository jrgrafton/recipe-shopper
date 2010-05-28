//
//  DataManager.m
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "DataManager.h"
#import "DatabaseRequestManager.h"
#import "APIRequestManager.h"
#import "LogManager.h"

static DatabaseRequestManager *databaseRequestManager;
static APIRequestManager *apiRequestManager;

@implementation DataManager

+ (void)initRequestManagers {
	#ifdef DEBUG
		[LogManager log:@"Initialising request managers" withLevel:LOG_INFO fromClass:@"DataManager"];
	#endif
	#ifdef DEBUG
		[LogManager log:@"Initialising database request manager" withLevel:LOG_INFO fromClass:@"DataManager"];
	#endif
	databaseRequestManager = [[DatabaseRequestManager alloc] init];
	#ifdef DEBUG
		[LogManager log:@"Initialising api request manager" withLevel:LOG_INFO fromClass:@"DataManager"];
	#endif
	apiRequestManager = [[APIRequestManager alloc] init];
}

+ (void)deInitRequestManagers {
	#ifdef DEBUG
		[LogManager log:@"DeInitialising request managers" withLevel:LOG_INFO fromClass:@"DataManager"];
	#endif
	[databaseRequestManager release];
	[apiRequestManager release];
}

+ (NSArray*)fetchLastPurchasedRecipes: (NSInteger)count {
	return [databaseRequestManager fetchLastPurchasedRecipes:count];
}

+ (NSString*)fetchUserPreference: (NSString*) key {
	return [databaseRequestManager fetchUserPreference:key];
}

+ (NSString*)fetchUserDocumentsPath {
	//Search for standard documents using NSSearchPathForDirectoriesInDomains
	//First Param = Searching the documents directory
	//Second Param = Searching the Users directory and not the System
	//Expand any tildes and identify home directories.
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

+ (BOOL)fileExistsInUserDocuments: (NSString*) fileName {
	NSString *processedPath = [[DataManager fetchUserDocumentsPath] stringByAppendingPathComponent:fileName];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	return [fileManager fileExistsAtPath:processedPath];
}

@end
