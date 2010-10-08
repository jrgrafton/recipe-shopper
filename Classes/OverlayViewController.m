//
//  OverlayViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 20/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "OverlayViewController.h"
#import "RecipeShopperAppDelegate.h"

@implementation OverlayViewController

@synthesize overlayLabel;

- (void)showOverlayView {
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	UITabBarController *tabBarController = [appDelegate tabBarController];
	[[[tabBarController selectedViewController] view] addSubview:[self view]];
}

- (void)hideOverlayView {
	[overlayLabel setText:@""];
	[[self view] removeFromSuperview];
}

- (void)hideActivityIndicator {
	/* activity indicator is set to hide when its stopped animating */
	[overlayIndicator stopAnimating];
}

- (void)setOverlayLabelText:(NSString *)text {
	[overlayLabel setText:text];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	//[[appDelegate onlineShopViewController] overlayViewTouched];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
