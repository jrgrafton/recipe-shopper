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

@interface HTTPRequestManager ()
//Private class functions
-(NSData*)httpGetRequest:(NSString*)requestUrl;
-(NSNumber*)getDistanceInMilesBetween:(CLLocationCoordinate2D)point1 andPoint:(CLLocationCoordinate2D)point2;
@end

@implementation HTTPRequestManager


- (id)init {
	if (self = [super init]) {
		//Initialisation code
	}
	return self;
}

- (NSArray*)fetchClosestStores: (NSArray*)latitudeLongitude andReturnUpToThisMany:(NSInteger) count {
	NSString *requestString = [NSString stringWithFormat:@"http://www.tesco.com/storelocator/sf.asp?Lat=%f&Lng=%f&Rad=0.10&storeType=all",[[latitudeLongitude objectAtIndex:0] doubleValue],[[latitudeLongitude objectAtIndex:1] doubleValue]];
	
	NSData *data = [self httpGetRequest:requestString];	
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	//Have to correct return data so its valid JSON
	NSMutableString* jsonString = [[dataString componentsSeparatedByString: @"["] objectAtIndex:1];
	jsonString = [[jsonString componentsSeparatedByString: @"]"] objectAtIndex:0];
	jsonString = [NSString stringWithFormat:@"[%@]",jsonString];
	
	
	SBJSON *parser = [[SBJSON alloc] init];
	NSError *error = nil;
	NSArray *stores = [parser objectWithString:jsonString error:&error];
	
	if(error != nil){
		NSString *msg = [NSString stringWithFormat:@"error parsing JSON: '%@'.",[error localizedDescription]];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"HTTPRequestManager"];
	}
	
	for (NSDictionary *ajaxStore in stores)
	{
		NSInteger storeID = [[ajaxStore objectForKey:@"bID"] integerValue];
		if (storeID == 0){continue;} // 0 entry always sent first
		
		NSString *storeName = [ajaxStore objectForKey:@"placeName"];		
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
		
		HTTPStore *store = [[HTTPStore alloc] initWithStoreID:storeID andStoreName:storeName
								andStoreType:storeType andStoreDistanceFromCurrentLocation:storeDistanceFromCurrentLocation
								andStoreLatitude:storeLatitude andStoreLongitude:storeLongitude];
		
		NSLog(@"Built store object %@",store);
	}
	
	
	[parser release];
	return [NSMutableArray array];
}

-(NSData*)httpGetRequest:(NSString*)requestUrl {
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
