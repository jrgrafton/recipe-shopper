//
//  LoginManager.h
//  RecipeShopper
//
//  Created by Simon Barnett on 23/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataManager;

@interface LoginManager : NSObject <UIAlertViewDelegate> {
	NSString *loginName;
	
@private 
	DataManager *dataManager;
}

@property (nonatomic, retain) NSString *loginName;

- (void)requestLoginToStore;

@end