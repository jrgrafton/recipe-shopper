//
//  OverlayViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 20/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OverlayViewController : UIViewController {
	IBOutlet UIActivityIndicatorView *overlayIndicator;
}

@property (nonatomic, retain) IBOutlet UILabel *overlayLabel;

- (void)showOverlayView:(UIView *)superView;
- (void)hideOverlayView;
- (void)setOverlayViewOffset:(CGPoint)contentOffset;
- (void)showActivityIndicator;
- (void)hideActivityIndicator;
- (void)setOverlayLabelText:(NSString *)text;

@end
