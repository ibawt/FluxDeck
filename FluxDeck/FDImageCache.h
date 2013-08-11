//
//  FDImageCache.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FDImageCache : NSObject

+(NSData*)getDataForURL:(NSString*)url onComplete:( void (^)(NSData* data, NSError *error))callback;
+(BOOL)isInCache:(NSString*)url;
+(FDImageCache*)instance;

@end
