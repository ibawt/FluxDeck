//
//  FDTextView.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-17.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDTextView.h"

@implementation FDTextView

-(void)mouseDown:(NSEvent *)theEvent
{
	NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSInteger charIndex = [self characterIndexForInsertionAtPoint:point];

	NSDictionary *attributes = [[self attributedString] attributesAtIndex:charIndex effectiveRange:NULL];

	if( attributes[kFDUserLinkAttribute] ) {
		if( self.linkBlock ) {
			self.linkBlock( attributes[kFDUserLinkAttribute], self);
		}
	} else {
		[super mouseDown:theEvent];
	}
}

@end
