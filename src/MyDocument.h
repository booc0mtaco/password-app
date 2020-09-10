//
//  MyDocument.h
//  Password
//
//  Created by Andrew Holloway on 2010-01-02.
//

#import <Cocoa/Cocoa.h>

#import "StringToAttributedStringTransformer.h"
#import "PasswordToStringTransformer.h"

#import "PasswordArrayController.h"

@interface MyDocument : NSPersistentDocument {
	// adding a table View outlet so that the NSAlert knows where to look [tableView window]
	IBOutlet NSTableView *tableView;
	
	// The managed object context uses the password array controller, 
	// create an outlet, and attach it to the file's owner (MyDocument)
	IBOutlet PasswordArrayController *passwordArrayController; 
	
	// Reference to the URL field
	IBOutlet NSTextField *urlTextField;
	
	// Reference to the password entry name field
	IBOutlet NSTextField *entryNameField;
	
	// Reference to the password Checkbox
	IBOutlet NSButton *checkboxButton;
	
	// Password text Fields
	IBOutlet NSSecureTextField *secureField;
	IBOutlet NSTextField *clearTextField;
	
	// Setting up the cryptsheet which will be where we set the encryption value - p319
	// Value Transformer sheet
	IBOutlet NSWindow *cryptSheet;
	
    // The Crypt Key field
    IBOutlet NSTextField *cryptMasterKeyField;
    IBOutlet NSButton *endCryptSheetButton;
    IBOutlet NSTextField *newLabel;
    
	// Data
	NSString *cryptMasterKey;
	
	
}
// Cocoa Programming for Mac OS X - p218
// Adding method action for adding and removing password(s)
- (IBAction)addPassword:(id)sender;
- (IBAction)removePassword:(id)sender;

// Adding method action for launching URLs
// http://theocacao.com/document.page/183
- (IBAction)launchPage:(id)sender;

// Method to handle showing or hiding password fields
- (IBAction)setVisiblePassword:(id)sender;

// Actions for the new sheet
- (IBAction)beginCryptSheet:(id)sender;
- (IBAction)endCryptSheet:(id)sender;

- (void)showCryptSheet;

@end
