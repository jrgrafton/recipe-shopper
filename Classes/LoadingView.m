//
//  LoadingView.m
//  LoadingView
//
//  Created by Matt Gallagher on 12/04/09.
//  Copyright Matt Gallagher 2009. All rights reserved.
// 
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//
#import "LoadingView.h"
#import "RecipeShopperAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

static LoadingView *currentLoadingView = nil;

//
// NewPathWithRoundRect
//
// Creates a CGPathRect with a round rect of the given radius.
//
CGPathRef NewPathWithRoundRect(CGRect rect, CGFloat cornerRadius)
{
	//
	// Create the boundary path
	//
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL,
					  rect.origin.x,
					  rect.origin.y + rect.size.height - cornerRadius);
	
	// Top left corner
	CGPathAddArcToPoint(path, NULL,
						rect.origin.x,
						rect.origin.y,
						rect.origin.x + rect.size.width,
						rect.origin.y,
						cornerRadius);
	
	// Top right corner
	CGPathAddArcToPoint(path, NULL,
						rect.origin.x + rect.size.width,
						rect.origin.y,
						rect.origin.x + rect.size.width,
						rect.origin.y + rect.size.height,
						cornerRadius);
	
	// Bottom right corner
	CGPathAddArcToPoint(path, NULL,
						rect.origin.x + rect.size.width,
						rect.origin.y + rect.size.height,
						rect.origin.x,
						rect.origin.y + rect.size.height,
						cornerRadius);
	
	// Bottom left corner
	CGPathAddArcToPoint(path, NULL,
						rect.origin.x,
						rect.origin.y + rect.size.height,
						rect.origin.x,
						rect.origin.y,
						cornerRadius);
	
	// Close the path at the rounded rect
	CGPathCloseSubpath(path);
	
	return path;
}

@implementation LoadingView

@synthesize cornerRadius,viewBackgroundColor,drawStroke;
//
// loadingViewInView:
//
// Constructor for this view. Creates and adds a loading view for covering the
// provided aSuperview.
//
// Parameters:
//    aSuperview - the superview that will be covered by the loading view
//
// returns the constructed view, already added as a subview of the inASuperview
//	(and hence retained by the superview)
//
+ (id)loadingViewInView:(UIView *)inASuperview withText:(NSString*)inText andFont:(UIFont*)inFont 
		   andFontColor:(UIColor*)inFontColor andCornerRadius:(NSInteger)inCornerRadius
		   andBackgroundColor:(UIColor*)inViewBackgroundColor andDrawStroke:(BOOL)inDrawStroke;
{
	LoadingView *loadingView =
	[[[LoadingView alloc] initWithFrame:[[inASuperview superview] bounds]] autorelease];
	if (!loadingView)
	{
		return nil;
	}
	
	//Initialise private properties first
	[loadingView setCornerRadius:inCornerRadius];
	[loadingView setViewBackgroundColor:inViewBackgroundColor];
	[loadingView setDrawStroke:inDrawStroke];
	
	loadingView.opaque = NO;
	loadingView.autoresizingMask =
	UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[inASuperview addSubview:loadingView];
	
	//Add loading text label
	const CGFloat DEFAULT_LABEL_WIDTH = 280.0;
	const CGFloat DEFAULT_LABEL_HEIGHT = 50.0;
	CGRect loadingLabelFrame = CGRectMake(0, 0, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT);
	
	UILabel *loadingLabel =
	[[[UILabel alloc]
	  initWithFrame:loadingLabelFrame]
	 autorelease];
	loadingLabel.text = NSLocalizedString(inText, nil);
	loadingLabel.textColor = inFontColor;
	loadingLabel.backgroundColor = [UIColor clearColor];
	loadingLabel.textAlignment = UITextAlignmentCenter;
	loadingLabel.font = inFont;
	loadingLabel.autoresizingMask =
	UIViewAutoresizingFlexibleLeftMargin |
	UIViewAutoresizingFlexibleRightMargin |
	UIViewAutoresizingFlexibleTopMargin |
	UIViewAutoresizingFlexibleBottomMargin;
	[loadingView addSubview:loadingLabel];
	
	//Add loading spinner animation
	UIActivityIndicatorView *activityIndicatorView =
	[[[UIActivityIndicatorView alloc]
	  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]
	 autorelease];
	[loadingView addSubview:activityIndicatorView];
	
	
	activityIndicatorView.autoresizingMask =
	UIViewAutoresizingFlexibleLeftMargin |
	UIViewAutoresizingFlexibleRightMargin |
	UIViewAutoresizingFlexibleTopMargin |
	UIViewAutoresizingFlexibleBottomMargin;
	[activityIndicatorView startAnimating];
	
	//Add progress text label
	CGRect progressLabelFrame = CGRectMake(0, 0, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT);
	UILabel *progressLabel =
	[[[UILabel alloc]
	  initWithFrame:loadingLabelFrame]
	 autorelease];
	progressLabel.text = @"";
	progressLabel.textColor = inFontColor;
	progressLabel.backgroundColor = [UIColor clearColor];
	progressLabel.textAlignment = UITextAlignmentCenter;
	progressLabel.font = [UIFont fontWithName:[inFont fontName] size:[inFont pointSize]/1.5];
	progressLabel.autoresizingMask =
	UIViewAutoresizingFlexibleLeftMargin |
	UIViewAutoresizingFlexibleRightMargin |
	UIViewAutoresizingFlexibleTopMargin |
	UIViewAutoresizingFlexibleBottomMargin;
	[loadingView addSubview:progressLabel];
	
	//Total height of all components
	CGFloat totalHeight =
	loadingLabel.frame.size.height +
	activityIndicatorView.frame.size.height +
	progressLabel.frame.size.height;
	
	//Set layout for loading label
	loadingLabelFrame.origin.x = floor(0.5 * (loadingView.frame.size.width - DEFAULT_LABEL_WIDTH));
	loadingLabelFrame.origin.y = floor(0.5 * (loadingView.frame.size.height - totalHeight));
	loadingLabel.frame = loadingLabelFrame;
	
	//Set layout for spin animation
	CGRect activityIndicatorRect = activityIndicatorView.frame;
	activityIndicatorRect.origin.x =
	0.5 * (loadingView.frame.size.width - activityIndicatorRect.size.width);
	activityIndicatorRect.origin.y =
	loadingLabel.frame.origin.y + loadingLabel.frame.size.height;
	activityIndicatorView.frame = activityIndicatorRect;
	
	//Set layout for progress label
	progressLabelFrame.origin.x = floor(0.5 * (loadingView.frame.size.width - DEFAULT_LABEL_WIDTH));
	progressLabelFrame.origin.y = floor(0.5 * (loadingView.frame.size.height + activityIndicatorRect.size.height));
	progressLabel.frame = progressLabelFrame;
	
	// Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[inASuperview layer] addAnimation:animation forKey:@"layerAnimation"];
	
	currentLoadingView = loadingView;
	
	return loadingView;
}

+ (void)updateCurrentLoadingViewLoadingText:(NSString*)loadingText{
	if (currentLoadingView != nil) {
		UILabel * loadingLabel = [[currentLoadingView subviews] objectAtIndex:0];
		[loadingLabel setText:loadingText];
	}
}

+ (void)updateCurrentLoadingViewProgressText:(NSString*)progressText{
	if (currentLoadingView != nil) {
		UILabel * progressLabel = [[currentLoadingView subviews] objectAtIndex:2];
		[progressLabel setText:progressText];
	}
}

//
// removeView
//
// Animates the view out from the superview. As the view is removed from the
// superview, it will be released.
//
- (void)removeView
{
	UIView *aSuperview = [self superview];
	[super removeFromSuperview];
	
	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
}

//
// drawRect:
//
// Draw the view.
//
- (void)drawRect:(CGRect)rect
{
	rect.size.height -= 1;
	rect.size.width -= 1;
	
	const CGFloat RECT_PADDING = (cornerRadius == 0)? 0.0 : 1.0;
	rect = CGRectInset(rect, RECT_PADDING, RECT_PADDING);
	
	const CGFloat ROUND_RECT_CORNER_RADIUS = cornerRadius;
	CGPathRef roundRectPath = NewPathWithRoundRect(rect, ROUND_RECT_CORNER_RADIUS);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGColorRef color = [viewBackgroundColor CGColor];

	const CGFloat *components = CGColorGetComponents(color);
	CGFloat redComponent = components[0];
	CGFloat greenComponent = components[1];
	CGFloat blueComponent = components[2];
	CGFloat alphaComponent = components[3];	
	
	CGContextSetRGBFillColor(context, redComponent, greenComponent, blueComponent, alphaComponent);
	
	CGContextAddPath(context, roundRectPath);
	CGContextFillPath(context);
	
	if (cornerRadius != 0) {
		const CGFloat STROKE_OPACITY = 0.25;
		CGContextSetRGBStrokeColor(context, 1, 1, 1, STROKE_OPACITY);
		CGContextAddPath(context, roundRectPath);
		CGContextStrokePath(context);
	}
	
	CGPathRelease(roundRectPath);
}


//
// dealloc
//
// Release instance memory.
//
- (void)dealloc
{
    [super dealloc];
}

@end