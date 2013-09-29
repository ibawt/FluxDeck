//
//  FDFlowButton.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-09-28.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDFlowButton.h"

@implementation FDFlowButton

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
	}
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	[[NSColor blackColor] setFill];
	NSRectFill(dirtyRect);
    // Drawing code here.
}

@end
