//
//  FDChatTableCellView.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-10-02.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDChatTableCellView.h"
#import "FDTextView.h"

@implementation FDChatTableCellView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		self.textView = [[FDTextView alloc] initWithFrame:NSMakeRect(80, 0, frame.size.width-80, 0)];
		self.identifier = @"ChatTableCellView";
		self.textView.autoresizingMask = NSViewWidthSizable;
		[self.textView setHorizontallyResizable:YES];
		[self.textView setVerticallyResizable:YES];
		self.usernameField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 80, 0)];
		[self.usernameField setDrawsBackground:NO];
		[self.usernameField setBordered:NO];
		[self.usernameField setBezeled:NO];
		self.usernameField.textColor = [NSColor colorWithSRGBRed:0.3 green:0.3 blue:0.3 alpha:1.0f];
		[self addSubview:self.textView];
		[self addSubview:self.usernameField];
    }
    return self;
}

-(void)prepareForReuse
{
	NSLog(@"going into recycle queue");
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];

	NSColor* fillColor = [NSColor colorWithSRGBRed:0.95 green:0.95 blue:1.0 alpha:1.0];
	[fillColor setFill];

	NSRect rect = NSMakeRect(0, 0, 80, self.frame.size.height+20);
	NSRectFill(rect);

	NSColor *color = [NSColor colorWithSRGBRed:0.7 green:0.7 blue:0.8 alpha:1.0];
	[color setStroke];

	[NSBezierPath strokeLineFromPoint:NSMakePoint(0, self.frame.size.height) toPoint:NSMakePoint(self.frame.size.width, self.frame.size.height)];
}

@end
