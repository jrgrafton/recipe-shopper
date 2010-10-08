//
//  RecipeViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 05/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recipe.h"

@interface RecipeViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
	IBOutlet UIImageView *imageFadeView;
	Recipe *currentRecipe;
}

@property (nonatomic,retain) Recipe *currentRecipe;

- (void)processViewForRecipe:(Recipe *)recipe withWebViewDelegate:(id <UIWebViewDelegate>)webViewDelegate;

@end
