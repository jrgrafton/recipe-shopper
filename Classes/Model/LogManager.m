//
//  LogManager.m
//  RecipeShopper
//
//  Created by Simon Barnett on 11/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "LogManager.h"

@implementation LogManager

+ (void)log:(NSString *)msg withLevel:(LogLevel)level fromClass:(NSString *)className {
#ifdef OUTPUT_DEBUG
	
	NSString* levelStr = @"";
	
	switch (level) {
		case LOG_INFO:
			levelStr = @"Info:";
			break;
		case LOG_WARNING:
			levelStr = @"Warning:";
			break;
		case LOG_ERROR:
			levelStr = @"Error:";
			break;
		default:
			levelStr = @"Unknown:";
			break;
	}
	

	NSLog(@"[%@]%@ %@", className, levelStr, msg);
#endif
}

@end
