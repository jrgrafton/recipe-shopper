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

@end
