//
//  CommonSpecificRecipeViewController.h
//  RecipeShopper
//
//  Created by James Grafton on 5/24/10.
//  Copyright 2010 Assentec Global. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DBRecipe.h"


@interface CommonSpecificRecipeViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
	IBOutlet UIImageView *imageFadeView;
	DBRecipe *currentRecipe;
	
	@private
	NSURLRequest *recipeHtmlPage;
}


@property (nonatomic,retain) NSURLRequest *recipeHtmlPage;
@property (nonatomic,retain) DBRecipe *currentRecipe;
@property (nonatomic,assign) BOOL initialised;

- (void)processViewForRecipe:(DBRecipe*)recipe withWebViewDelegate:(id <UIWebViewDelegate>) webViewDelegate;

@end
