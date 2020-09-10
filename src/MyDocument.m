//
//  MyDocument.m
//  Password
//
//  Created by Andrew Holloway on 2010-01-02.
//

#import "MyDocument.h"

@implementation MyDocument

- (id)init 
{
    self = [super init];
    if (self != nil) {
		
		// adding a notification center reference so we can see when an object has changed
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self 
			   selector:@selector(managedObjectContextObjectsDidChange:) 
				   name:NSManagedObjectContextObjectsDidChangeNotification
				 object:nil];
		
		cryptMasterKey = [[NSString alloc] initWithString:@""];

        // Transform strings between NS String and a password entry
		PasswordToStringTransformer *passwordToStringTransformer = [[PasswordToStringTransformer alloc] init];
		[passwordToStringTransformer setCryptTransformerKey:cryptMasterKey];
		[NSValueTransformer setValueTransformer:passwordToStringTransformer forName:@"PasswordToStringTransformer"];
        
        // Handle transforming strings for the text field rich text input
		StringToAttributedStringTransformer* stringToAttributedStringTransformer = [[StringToAttributedStringTransformer alloc] init];
		[NSValueTransformer setValueTransformer:stringToAttributedStringTransformer forName:@"StringToAttributedStringTransformer"];		
		
    }
	
    return self;
}

// Set the name of the window
- (NSString *)windowNibName 
{
    return @"MyDocument";
}

// check to see if the nib/xib was loaded
// Technically, not needed right now, since it only calls the super function
- (void)windowControllerDidLoadNib:(NSWindowController *)windowController 
{
    [super windowControllerDidLoadNib:windowController];
    
    // TODO: only draw the sheet if there's a file loaded. Otherwise, delay until the password button is pressed
    if ([[passwordArrayController arrangedObjects] count] > 0) {
        [self showCryptSheet];
    }    
}

// Cleanup before exit
- (void)dealloc
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
}

// Draw this sheet every time the window draws
- (void)showWindows
{
	[super showWindows];
	
	[passwordArrayController rearrangeObjects];
	[tableView setUsesAlternatingRowBackgroundColors:YES];	

}

#pragma mark p220 - Handling Add/Delete Dialog 
- (IBAction)addPassword:(id)sender
{
    
    // If this is the first password, load the crypt sheet to get the key
    if ([[passwordArrayController arrangedObjects] count] <= 0) {
        [self showCryptSheet];
    }

	// p150 - doing some work to put the cursor in the right place
	NSWindow *w = [tableView window];
	
	BOOL editingEnded = [w makeFirstResponder:w];
	if (!editingEnded) {
		NSLog(@"Unable to end the editing");
	}
	NSUndoManager *undo = [self undoManager];
	
	// Has an edit occurred already in this event?
	if ([undo groupingLevel]) {
		[undo endUndoGrouping];
		[undo beginUndoGrouping];
	}
	
	id newGuy = [passwordArrayController newObject];
	[passwordArrayController addObject:newGuy];
	[passwordArrayController rearrangeObjects];
	
	NSArray *a = [passwordArrayController arrangedObjects];
	
	int row = [a indexOfObjectIdenticalTo:newGuy];
		
	NSIndexSet *selectIndex = [NSIndexSet indexSetWithIndex:row];
	
	[tableView selectRowIndexes:selectIndex byExtendingSelection:NO];
	
	[w makeFirstResponder:entryNameField];
}

- (IBAction)removePassword:(id)sender
{
	
	NSArray *selectedPasswords = [passwordArrayController selectedObjects];
	
	if ([[passwordArrayController selectedObjects] count] > 1) {
		NSAlert *alert = [NSAlert alertWithMessageText:@"Delete?" 
										 defaultButton:@"Delete" 
									   alternateButton:@"Cancel" 
										   otherButton:nil 
							 informativeTextWithFormat:@"Do you really want to delete %d password(s)?", [selectedPasswords count]];
			
		[alert beginSheetModalForWindow:[tableView window] 
						  modalDelegate:self 
						 didEndSelector:@selector(alertEnded:code:context:) 
							contextInfo:NULL];
	} else {
		[passwordArrayController remove:nil];
	}

}

- (void)alertEnded:(NSAlert *)alert 
			  code:(int)choice 
		   context:(void *)v
{
	// if the user chose "delete", tell the array controller to delete the passwords
	if (choice == NSAlertDefaultReturn) {
		[passwordArrayController remove:nil];
	}
}

#pragma mark URL Launching
- (IBAction)launchPage:(id)sender
{
	NSWorkspace * myWorkspace = [NSWorkspace sharedWorkspace];
	NSURL *url = [NSURL URLWithString:[urlTextField stringValue]];
	
	if (![myWorkspace openURL:url])		
		NSRunAlertPanel(@"No URL", @"This entry has no URL to open", @"OK", nil, nil);
	
}

#pragma mark When an object has been Changed 
// When there are changes, Stop observation, update the date, then restart observation
- (void) managedObjectContextObjectsDidChange:(NSNotification *)aNotification 
{	
	// remove the observer temporarily
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self 
				  name:NSManagedObjectContextObjectsDidChangeNotification 
				object:nil];
	
	NSDictionary *dictionary = [aNotification userInfo];
	NSSet *changedObjects = [dictionary objectForKey:NSUpdatedObjectsKey];
	
	id value;
	NSDate *now = [NSDate date];
		
	NSEnumerator *changedEnumerator = [changedObjects objectEnumerator];
	while (value = [changedEnumerator nextObject]) {
		// http://www.cocoabuilder.com/archive/cocoa/186203-modified-date-in-coredata-model.html
		[value setPrimitiveValue:now forKey:@"editDate"];
	}
	
	[nc addObserver:self 
		   selector:@selector(managedObjectContextObjectsDidChange:) 
			   name:NSManagedObjectContextObjectsDidChangeNotification 
			 object:nil];
	
}

#pragma mark Handling showing different password fields
- (IBAction)setVisiblePassword:(id)sender
{
	if ([checkboxButton state]) {
        // OS X Lion workaround: if the cryptkey is empty, show the sheet
        // This is needed because Lion automagically opens old files
        if ([cryptMasterKey length] <= 0) {
            [self showCryptSheet];
        }
		[secureField setHidden:YES];
		[clearTextField setHidden:NO];
	} else {
		[secureField setHidden:NO];
		[clearTextField setHidden:YES];
	}

}

#pragma mark Handling the displaying and hiding of the crypt sheet
// Use this when adding a password to an empty file (first time use)
// Or, when opening a file that has passwords already
- (IBAction)beginCryptSheet:(id)sender
{
	[self showCryptSheet];
    
    // if there are no passwords, we have a new one, so enable the new text
    if ([[passwordArrayController selectedObjects] count]) {
        [newLabel setHidden:YES];
    }
}

- (IBAction)endCryptSheet:(id)sender
{
	if ([cryptMasterKey length] < 5) {
		NSBeep();
		return;
	}
		
	PasswordToStringTransformer *tempTransformer = [PasswordToStringTransformer valueTransformerForName:@"PasswordToStringTransformer"];
	[tempTransformer setCryptTransformerKey:cryptMasterKey];
	
	// Return to normal event handling
	[NSApp endSheet:cryptSheet];
		
	[cryptSheet orderOut:sender];
	
	[checkboxButton setState:1];
	[secureField setHidden:YES];
	[clearTextField setHidden:NO];
	
	// http://osdir.com/ml/cocoa-dev/2009-09/msg01868.html
    // When you close the sheet, de-select the default item in the list
    if ([[passwordArrayController selectedObjects] count]) {
        [tableView deselectAll:sender];
    }
}

#pragma mark Buncha gunk that probably should be elsewhere...
// mydocument becomes the delegate for the cryptsheet's text field, so we can programmatically enable/disable the button
- (void)controlTextDidChange:(NSNotification *)aNotification
{
    if ([[cryptMasterKeyField stringValue] length] >= 5) {
        [endCryptSheetButton setEnabled:YES];
        
        // Put the string, regardless, in the masterkey value as you type
        
        // THIS IS HORRIBLE... can't be the right way to do this...
        cryptMasterKey = [cryptMasterKeyField stringValue];
    } else {
        [endCryptSheetButton setEnabled:NO];
    }
    
}

// begin the password sheet as requested
- (void)showCryptSheet
{
    [NSApp beginSheet:cryptSheet 
	   modalForWindow:[tableView window] 
		modalDelegate:nil 
	   didEndSelector:NULL 
		  contextInfo:NULL];
}

@end
