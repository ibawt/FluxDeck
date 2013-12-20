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
-(void)setImage:(NSImage *)image
{
	if( image ) {
		NSBitmapImageRep *rep = [image representations][0];
		if( [[rep valueForProperty:NSImageFrameCount] isGreaterThan:@(0)]) {
			self.isAnimated = YES;
		}
	}
	_image = image;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	CGFloat x = ABS( self.frame.size.width - self.image.size.width)/2;

	NSBitmapImageRep *rep = [self.image representations][0];
	if( self.isAnimated ) {

		NSNumber *numFramesNumber = [rep valueForProperty:NSImageFrameCount];

		int numFrames = [numFramesNumber intValue];
		if( numFrames > 0 ) {
			NSTimeInterval elapsedTime = [NSDate timeIntervalSinceReferenceDate] - self.lastDrawTime;

			CGFloat currentFrameDuration = [[rep valueForProperty:NSImageCurrentFrameDuration] floatValue];

			CGFloat currentFrame = [[rep valueForProperty:NSImageCurrentFrame] floatValue];

			currentFrameDuration -= elapsedTime;
			if( currentFrameDuration < 0 ) {
				self.lastDrawTime = [NSDate timeIntervalSinceReferenceDate];
				int cr = rint(currentFrame+1);
				[rep setProperty:NSImageCurrentFrame withValue:[NSNumber numberWithInt:(cr)%numFrames]];
			}
		}
	}


	[self.image drawAtPoint:NSMakePoint(x, 0) fromRect:NSMakeRect(0, 0, self.image.size.width, self.image.size.height) operation:NSCompositeDestinationAtop fraction:1.0];
}

@end
