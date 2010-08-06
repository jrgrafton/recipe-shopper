//
//  LogManager.m
//  RecipeShopper
//
//  Created by James Grafton on 5/21/10.
//  Copyright 2010 Assentec Global. All rights reserved.
//

#import "LogManager.h"

@implementation LogManager

+ (void)log: (NSString*) msg withLevel:(LogLevel)level fromClass:(NSString*) className {
	//Log level string
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
	
	//Output the log string
	NSLog(@"[%@]%@ %@",className,levelStr,msg);
}

@end
