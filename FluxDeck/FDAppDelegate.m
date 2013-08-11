//
//  FDAppDelegate.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDAppDelegate.h"

@implementation FDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
														 diskCapacity:20 * 1024 * 1024
															 diskPath:nil];
	[NSURLCache setSharedURLCache:URLCache];

	self.viewController = [[FluxDeckViewController alloc] initWithNibName:@"FluxDeckViewController" bundle:nil];
	[self.window.contentView addSubview:self.viewController.view];
	self.viewController.view.frame = ((NSView*)self.window.contentView).bounds;
}
@end
