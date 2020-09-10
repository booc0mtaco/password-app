//
//  DataEncryption.h
//  Password
//
//  Created by Andrew Holloway on 2010-01-23.
//

#import <Cocoa/Cocoa.h>

// I forgot what this is called, but we are extending the NSMutableData Class with two encryption subroutines
@interface NSMutableData (AES256)
- (NSMutableData*)encryptWithKey:(NSString*) key;
- (NSMutableData*)decryptWithKey:(NSString*) key;
@end
