//
//  PasswordToStringTransformer.m
//  Password
//
//  Created by Andrew Holloway on 2010-01-23.
//

#import "PasswordToStringTransformer.h"
#import "DataEncryption.h"

@implementation PasswordToStringTransformer


- (NSString *) cryptTransformerKey {
	return cryptTransformerKey;
}

- (void) setCryptTransformerKey:(NSString *)toValue {
	cryptTransformerKey = [[NSString alloc] initWithString:toValue];
}

+(PasswordToStringTransformer *)valueTransformerForName:(NSString *)aName
{
	return (PasswordToStringTransformer *) [super valueTransformerForName:aName];
}

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return YES;
}

// take data object, decode it, and return string
- (id)transformedValue:(id)value
{
	if (value == nil)
		return nil;
		
	NSMutableData *passwordData = [[NSMutableData alloc] initWithData:(NSData*)value];
	NSMutableData *decryptedData;
	
	// Take this mutable data object, and convert it
	decryptedData = [passwordData decryptWithKey:cryptTransformerKey];
	if (decryptedData != nil) {
		NSString *stringValue = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
		return stringValue;
	} else {
		return nil;
	}

}

// Take string and encrypt it
- (id)reverseTransformedValue:(id)value
{
	if (value == nil)
		return nil;
		
	NSMutableData *data;
	data = [NSMutableData dataWithBytes:[(NSString*)value cStringUsingEncoding:NSUTF8StringEncoding] length:[(NSString*)value length]];
	
	// Take this mutable data object, and convert it
	NSMutableData *encryptedData = [data encryptWithKey:cryptTransformerKey];
	if (encryptedData != nil) {
		return encryptedData;
	} else {
		return nil;
	}
}

@end
