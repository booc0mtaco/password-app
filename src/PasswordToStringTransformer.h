//
//  PasswordToStringTransformer.h
//  Password
//
//  Created by Andrew Holloway on 2010-01-23.
//

#import <Cocoa/Cocoa.h>

@interface PasswordToStringTransformer : NSValueTransformer {
	NSString *cryptTransformerKey;
}

+(PasswordToStringTransformer *)valueTransformerForName:(NSString *)aName;
- (NSString *) cryptTransformerKey;
- (void) setCryptTransformerKey:(NSString *)toValue;

@end
