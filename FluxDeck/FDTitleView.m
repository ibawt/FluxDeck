//
//  FDTitleView.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-09-29.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDTitleView.h"

@implementation FDTitleView

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

//	NSRect rect = self.bounds;
//
//	NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
//	path.lineWidth = 2.0f;
//	[[NSColor blackColor] setStroke];
//	
//	[path stroke];
}

@end
