//
//  LoadingView.h
//  LoadingView
//
//  Created by Matt Gallagher on 12/04/09.
//  Copyright Matt Gallagher 2009. All rights reserved.
//	Enhancements by Assentec Global on 10/05/2010
//	Copyright AET 2010. All rights reserved.
// 
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView
{
	NSInteger cornerRadius;
	UIColor *viewBackgroundColor;
	BOOL drawStroke;
}

@property (nonatomic,assign)NSInteger cornerRadius;
@property (nonatomic,assign)BOOL drawStroke;
@property (nonatomic,retain)UIColor *viewBackgroundColor;


+ (id)loadingViewInView:(UIView *)inASuperview withText:(NSString*)inText andFont:(UIFont*)inFont 
		   andFontColor:(UIColor*)inFontColour andCornerRadius:(NSInteger)inCornerRadius
		   andBackgroundColor:(UIColor*)inBackgroundColor andDrawStroke:(BOOL)inDrawStroke;
+ (void)updateCurrentLoadingViewLoadingText:(NSString*)loadingText;
+ (void)updateCurrentLoadingViewProgressText:(NSString*)progressText;
- (void)removeView;

@end