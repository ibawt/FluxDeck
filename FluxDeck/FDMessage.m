//
//  FDMessage.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDMessage.h"
#import "FluxDeck.h"
#import <TwitterText.h>
#import <math.h>
#import "FluxDeck.h"
#import "FDImageCache.h"

static const NSString *kFDHashTag = @"HashTag";
static const NSString *kFDListName = @"ListName";
static const NSString *kFDScreenName = @"ScreenName";
static const NSString *kFDSymbol = @"Symbol";

#define fequal( _x, _y) (fabs((_x) - (_y) ) < FLT_EPSILON )

@implementation FDMessage

-(id)init
{
	if( self = [super init] ) {
	}
	return self;
}

+(NSDictionary*)JSONKeyPathsByPropertyKey
{
	return @{
			 @"attachments" : @"attachments",
			 @"content" : @"content",
			 @"edited" : @"edited",
			 @"flow" : @"flow",
			 @"msgID" : @"id",
			 @"sent" :@"sent",
			 @"tags" : @"tags",
			 @"user" : @"user",
			 @"uuid" : @"uuid",
			 @"event" : @"event"
			 };
}

+ (NSValueTransformer *)appJSONTransformer {
    NSDictionary *states = @{
							 @"chat": @(FDChat),
							 @"influx": @(FDInflux),
							 @"<null>": @(FDNull),
							 };

    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
		if( !str ) {
			str = @"<null>";
		}
        return states[str];
    } reverseBlock:^(NSNumber *state) {
        return [states allKeysForObject:state].lastObject;
    }];
}

-(void)parseContent
{
	NSString *str = nil;

	if( [self.event isEqualToString:@"file"] ) {
		str = @"file";

		NSDictionary *dict = (NSDictionary*)self.content;

		if( dict[@"image"] ) {
			self.isImageCell = YES;
			self.rowHeight = [dict[@"image"][@"height"] floatValue];
			self.imageURL = [NSString stringWithFormat:@"https:/api.flowdock.com/%@", dict[@"path"]];
			[FDImageCache getDataForURL:self.imageURL onComplete:^(NSData *data, NSError*error) {
				self.image = [[NSImage alloc] initWithData:data];
			}];
		}
	}
	else if( [self.event isEqualToString:@"comment"]) {
		str = [self.content valueForKey:@"text"];
	}
	else if( [self.content isKindOfClass:NSString.class]) {
		str = (NSString*)self.content;
	} else{
		NSLog(@"wierd shit: %@", self.description);
	}
	// move link detection to twitter text entities? not sure how to do mixed images and text
	if( [str hasSuffix:@"png"] || [str hasSuffix:@"gif"] || [str hasSuffix:@"jpg"] || [str hasSuffix:@"jpeg"]) {
		self.isImageCell = YES;
		self.imageURL = (NSString*)self.content;
		[FDImageCache getDataForURL:(NSString*)self.content onComplete:^(NSData *data, NSError *error ) {
			self.image = [[NSImage alloc] initWithData:data];
			self.rowHeight = self.image.size.height;
		}];
		return;
	}

	NSArray *entities = [TwitterText entitiesInText:str];
	NSMutableAttributedString *ds = [[NSMutableAttributedString alloc] initWithString:str];

	for( TwitterTextEntity *te in entities ) {
		NSDictionary *attr = nil;
		NSString *value = [str substringWithRange:te.range];
		if( value == nil ) {
			continue;
		}
		switch(te.type ) {
			case TwitterTextEntityHashtag:
				attr = @{ kFDHashTag : value,
						  NSBackgroundColorAttributeName : [NSColor redColor],
						  };
				break;
			case TwitterTextEntityListName:
				break;
			case TwitterTextEntityScreenName:
				attr = @{ kFDScreenName : value,
						  NSBackgroundColorAttributeName : [NSColor orangeColor]
						  };
				break;
			case TwitterTextEntitySymbol:
				attr = @{};
				break;
			case TwitterTextEntityURL:
				attr = @{ NSLinkAttributeName : [NSURL URLWithString:value]
						  };
				break;
		}
		if( attr != nil )
			[ds addAttributes:attr range:te.range];
	}

	self.displayString = ds;
}

-(BOOL)verifyRowHeightForWidth:(CGFloat)w withHeight:(CGFloat)h
{
	if( fequal(w, self.rowWidth) && fequal(h, self.rowHeight)) {
		return YES;
	} else {
		self.rowWidth = w;
		self.rowHeight = h;
		return NO;
	}
}

-(void)saveImageFrame
{
	if( self.image ) {
		NSBitmapImageRep *bmp = [self.image representations][0];

		self.currentFrame = [bmp valueForProperty:NSImageCurrentFrame];
	}
}

-(void)setImageFrame
{
	NSBitmapImageRep *bmp = [self.image representations][0];
	if( self.currentFrame ) {
		[bmp setProperty:NSImageCurrentFrame withValue:self.currentFrame];
	}
}

-(CGFloat)rowHeightForWidth:(CGFloat)width
{
	if( self.isImageCell ) {
		return self.rowHeight;
	}
	if( !fequal(width, self.rowWidth) ) {
		NSRect rect = [self.displayString boundingRectWithSize:NSMakeSize(width, 0) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)];
		self.rowHeight = rect.size.height + kFDChatLinePadding;
	}
	return self.rowHeight;
}

+(NSValueTransformer*)sentJSONTransformer {
	return FDTimestampValueTransformer();
}

+(NSValueTransformer*)tagsJSONTransform
{
	return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:NSString.class];
}

@end
