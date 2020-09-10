//
//  PasswordArrayController.m
//  Password
//
//  Created by Andrew Holloway on 2010-01-10.
//

#import "PasswordArrayController.h"


@implementation PasswordArrayController

- (id)newObject
{
	// Cocoa Programming for Mac OS X - p181
	// Set the initial creation date when adding a new object 
	id newObj = [super newObject];
	NSDate *now = [NSDate date];
	
	[newObj setValue:now forKey:@"createDate"];
	return newObj;
}

// Add a method for when you edit a password
	
@end
