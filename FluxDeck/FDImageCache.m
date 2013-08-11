//
//  FDImageCache.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDImageCache.h"

static NSString* base64String(NSString *str)
{
    NSData *theData = [str dataUsingEncoding: NSASCIIStringEncoding];
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];

    static const char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;

    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;

            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }

        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }

    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@interface FDImageCache ()

@property (assign) dispatch_queue_t     queue;
@property (strong) NSMutableDictionary *cache;
@end

@implementation FDImageCache

-(id)init
{
	if( self = [super init] ) {
		self.cache = [[NSMutableDictionary alloc] init];
		queue = dispatch_queue_create("flux_deck_image_queue", DISPATCH_QUEUE_SERIAL );
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

+(BOOL)isInCache:(NSString *)url
{
	return [[FDImageCache instance].cache objectForKey:url] != nil;
}

+(void)writeToDisk:(NSData*)data url:(NSString*)url
{
	NSString *base64 = base64String(url);

	[[NSFileManager defaultManager] createFileAtPath:base64 contents:data attributes:nil];
}


+(NSData*)getFileFromDisk:(NSString *)url
{
	NSString *base64 = base64String(url);

	if( [[NSFileManager defaultManager] fileExistsAtPath:base64 ] ) {
		return [NSData dataWithContentsOfFile:base64];
	}
	return nil;

}

static dispatch_queue_t queue = NULL;
+(NSData*)getDataForURL:(NSString *)url onComplete:(void (^)(NSData *, NSError *))callback
{
	if(![FDImageCache isInCache:url] ) {
		NSData *data = [FDImageCache getFileFromDisk:url];
		if( data ) {
			[[FDImageCache instance].cache setValue:data forKey:url];
			if( callback ) {
				callback(data,nil);
			}
			return data;
		}

		NSLog(@"sending request for %@", url);
		dispatch_async(queue, ^{
			NSURLResponse *resp = nil;
			NSError *error = nil;
			NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
												 returningResponse:&resp error:&error];
			[[FDImageCache instance].cache setObject:data forKey:url];
			[data writeToFile:base64String(url) atomically:NO];

			if( callback ) {
				callback( data, error);
			}
		} );
	}

	if( callback ) {
		callback( [[FDImageCache instance].cache objectForKey:url],nil);
	}
	return [[FDImageCache instance].cache objectForKey:url];

}


@end
