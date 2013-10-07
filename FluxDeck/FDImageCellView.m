//
//  FDImageCellView.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-10-06.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDImageCellView.h"

@implementation FDImageCellView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(void)prepareForReuse
{
	self.image = nil;
	self.onScreen = NO;
	[self.message saveImageFrame];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	NSLog(@"drawing...");
	CGFloat x = ABS( self.frame.size.width - self.image.size.width)/2;

	NSBitmapImageRep *rep = [self.image representations][0];
	if( self.lastDrawTime != 0.0f) {

		NSNumber *numFramesNumber = [rep valueForProperty:NSImageFrameCount];

		int numFrames = [numFramesNumber intValue];
		if( numFrames > 0 ) {
			NSTimeInterval elapsedTime = [NSDate timeIntervalSinceReferenceDate] - self.lastDrawTime;

			int currentFrame = [[rep valueForProperty:NSImageCurrentFrame] intValue];
			[rep setProperty:NSImageCurrentFrame withValue:[NSNumber numberWithInt:(currentFrame+1)%numFrames]];
		}
	}


	[self.image drawAtPoint:NSMakePoint(x, 0) fromRect:NSMakeRect(0, 0, self.image.size.width, self.image.size.height) operation:NSCompositeDestinationAtop fraction:1.0];

	self.lastDrawTime = [NSDate timeIntervalSinceReferenceDate];
    // Drawing code here.
}

@end
