//
//  NSData-Extended.m
//  RecipeShopper
//
//  Created by James Grafton on 5/23/10.
//  Copyright 2010 Assentec Global. All rights reserved.
//
//  Extends the NSData class allowing us to create an NSData object from
//  a base64 encoded NSString

#import "NSData-Extended.h"

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation NSData(MBBase64)

+ (NSData *)dataWithBase64EncodedString:(NSString *)string;
{
	if (string == nil) {
		[NSException raise:NSInvalidArgumentException format:@"%s"];
	}
	
	if ([string length] == 0) {
		return [NSData data];
	}
	
	static char *decodingTable = NULL;
	
	if (decodingTable == NULL) {
		decodingTable = malloc(256);
		
		if (decodingTable == NULL) {
			return nil;
		}
		
		memset(decodingTable, CHAR_MAX, 256);
		NSUInteger i;
		
		for (i = 0; i < 64; i++) {
			decodingTable[(short)encodingTable[i]] = i;
		}
	}
	
	const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
	
	if (characters == NULL) {    //  Not an ASCII string!
		return nil;
	}
	
	char *bytes = malloc((([string length] + 3) / 4) * 3);
	
	if (bytes == NULL) {
		return nil;
	}
	
	NSUInteger length = 0;
	NSUInteger i = 0;
	
	while (YES) {
		char buffer[4];
		short bufferLength;
		
		for (bufferLength = 0; bufferLength < 4; i++) {
			if (characters[i] == '\0') {
				break;
			}
			
			if (isspace(characters[i]) || characters[i] == '=') {
				continue;
			}
			
			buffer[bufferLength] = decodingTable[(short)characters[i]];
			
			if (buffer[bufferLength++] == CHAR_MAX) {     //  Illegal character!
				free(bytes);
				return nil;
			}
		}
		
		if (bufferLength == 0) {
			break;
		}
		
		if (bufferLength == 1) {     //  At least two characters are needed to produce one byte!
			free(bytes);
			return nil;
		}
		
		// Decode the characters in the buffer to bytes.
		bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
		
		if (bufferLength > 2) {
			bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
		}
		
		if (bufferLength > 3) {
			bytes[length++] = (buffer[2] << 6) | buffer[3];
		}
	}
	
	realloc(bytes, length);
	return [NSData dataWithBytesNoCopy:bytes length:length];
}

@end