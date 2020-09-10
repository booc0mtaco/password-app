//
//  StringToAttributedStringTransformer.m
//  Password
//
//  Created by Andrew Holloway on 2010-01-10.
//

#import "StringToAttributedStringTransformer.h"

// http://lists.apple.com/archives/cocoa-dev/2007/Jul/msg01483.html

@implementation StringToAttributedStringTransformer
+ (Class)transformedValueClass
{
	return [NSAttributedString class];
}

+ (BOOL)allowsReverseTransformation
{
	return YES;
}

- (id)transformedValue:(id)value
{
	if (value == nil)
		return nil;
	
	NSAttributedString *attribString = [[NSAttributedString alloc] initWithString:(NSString*)value];
	return attribString;
}

- (id)reverseTransformedValue:(id)value
{
	if (value == nil)
		return nil;
	
	return [(NSAttributedString*)value string];
}
@end
