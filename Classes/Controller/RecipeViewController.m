//
//  RecipeViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 05/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "RecipeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RecipeShopperAppDelegate.h"

@interface RecipeViewController()

- (NSString *)createRecipeHtml:(Recipe *)recipe withCssFile:(NSString *)cssFile;
- (NSString *)createRecipeCss:(Recipe *)recipe;
- (NSString *)replaceTokens:(NSString *)originalText tokenToReplace:(NSString *)token withText:(NSString *)replacementText;

@end

@implementation RecipeViewController

@synthesize currentRecipe;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		dataManager = [DataManager getInstance];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *userDocsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES) objectAtIndex:0];
		
		NSString *documentsImgPath = [userDocsPath stringByAppendingPathComponent:@"imgs"];
		
		if ([fileManager fileExistsAtPath:documentsImgPath] == NO) {
			NSError *error;
			NSBundle *bundle = [NSBundle mainBundle];
			NSString *localImagePath = [bundle pathForResource:@"imgs" ofType:nil];
			[fileManager copyItemAtPath:localImagePath toPath:documentsImgPath error:&error];
		}		
    }
	
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Add logo to nav bar
	UIImage *image = [UIImage imageNamed: @"header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	/* round recipe view corners */
	webView.layer.masksToBounds = YES;
	webView.layer.cornerRadius = 5;
	
	/* round fade image corners */
	imageFadeView.layer.masksToBounds = YES;
	imageFadeView.layer.cornerRadius = 5;
	
	/* change background color */
	webView.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	/* switch delegate back to us so we can intercept links */
	[webView setDelegate:self];
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

/* 
 * Intercept links (add recipe to basket links) clicked from webview (recipe view)
 */
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSUInteger locationOfLink = [[[request URL] absoluteString] rangeOfString:@"_addtocart_"].location;
	
	if (locationOfLink != NSNotFound) {
		/* add the current recipe to the basket and to the recipe history */
		[dataManager addRecipeToBasket:currentRecipe];

		UIAlertView *recipeAlert = [[UIAlertView alloc] initWithTitle:@"Add recipe" message:@"Recipe successfully added to recipe basket" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[recipeAlert show];
		[recipeAlert release];
	}
	
	return YES;
}

- (void)processViewForRecipe:(Recipe *)recipe withWebViewDelegate:(id <UIWebViewDelegate>)webViewDelegate {
	/* release previous recipe */
	if ([self currentRecipe] != nil) {
		[currentRecipe release];
		currentRecipe = nil;
	}
	
	/* set current recipe */
	[self setCurrentRecipe:recipe];
	
	/* now get the extended data for this recipe (only get this when we actually want to display it) */
	[dataManager fetchExtendedDataForRecipe:currentRecipe];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *userDocsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	
	NSString *recipeHtmlFile = [userDocsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.html", [recipe recipeID]]];
	NSString *recipeCssFile = [userDocsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.css", [recipe recipeID]]];
	
	if (([fileManager fileExistsAtPath:recipeHtmlFile] == NO) || ([fileManager fileExistsAtPath:recipeCssFile] == NO)) {
		/* we don't have the HTML or CSS for this recipe yet, so create it and write it to file now */
		[[self createRecipeHtml:recipe withCssFile:recipeCssFile] writeToFile:recipeHtmlFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
		[[self createRecipeCss:recipe] writeToFile:recipeCssFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
	}

	/* set delegate so that it can only start transition when webview has finished loading */
	[webView setDelegate:webViewDelegate];
	
	/* load recipe page */
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:recipeHtmlFile]]];
}

- (NSString *)createRecipeHtml:(Recipe *)recipe withCssFile:(NSString *)cssFile {
	NSString *recipeHtml = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"recipe_base" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];	
	
	/* css link in the HTML for this recipe */
	recipeHtml = [recipeHtml stringByReplacingOccurrencesOfString:@"{css}" withString:cssFile];
	
	/* recipe title (also gets rid of the "Recipe for" parts of any title) */
	recipeHtml = [recipeHtml stringByReplacingOccurrencesOfString:@"{title}" withString:[[recipe recipeName] stringByReplacingOccurrencesOfString:@"Recipe for" withString:@"" 
																					options:NSCaseInsensitiveSearch range:NSMakeRange(0, [[recipe recipeName] length])]];
	
	/* recipe description */
	if ([recipe recipeDescription] != nil) {
		recipeHtml = [self replaceTokens:recipeHtml tokenToReplace:@"{description}" withText:[recipe recipeDescription]];
	}
	
	/* recipe nutritional info */
	NSArray *nutritionalInfo = [recipe nutritionalInfo];
	
	if ([nutritionalInfo count] != 0) {
		NSArray *nutritionalInfoPercent = [recipe nutritionalInfoPercent];
		
		recipeHtml = [recipeHtml stringByReplacingOccurrencesOfString:@"{calories}" withString:[nutritionalInfo objectAtIndex:0]];
		recipeHtml = [recipeHtml stringByReplacingOccurrencesOfString:@"{sugar}" withString:[nutritionalInfo objectAtIndex:1]];
		recipeHtml = [recipeHtml stringByReplacingOccurrencesOfString:@"{fat}" withString:[nutritionalInfo objectAtIndex:2]];
		recipeHtml = [recipeHtml stringByReplacingOccurrencesOfString:@"{saturatedfat}" withString:[nutritionalInfo objectAtIndex:3]];
		recipeHtml = [recipeHtml stringByReplacingOccurrencesOfString:@"{salt}" withString:[nutritionalInfo objectAtIndex:4]];
		
		recipeHtml = [recipeHtml stringByReplacingOccurrencesOfString:@"{calories%}" withString:[nutritionalInfoPercent objectAtIndex:0]];
		recipeHtml = [recipeHtml stringByReplacingOccurrencesOfString:@"{sugar%}" withString:[nutritionalInfoPercent objectAtIndex:1]];
		recipeHtml = [recipeHtml stringByReplacingOccurrencesOfString:@"{fat%}" withString:[nutritionalInfoPercent objectAtIndex:2]];
		recipeHtml = [recipeHtml stringByReplacingOccurrencesOfString:@"{saturatedfat%}" withString:[nutritionalInfoPercent objectAtIndex:3]];
		recipeHtml = [recipeHtml stringByReplacingOccurrencesOfString:@"{salt%}" withString:[nutritionalInfoPercent objectAtIndex:4]];
	}
	
	/* serves */
	if ([recipe serves] != nil) {
		recipeHtml = [self replaceTokens:recipeHtml tokenToReplace:@"{serves}" withText:[recipe serves]];
	}
	
	/* recipe preparation time */
	if ([recipe preparationTime] != nil) {
		recipeHtml = [self replaceTokens:recipeHtml tokenToReplace:@"{preparationtime}" withText:[recipe preparationTime]];
	}
	
	/* recipe cooking time */
	if ([recipe cookingTime] != nil) {
		recipeHtml = [self replaceTokens:recipeHtml tokenToReplace:@"{cookingtime}" withText:[recipe cookingTime]];
	}
	
	/* recipe contributor */
	if ([recipe contributor] != nil) {
		recipeHtml = [self replaceTokens:recipeHtml tokenToReplace:@"{contributor}" withText:[recipe contributor]];
	}
	
	/* recipe instructions */
	NSEnumerator *instructionsEnumerator = [[recipe instructions] objectEnumerator];
	NSString *instructionsList = @"";
	NSString *instruction;
	
	while ((instruction = [instructionsEnumerator nextObject])) {
		instructionsList = [instructionsList stringByAppendingFormat:@"<li>%@</li>", instruction];
	}
	
	recipeHtml = [recipeHtml stringByReplacingOccurrencesOfString:@"{method}" withString:instructionsList];
	
	/* recipe ingredients */
	NSEnumerator *ingredientsEnumerator = [[recipe textIngredients] objectEnumerator];
	NSString *ingredientsList = @"";
	NSString *ingredient;
	
	while ((ingredient = [ingredientsEnumerator nextObject])) {
		ingredientsList = [ingredientsList stringByAppendingFormat:@"<li>%@</li>", ingredient];
	}
	
	recipeHtml = [recipeHtml stringByReplacingOccurrencesOfString:@"{ingredients}" withString:ingredientsList];
	
	/* do the recipe image last to keep string small as possible for each replace as its in raw format */
	recipeHtml = [recipeHtml stringByReplacingOccurrencesOfString:@"{image}" withString:[recipe largeRecipeImageRaw]];
	
	return recipeHtml;
}

- (NSString *)createRecipeCss:(Recipe *)recipe {
	NSString *recipeCss = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"recipe_base" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil];
	
	/* recipe description */
	if ([recipe recipeDescription] == nil) {
		recipeCss = [recipeCss stringByAppendingString:@"\n#description{display:none;}"];
	}
	
	/* recipe nutrition info */
	if ([[recipe nutritionalInfo] count] == 0) {
		recipeCss = [recipeCss stringByAppendingString:@"\ndiv.nutrition{display:none;}"];
	}
	
	/* serves */
	if ([recipe serves] == nil) {
		recipeCss = [recipeCss stringByAppendingString:@"\n#serves{display:none;}"];
	}
	
	/* recipe preparation time */
	if ([recipe preparationTime] == nil) {
		recipeCss = [recipeCss stringByAppendingString:@"\n#preptime{display:none;}"];
	}
	
	/* recipe cooking time */
	if ([recipe cookingTime] == nil) {
		recipeCss = [recipeCss stringByAppendingString:@"\n#cooktime{display:none;}"];
	}
	
	/* recipe contributor */
	if ([recipe contributor] == nil) {
		recipeCss = [recipeCss stringByAppendingString:@"\n#contributor{display:none;}"];
	}
	
	return recipeCss;
}

- (NSString *)replaceTokens:(NSString *)originalText tokenToReplace:(NSString *)token withText:(NSString *)replacementText {
	return [originalText stringByReplacingOccurrencesOfString:token withString:replacementText];
}
	
- (void)dealloc {
    [super dealloc];
}


@end
