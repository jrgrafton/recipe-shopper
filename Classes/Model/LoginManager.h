//
//  LoginManager.h
//  RecipeShopper
//
//  Created by Simon Barnett on 23/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataManager.h"

@interface LoginManager : NSObject <UIAlertViewDelegate> {
@private 
	DataManager *dataManager;
}

@property (nonatomic, retain) NSString *loginName;

- (void)requestLoginToStore;

@end