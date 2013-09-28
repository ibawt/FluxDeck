//
//  FDImageCache.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDImageCache.h"
#import <TMCache.h>
#import "FDRequestManager.h"

@interface FDImageCache ()
@property (nonatomic, strong) FDRequestManager *requestManager;
@end

@implementation FDImageCache

-(id)init
{
	if( self = [super init] ) {
		self.requestManager = [[FDRequestManager alloc] init];
		[self.requestManager setResponseSerializer:[[AFImageResponseSerializer alloc] init]];
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
			FDRequestManager *requestManager= [self instance].requestManager;
			AFHTTPRequestOperation *o = [requestManager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id response ){
				[[TMCache sharedCache] setObject:response forKey:url];
				callback(response, nil);
			} failure:^(AFHTTPRequestOperation* operation, NSError *error) {
				callback(nil,error);
			}];
			[o start];
		} else {
			callback(object,nil);
		}
	}];
}


@end
