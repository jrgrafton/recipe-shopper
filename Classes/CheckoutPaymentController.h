//
//  CheckoutPaymentController.h
//  RecipeShopper
//
//  Created by User on 8/10/10.
//  Copyright 2010 Assent Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CheckoutPaymentController : UIViewController <UIWebViewDelegate>{
	IBOutlet UIWebView *webView;
	
	@private
	NSURLRequest *recipeHtmlPage;
}


- (void)loadPaymentPageAndNotify:(id <UIWebViewDelegate>) webViewDelegate;

@end
