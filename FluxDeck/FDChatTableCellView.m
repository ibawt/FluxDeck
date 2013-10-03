//
//  FDChatTableCellView.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-10-02.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDChatTableCellView.h"

@implementation FDChatTableCellView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	NSRectClip(dirtyRect);
	//f8f8ff
	[[NSColor colorWithCGColor:CGColorCreateGenericRGB(0.95, 0.95, 1.0, 1.0)] setFill];
	NSColor *color = [NSColor colorWithSRGBRed:0.7 green:0.7 blue:0.8 alpha:1.0];
	[color setStroke];

	NSRect rect = NSMakeRect(0, 0, 80, self.frame.size.height+20);
	NSRectFill(rect);



	[NSBezierPath strokeLineFromPoint:NSMakePoint(0, self.frame.size.height) toPoint:NSMakePoint(self.frame.size.width, self.frame.size.height)];

    // Drawing code here.
}

@end
