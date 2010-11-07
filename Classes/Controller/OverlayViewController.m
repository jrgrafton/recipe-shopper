//
//  OverlayViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 20/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "OverlayViewController.h"

@implementation OverlayViewController

@synthesize overlayLabel;
@synthesize overlayLoadingLabel;

- (void)showOverlayView:(UIView *)superView {
	[superView addSubview:[self view]];
	[self setOverlayViewOffset:CGPointMake(0.0, 20.0)];
	[self setOverlayLabelText:@""];
	[self setOverlayLoadingLabelText:@""];
}

- (void)hideOverlayView {
	[[self view] removeFromSuperview];
}

- (void)showActivityIndicator {
	[overlayIndicator startAnimating];
}

- (void)hideActivityIndicator {
	/* activity indicator is set to hide when its stopped animating */
	[overlayIndicator stopAnimating];
}

- (void)setOverlayViewOffset:(CGPoint)contentOffset {
	CGRect viewFrame = CGRectMake(contentOffset.x, contentOffset.y, [[self view] frame].size.width, [[self view] frame].size.height);
	[[self view] setFrame:viewFrame];
}

- (void)setOverlayLabelText:(NSString *)text {
	[overlayLabel setText:text];
}

- (void)setOverlayLoadingLabelText:(NSString *)text {
	[overlayLoadingLabel setText:text];
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
