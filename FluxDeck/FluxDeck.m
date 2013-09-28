//
//  FluxDeck.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-09-28.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FluxDeck.h"
#import <Mantle.h>


NSValueTransformer* FDTimestampValueTransformer(void)
{
	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *num) {
		return [NSDate dateWithTimeIntervalSince1970:num.longValue / 1000.0];
	} reverseBlock:^(NSDate* date) {
		return [NSString stringWithFormat:@"%ld",(NSInteger)[date timeIntervalSince1970]];
	}];
}
