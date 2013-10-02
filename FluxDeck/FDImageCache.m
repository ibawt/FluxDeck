//
//  FDImageCache.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDImageCache.h"
#import <TMCache.h>
#import "FDRequest.h"

@implementation FDImageCache

-(id)init
{
	if( self = [super init] ) {
	}
	return self;
}

+(FDImageCache*)instance
{
	static FDImageCache *instance = nil;
	static dispatch_once_t pred;

	dispatch_once(&pred, ^{
		instance = [[FDImageCache alloc] init];
	});
	return instance;
}

+(void)getDataForURL:(NSString *)url onComplete:(void (^)(NSImage *, NSError *))callback
{
	[[TMCache sharedCache] objectForKey:url block:^(TMCache *cache, NSString *key, id object) {
		if( object == nil ) {
			[FDRequest initWithString:url withBlock:^(NSObject *obj, NSError *error) {
				NSImage *image = [[NSImage alloc] initWithData:(NSData*)obj];
				callback(image,error);
			}];
		} else {
			callback(object,nil);
		}
	}];
}

@end
