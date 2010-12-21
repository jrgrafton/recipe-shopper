//
//  LogManager.h
//  RecipeShopper
//
//  Created by Simon Barnett on 11/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define OUTPUT_DEBUG

typedef enum LogLevel
{
	LOG_INFO,
	LOG_WARNING,
	LOG_ERROR
} LogLevel;


@interface LogManager : NSObject {

}

+ (void)log:(NSString *)msg withLevel:(LogLevel)level fromClass:(NSString *)className;

@end
