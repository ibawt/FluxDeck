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

static const NSString *kFDHashTag = @"HashTag";
static const NSString *kFDListName = @"ListName";
static const NSString *kFDScreenName = @"ScreenName";
static const NSString *kFDSymbol = @"Symbol";

@implementation FDMessage

-(id)init
{
	if( self = [super init] ) {
		self.rowHeightCache = [[NSMutableDictionary alloc] init];
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
	}
	else if( [self.event isEqualToString:@"comment"]) {
		str = [self.content valueForKey:@"text"];
	}
	else if( [self.content isKindOfClass:NSString.class]) {
		str = (NSString*)self.content;
	} else{
		NSLog(@"wierd shit: %@", self.description);
	}

	NSArray *entities = [TwitterText entitiesInText:str];
	NSMutableAttributedString *ds = [[NSMutableAttributedString alloc] initWithString:str];

	for( TwitterTextEntity *te in entities ) {
		NSDictionary *attr = nil;
		NSString *value = [str substringWithRange:te.range];
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

		[ds addAttributes:attr range:te.range];
	}

	self.displayString = ds;
}

-(BOOL)verifyRowHeightForWidth:(CGFloat)w withHeight:(CGFloat)h
{
	NSNumber *width = [NSNumber numberWithFloat:w];
	NSNumber *height = [NSNumber numberWithFloat:h];

	if( ![self.rowHeightCache[width] isEqualToNumber:height] ) {
		self.rowHeightCache[width] = height;
		return NO;
	}
	return YES;
}

-(CGFloat)rowHeightForWidth:(CGFloat)width
{
	NSNumber *number = [NSNumber numberWithFloat:width];
	NSNumber *height = self.rowHeightCache[number];

	if( height == nil ) {
		NSRect rect = [self.displayString boundingRectWithSize:NSMakeSize(width, 0) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)];
		height = [NSNumber numberWithFloat:rect.size.height + 3];
		self.rowHeightCache[number] = height;
	}
	return [height floatValue];
}

+(NSValueTransformer*)sentJSONTransformer {
	return FDTimestampValueTransformer();
}

+(NSValueTransformer*)tagsJSONTransform
{
	return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:NSString.class];
}

@end
