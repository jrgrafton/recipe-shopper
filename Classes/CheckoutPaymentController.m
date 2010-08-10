    //
//  CheckoutPaymentController.m
//  RecipeShopper
//
//  Created by User on 8/10/10.
//  Copyright 2010 Assent Software. All rights reserved.
//

#import "CheckoutPaymentController.h"
#import "DataManager.h"
#import "LogManager.h"

@interface CheckoutPaymentController ()
//Private class member functions
- (void) copyHtmlResourcesIfNeeded;
@end

@implementation CheckoutPaymentController


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		[self copyHtmlResourcesIfNeeded];
    }
    return self;
}

#pragma mark -
#pragma mark View Lifecycle Management

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	
	//Add Tesco logo to nav bar
	UIImage *image = [UIImage imageNamed: @"tesco_header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	
	//Set background colour
	[[self view] setBackgroundColor: [UIColor colorWithRed:0.8745098039215686 
													 green:0.9137254901960784 
													  blue:0.9568627450980392
													 alpha:1.0]];
}


#pragma mark -
#pragma mark UIWebViewDelegate Methods

/**
 Intercepts links clicked from webview
 */
- (BOOL)webView: (UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *url = request.URL;
	NSString *urlString = url.absoluteString;
	
	NSString *msg = [NSString stringWithFormat:@"Intercepting link ::: %@",urlString];
	[LogManager log:msg withLevel:LOG_INFO fromClass:@"CommonSpecificRecipeViewController"];
	
	
	return YES;
}

#pragma mark -
#pragma mark Additional Instance Functions
- (void)loadPaymentPageAndNotify:(id <UIWebViewDelegate>) webViewDelegate {
	//Set delegate so that it can only start transition when webview has finished loading
	[webView setDelegate:webViewDelegate];
	
	//Load page
	//[webView loadRequest:[self recipeHtmlPage]];
}

/**
 Copies over html imgs folder to user documents
 so we can cache generated webpages (if needed)
 Note; we need this here as well as in CommonSpecificRecipeViewController
 since that may not have been instantiated at this point...method needs abstracting
 */
- (void) copyHtmlResourcesIfNeeded {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSString *localImgPath = [[NSBundle mainBundle] pathForResource:@"imgs" ofType:nil];
	NSString *documentsImgPath = [[DataManager fetchUserDocumentsPath] stringByAppendingPathComponent:@"imgs"];
	
	//Always copy resources in DEBUG mode
	#ifdef DEBUG
	if ([fileManager fileExistsAtPath:documentsImgPath]){
		[fileManager removeItemAtPath:documentsImgPath error:nil];
	}
	#endif
	
	if (![DataManager fileExistsInUserDocuments:@"imgs"]){
		NSString* msg = [NSString stringWithFormat: @"Copying HTML imgs folder from %@ to %@",localImgPath,documentsImgPath];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"CommonSpecificRecipeViewController"];
		
		if (![fileManager copyItemAtPath:localImgPath toPath:documentsImgPath error:&error]){
			NSString *msg = [NSString stringWithFormat:@"error copying html resources: '%@'.",[error localizedDescription]];
			[LogManager log:msg withLevel:LOG_ERROR fromClass:@"CommonSpecificRecipeViewController"];
		}
	}
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [super dealloc];
}


@end
