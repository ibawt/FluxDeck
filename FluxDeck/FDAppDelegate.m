//
//  FDAppDelegate.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDAppDelegate.h"
#import <DDLog.h>
#import <DDTTYLogger.h>
#import <DDASLLogger.h>
#import <DDFileLogger.h>
#import <TMCache.h>

int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface FDAppDelegate()

@property (nonatomic,strong) DDFileLogger *fileLogger;

@end


@implementation FDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4*1024*1024
														 diskCapacity:20 * 1024 * 1024
															 diskPath:nil];
	[NSURLCache setSharedURLCache:URLCache];

	self.viewController = [[FluxDeckViewController alloc] initWithNibName:@"FluxDeckViewController" bundle:nil];
	[self.window.contentView addSubview:self.viewController.view];
	self.viewController.view.frame = ((NSView*)self.window.contentView).bounds;

	self.fileLogger = [[DDFileLogger alloc] init];
	self.fileLogger.rollingFrequency = 60*60*24;


	[DDLog addLogger:[DDASLLogger sharedInstance]];
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	[[DDTTYLogger sharedInstance] setColorsEnabled:YES];

	[DDLog addLogger:self.fileLogger];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	if( !flag ) {
		[self.window makeKeyAndOrderFront:self];
	}
	return YES;
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
	
}

@end
