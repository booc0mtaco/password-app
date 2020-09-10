//
//  DataEncryption.m
//  Password
//
//  Created by Andrew Holloway on 2010-01-23.
//

#import "DataEncryption.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSMutableData (AES256)
// Sourced from : http://iphonedevelopment.blogspot.com/2009/02/strong-encryption-for-cocoa-cocoa-touch.html
// with fixes from http://pastie.org/426530
- (NSMutableData*) encryptWithKey: (NSString *) key
{
	
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char * keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
	bzero( keyPtr, sizeof(keyPtr) ); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString: (char*)keyPtr maxLength: sizeof(keyPtr) encoding: NSUTF8StringEncoding];
	
	// Set the data length from the object in question
	NSUInteger dataLength = [self length];
	
	// For block ciphers, the output size will always be <= input size PLUS
	// THE SIZE OF ONE BLOCK. That's why we need to add that one block here
	size_t bufSize = dataLength + kCCBlockSizeAES128;
	void *buf = malloc(bufSize);
	
	size_t numBytesEncrypted = 0;
	CCCryptorStatus result = CCCrypt( kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, 
									 keyPtr, kCCKeySizeAES256,
									 NULL /* initialization vector (optional) */, 
									 [self mutableBytes], dataLength, /* input */
									 buf, bufSize, /* output */
									 &numBytesEncrypted );
	if (result == kCCParamError) {
		NSLog(@"Param error");
	} else if (result== kCCDecodeError) {
		NSLog(@"Decode error");
	} else if (result== kCCBufferTooSmall) {
        // This is OK; means the password hasn't been set yet
		//NSLog(@"buffer too small error");
	}	
	
	if (result == kCCSuccess)
		return [NSMutableData dataWithBytesNoCopy:buf length:numBytesEncrypted];
	
	free(buf);
	return nil;
}

- (NSMutableData*) decryptWithKey: (NSString *) key
{	
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char * keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
	bzero( keyPtr, sizeof(keyPtr) ); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString: (char*)keyPtr maxLength: sizeof(keyPtr) encoding: NSUTF8StringEncoding];
	
	// Set the data length from the object in question
	NSUInteger dataLength = [self length];
	
	// For block ciphers, the output size will always be <= input size PLUS
	// THE SIZE OF ONE BLOCK. That's why we need to add that one block here
	size_t bufSize = dataLength + kCCBlockSizeAES128;
	void *buf = malloc(bufSize);
	
	// encrypts in-place, since this is a mutable data object
	size_t numBytesDecrypted = 0;
	CCCryptorStatus result = CCCrypt( kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, 
									 keyPtr, kCCKeySizeAES256,
									 NULL /* initialization vector (optional) */, 
									 [self mutableBytes], dataLength, /* input */
									 buf, bufSize, /* output */
									 &numBytesDecrypted );
	
	if (result == kCCParamError) {
		NSLog(@"Param error");
	} else if (result== kCCDecodeError) {
		NSLog(@"Decode error");
	} else if (result== kCCBufferTooSmall) {
		NSLog(@"buffer too small error");
	}
	
	if (result == kCCSuccess)
		return [NSMutableData dataWithBytesNoCopy:buf length:numBytesDecrypted];
	
	free(buf);
	return nil;
}


@end
