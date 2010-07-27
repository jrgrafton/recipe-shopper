//
//  HTTPRequestManager.m
//  RecipeShopper
//
//  Created by James Grafton on 6/1/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "HTTPRequestManager.h"
#import "JSON.h"
#import "LogManager.h"
#import "HTTPStore.h"

#define EARTH_CIRCUMFERENCE_MILES 3963.191f
#define RADIANS( degrees ) ( degrees * M_PI / 180 )
#define GOOGLE_API_KEY @"ABQIAAAAYyJAuA-AaL8uU8P56nH3RxSfbtjM8DeObkTp7Rs4WF9j6r0wUBTPe63lCt7ztMy_ZHkisNnrvl-75w"

@interface HTTPRequestManager ()
//Private class functions
-(NSData *)httpGetRequest:(NSString*)requestUrl;
-(NSNumber *)getDistanceInMilesBetween:(CLLocationCoordinate2D)point1 andPoint:(CLLocationCoordinate2D)point2;
-(NSString *)urlEncodeValue:(NSString *)string;
-(NSArray *)getJSONForRequest:(NSString*)requestString andFixTescoResponse:(BOOL)fixResponse;
@end

@implementation HTTPRequestManager


- (id)init {
	if (self = [super init]) {
		//Initialisation code
	}
	return self;
}

-(NSString *) urlEncodeValue:(NSString*)requestString{
	CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(
																	NULL,
																	(CFStringRef)requestString,
																	NULL,
																	(CFStringRef)@"!*'\"();@+$,%#[]% ",
																	kCFStringEncodingUTF8 );
    return [(NSString *)urlString autorelease];
}


-(NSArray *)getJSONForRequest:(NSString*)requestString andFixTescoResponse:(BOOL)fixResponse{
	NSData *data = [self httpGetRequest:requestString];	
	NSString *dataString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
	if([dataString length] == 0 || [dataString rangeOfString:@"["].location == NSNotFound || [dataString rangeOfString:@"]"].location == NSNotFound){
		[LogManager log:@"Request fetched no/invalid results" withLevel:LOG_INFO fromClass:@"HTTPRequestManager"];
		return [NSArray array];
	}
	
	NSMutableString* jsonString = [NSMutableString stringWithFormat:@"%@", dataString];
	
	if(fixResponse){
		//Tesco website gives us back invalid JSON!!
		jsonString = [[dataString componentsSeparatedByString: @"["] objectAtIndex:1];
		jsonString = [[jsonString componentsSeparatedByString: @"]"] objectAtIndex:0];
		jsonString = [NSString stringWithFormat:@"[%@]",jsonString];
	}
	
	
	SBJSON *parser = [[SBJSON alloc] init];
	NSError *error = nil;
	NSArray *results = [parser objectWithString:jsonString allowScalar:TRUE error:&error];
	
	if(error != nil){
		NSString *msg = [NSString stringWithFormat:@"error parsing JSON: '%@'.",[error localizedDescription]];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"HTTPRequestManager"];
		results = [NSArray array];
	}
	
	//Always release alloc'd objects
	[parser release];
	
	return results;
}

- (NSArray*)fetchGeolocationFromAddress: (NSString*)address {
	NSMutableArray *latitudeLongitude = [NSMutableArray array];
	NSString *requestString = [NSString stringWithFormat: @"http://maps.google.com/maps/geo?q=%@&output=csv&oe=utf8&sensor=true_or_false&key=%@",address,GOOGLE_API_KEY];
	
	NSData *data = [self httpGetRequest:requestString];	
	NSString *result = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];

	if ([result length] != 0){
		NSArray *parts = [result componentsSeparatedByString: @","];
		
		NSNumber *latitude = [NSNumber numberWithDouble:[[parts objectAtIndex:([parts count] -2)] doubleValue]];
		NSNumber *longitude = [NSNumber numberWithDouble:[[parts objectAtIndex:([parts count] -1)] doubleValue]];
		
		if([latitude doubleValue] != 0 && [longitude doubleValue] != 0){
			[latitudeLongitude addObject:latitude];
			[latitudeLongitude addObject:longitude];
		}else{
		#ifdef DEBUG
			NSString *msg = [NSString stringWithFormat:@"Unable to find geoloc for address: '%@'.",address];
			[LogManager log:msg withLevel:LOG_INFO fromClass:@"HTTPRequestManager"];
		#endif
		}
	}
	
	return latitudeLongitude;
}

- (NSArray*)fetchClosestStoresToGeolocation: (NSArray*)latitudeLongitude andReturnUpToThisMany:(NSInteger) maxNumber {
	NSMutableArray *closestStores = [NSMutableArray array];
	
	NSString *requestString = [NSString stringWithFormat:@"http://www.tesco.com/storelocator/sf.asp?Lat=%f&Lng=%f&Rad=0.10&storeType=all",[[latitudeLongitude objectAtIndex:0] doubleValue],[[latitudeLongitude objectAtIndex:1] doubleValue]];
	NSArray *stores = [self getJSONForRequest:requestString andFixTescoResponse:TRUE];
	
	for (NSDictionary *ajaxStore in stores)
	{
		NSInteger storeID = [[ajaxStore objectForKey:@"bID"] integerValue];
		if (storeID == 0){continue;} // 0 entry always sent first
		
		NSString *storeName = [[ajaxStore objectForKey:@"placeName"] capitalizedString];		
		NSString *storeType = [ajaxStore objectForKey:@"typ"];
		NSNumber *storeLatitude = [NSNumber numberWithDouble:[[ajaxStore objectForKey:@"lat"] doubleValue]];
		NSNumber *storeLongitude = [NSNumber numberWithDouble:[[ajaxStore objectForKey:@"lng"] doubleValue]];
					   
		CLLocationCoordinate2D point1;
		point1.latitude = [[latitudeLongitude objectAtIndex:0] doubleValue];
		point1.longitude = [[latitudeLongitude objectAtIndex:1] doubleValue];
		CLLocationCoordinate2D point2;
		point2.latitude = [storeLatitude doubleValue];
		point2.longitude = [storeLongitude doubleValue];
		
		NSNumber *storeDistanceFromCurrentLocation = [self getDistanceInMilesBetween:point1 andPoint:point2];
		
		HTTPStore *store = [[[HTTPStore alloc] initWithStoreID:storeID andStoreName:storeName
								andStoreType:storeType andStoreDistanceFromCurrentLocation:storeDistanceFromCurrentLocation
								andStoreLatitude:storeLatitude andStoreLongitude:storeLongitude] autorelease];
		
		[closestStores addObject:store];		
	}
	
	//Sort array	
	[closestStores sortUsingSelector:@selector(compareByDistanceFromMyLocation:)];
	
	//Only return array size that we requested
	NSRange theRange;
	theRange.location = 0;
	theRange.length = ([closestStores count] > maxNumber)? maxNumber:[closestStores count];
	closestStores = [NSMutableArray arrayWithArray: [closestStores subarrayWithRange:theRange]];
	
	return [NSArray arrayWithArray: closestStores];
}

-(NSData*)httpGetRequest:(NSString*)requestUrl {
	//Ensure its fully URL encoded
	requestUrl = [self urlEncodeValue:requestUrl];
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];  
	[request setURL:[NSURL URLWithString:requestUrl]];
	[request setHTTPMethod:@"GET"];
#ifdef DEBUG
	NSString *msg = [NSString stringWithFormat:@"Sending request: '%@'.",requestUrl];
	[LogManager log:msg withLevel:LOG_INFO fromClass:@"HTTPRequestManager"];
#endif
	return [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
}

-(NSNumber*)getDistanceInMilesBetween:(CLLocationCoordinate2D)point1 andPoint:(CLLocationCoordinate2D)point2{
	double lat1 = point1.latitude;
	double lon1 = point1.longitude;
	
	double lat2 = point2.latitude;
	double lon2 = point2.longitude;
	
	double x = sin(lat1/57.295779) * sin(lat2/57.295779) + cos(lat1/57.295779) * cos(lat2/57.295779) * cos(lon2/57.295779 - lon1/57.295779);
	double a = EARTH_CIRCUMFERENCE_MILES * acos(x);
	
	//Only want single fraction digit
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setMaximumFractionDigits:1];
	NSString *answerString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:a]];
	[numberFormatter release];
	
	return [NSNumber numberWithDouble: [answerString doubleValue]];
}

@end
