//
//  CommonSpecificRecipeViewController.m
//  RecipeShopper
//
//  Created by James Grafton on 5/24/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "CommonSpecificRecipeViewController.h"
#import "LogManager.h"
#import "DataManager.h"

#define RDA_CALORIES 2000.0f
#define RDA_SUGAR 90.0f
#define RDA_FAT 70.0f
#define RDA_SAT_FAT 20.0f
#define RDA_SALT 6.0f

@interface CommonSpecificRecipeViewController ()
//Private class member functions
- (NSString*) replaceTokensInPage:(NSString*)templatePrefix forRecipe:(DBRecipe*)recipe;
- (void) copyHtmlResourcesIfNeeded;
@end

@implementation CommonSpecificRecipeViewController

@synthesize recipeHtmlPage,initialised;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
	//Not initialised until view did load completes!
	[self setInitialised:FALSE];
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Add Tesco logo to nav bar
	UIImage *image = [UIImage imageNamed: @"tesco_header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	
	//Set background colour
	[[self view] setBackgroundColor: [UIColor colorWithRed:0.8745098039215686 
													   green:0.9137254901960784 
														blue:0.9568627450980392
													   alpha:1.0]];
	//Round webview corners!
	webView.layer.masksToBounds = YES;
	webView.layer.cornerRadius = 5;
	
	//Round webview corners!
	imageFadeView.layer.masksToBounds = YES;
	imageFadeView.layer.cornerRadius = 5;
	
	//Change background color
	webView.backgroundColor = [UIColor whiteColor];
	
	//Intercept links!
	webView.delegate = self;
	
	//Copy Html resources if needed
	[self copyHtmlResourcesIfNeeded];
	
	//Finally load our recipe HTML page
	[webView loadRequest:[self recipeHtmlPage]];
	
	[self setInitialised: TRUE];
}

- (void)processViewForRecipe: (DBRecipe*)recipe {
	//Get template path
	NSString *templatePath = [self replaceTokensInPage: @"recipe_base" forRecipe:recipe];
	
	//NSURL *url = [NSURL fileURLWithPath:templatePath];
	NSURL *url = [NSURL fileURLWithPath:templatePath];
	
	#ifdef DEBUG
		NSString *msg = [NSString stringWithFormat:@"URL for html file %@",[url absoluteURL]];
		[LogManager log:msg withLevel:LOG_INFO fromClass:@"CommonSpecificRecipeViewController"];
	#endif
	
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[self setRecipeHtmlPage:request];
	
	if ( [self initialised] ){
		[webView loadRequest:[self recipeHtmlPage]];
	}
}

- (NSString*) replaceTokensInPage:(NSString*)templatePrefix forRecipe:(DBRecipe*)recipe {
	NSString *recipeHtmlName = [NSString stringWithFormat:@"%d.html",[recipe recipeID]];
	NSString *recipeCssName = [NSString stringWithFormat:@"%d.css",[recipe recipeID]];
	
	#ifndef DEBUG
	if ([DataManager fileExistsInUserDocuments:recipeHtmlName] && [DataManager fileExistsInUserDocuments:recipeCssName]){
		//Return the path to the previously processed page
		return [[DataManager fetchUserDocumentsPath] stringByAppendingPathComponent:recipeHtmlName];
	}
	#endif
	
	//Load HTML from template process it, then output to Documents dir
	NSString *templateHtml = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:templatePrefix ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];	
	
	//Load HTML from template process it, then output to Documents dir
	NSString *templateCss = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:templatePrefix ofType:@"css"] encoding:NSUTF8StringEncoding error:nil];

	//Css link
	templateHtml = [templateHtml stringByReplacingOccurrencesOfString:@"{css}" withString:recipeCssName];
	
	//Title
	templateHtml = [templateHtml stringByReplacingOccurrencesOfString:@"{title}" withString:[recipe recipeName]];
	
	//Description
	if ([recipe description] != nil) {
		templateHtml = [templateHtml stringByReplacingOccurrencesOfString:@"{description}" withString:[recipe description]];
	}else{
		templateCss = [templateCss stringByAppendingString:@"\n#description{display:none;}"];
	}
	
	//Nutritional info
	NSArray *nutritionalInfo = [recipe nutritionalInfo];
	NSArray *nutritionalInfoPercent = [recipe nutritionalInfoPercent];
	if ([nutritionalInfo count] != 0) {
		NSString *calories = [nutritionalInfo objectAtIndex:0];
		NSString *caloriesPercent = [nutritionalInfoPercent objectAtIndex:0];
		NSString *sugar = [nutritionalInfo objectAtIndex:1];
		NSString *sugarPercent = [nutritionalInfoPercent objectAtIndex:1];
		NSString *fat = [nutritionalInfo objectAtIndex:2];
		NSString *fatPercent = [nutritionalInfoPercent objectAtIndex:2];
		NSString *saturatedFat = [nutritionalInfo objectAtIndex:3];
		NSString *saturatedFatPercent = [nutritionalInfoPercent objectAtIndex:3];
		NSString *salt = [nutritionalInfo objectAtIndex:4];
		NSString *saltPercent = [nutritionalInfoPercent objectAtIndex:4];
		
		templateHtml = [templateHtml stringByReplacingOccurrencesOfString:@"{calories}" withString:calories];
		templateHtml = [templateHtml stringByReplacingOccurrencesOfString:@"{sugar}" withString:sugar];
		templateHtml = [templateHtml stringByReplacingOccurrencesOfString:@"{fat}" withString:fat];
		templateHtml = [templateHtml stringByReplacingOccurrencesOfString:@"{saturatedfat}" withString:saturatedFat];
		templateHtml = [templateHtml stringByReplacingOccurrencesOfString:@"{salt}" withString:salt];
		
		templateHtml = [templateHtml stringByReplacingOccurrencesOfString:@"{calories%}" withString:caloriesPercent];
		templateHtml = [templateHtml stringByReplacingOccurrencesOfString:@"{sugar%}" withString:sugarPercent];
		templateHtml = [templateHtml stringByReplacingOccurrencesOfString:@"{fat%}" withString:fatPercent];
		templateHtml = [templateHtml stringByReplacingOccurrencesOfString:@"{saturatedfat%}" withString:saturatedFatPercent];
		templateHtml = [templateHtml stringByReplacingOccurrencesOfString:@"{salt%}" withString:saltPercent];
	}else{
		templateCss = [templateCss stringByAppendingString:@"\ndiv #nutrition{display:none;}"];
	}
	
	//Serves
	if ([recipe serves] != nil) {
		templateHtml = [templateHtml stringByReplacingOccurrencesOfString:@"{serves}" withString:[recipe serves]];
	}else{
		templateCss = [templateCss stringByAppendingString:@"\n#serves{display:none;}"];
	}
	
	//Preparation Time
	if ([recipe preparationTime] != nil) {
		templateHtml = [templateHtml stringByReplacingOccurrencesOfString:@"{preparationtime}" withString:[recipe preparationTime]];
	}else{
		templateCss = [templateCss stringByAppendingString:@"\n#preptime{display:none;}"];
	}
	
	//Cooking Time
	if ([recipe cookingTime] != nil) {
		templateHtml = [templateHtml stringByReplacingOccurrencesOfString:@"{cookingtime}" withString:[recipe cookingTime]];
	}else{
		templateCss = [templateCss stringByAppendingString:@"\n#cooktime{display:none;}"];
	}
	
	//Preparation Time
	if ([recipe contributor] != nil) {
		templateHtml = [templateHtml stringByReplacingOccurrencesOfString:@"{contributor}" withString:[recipe contributor]];
	}else{
		templateCss = [templateCss stringByAppendingString:@"\n#contributor{display:none;}"];
	}
	
	//Method
	NSArray *instructions = [recipe instructions];
	NSString *instructionsList = @""; 
	NSInteger i = [instructions count];
	NSInteger j = i - 1;
	while ( i-- ) {
		instructionsList = [instructionsList stringByAppendingFormat:@"<li>%@</li>",[instructions objectAtIndex:j - i]]; 
	}
	templateHtml = [templateHtml stringByReplacingOccurrencesOfString:@"{method}" withString:instructionsList];
	
	//Ingredients
	NSArray *ingredients = [recipe textIngredients];
	NSString *ingredientsList = @""; 
	i = [ingredients count];
	j = i - 1;
	while ( i-- ) {
		ingredientsList = [ingredientsList stringByAppendingFormat:@"<li>%@</li>",[ingredients objectAtIndex:j - i]]; 
	}
	templateHtml = [templateHtml stringByReplacingOccurrencesOfString:@"{ingredients}" withString:instructionsList];
	
	//Do image last to keep string small as possible for each replace!
	templateHtml = [templateHtml stringByReplacingOccurrencesOfString:@"{image}" withString:[recipe iconLargeRaw]];
	
	//Write file out
	NSString *htmlPath = [[DataManager fetchUserDocumentsPath] stringByAppendingPathComponent:recipeHtmlName];
	NSString *cssPath = [[DataManager fetchUserDocumentsPath] stringByAppendingPathComponent:recipeCssName];
	
	#ifdef DEBUG
		NSString *msg = [NSString stringWithFormat:@"Writing HTML to file %@", htmlPath];
		[LogManager log:msg withLevel:LOG_INFO fromClass:@"CommonSpecificRecipeViewController"];
	
		msg = [NSString stringWithFormat:@"Writing CSS to file %@", cssPath];
		[LogManager log:msg withLevel:LOG_INFO fromClass:@"CommonSpecificRecipeViewController"];
	#endif

	[templateHtml writeToFile:htmlPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	[templateCss writeToFile:cssPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	
	//Return path to newly generated file
	return htmlPath;
}

- (void) copyHtmlResourcesIfNeeded {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSString *localImgPath = [[NSBundle mainBundle] pathForResource:@"imgs" ofType:nil];
	NSString *documentsImgPath = [[DataManager fetchUserDocumentsPath] stringByAppendingPathComponent:@"imgs"];
	
	#ifdef DEBUG
		//Always copy resources in DEBUG mode
		if ([fileManager fileExistsAtPath:documentsImgPath]){
			[fileManager removeItemAtPath:documentsImgPath error:nil];
		}
	#endif
	if (![DataManager fileExistsInUserDocuments:@"imgs"]){		
		#ifdef DEBUG
			NSString* msg = [NSString stringWithFormat: @"Copying HTML imgs folder from %@ to %@",localImgPath,documentsImgPath];
			[LogManager log:msg withLevel:LOG_ERROR fromClass:@"CommonSpecificRecipeViewController"];
		#endif
		
		if (![fileManager copyItemAtPath:localImgPath toPath:documentsImgPath error:&error]){
			NSString *msg = [NSString stringWithFormat:@"error copying html resources: '%@'.",[error localizedDescription]];
			[LogManager log:msg withLevel:LOG_ERROR fromClass:@"CommonSpecificRecipeViewController"];
		}
	}
}

- (BOOL)webView: (UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *url = request.URL;
	NSString *urlString = url.absoluteString;
	#ifdef DEBUG
		NSString *msg = [NSString stringWithFormat:@"Intercepting link ::: %@",urlString];
		[LogManager log:msg withLevel:LOG_INFO fromClass:@"CommonSpecificRecipeViewController"];
	#endif
	return YES;
}

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

- (void)viewWillDisappear:(BOOL)animated {
	//Load blank page on exiting
	[webView loadHTMLString:@"" baseURL:nil];
	[LogManager log:@"VIEW UNLOADING" withLevel:LOG_INFO fromClass:@"CommonSpecificRecipeViewController"];
}

/*
- (void)viewDidUnload {

}*/


- (void)dealloc {
    [super dealloc];
}


@end
