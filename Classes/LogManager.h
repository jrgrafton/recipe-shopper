//
//  LogManager.h
//  RecipeShopper
//
//  Created by James Grafton on 5/21/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define DEBUG

typedef enum LogLevel
{
	LOG_INFO,
	LOG_WARNING,
	LOG_ERROR
} LogLevel;

@interface LogManager : NSObject {

}

+ (void)log: (NSString*) msg withLevel:(LogLevel)level fromClass:(NSString*) className;

@end
