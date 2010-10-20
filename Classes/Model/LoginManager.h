//
//  LoginManager.h
//  RecipeShopper
//
//  Created by Simon Barnett on 23/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LoginManager : NSObject <UIAlertViewDelegate> {

}

@property (nonatomic, retain) NSString *loginName;

- (void)requestLoginToStore;

@end