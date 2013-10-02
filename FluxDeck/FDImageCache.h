//
//  FDImageCache.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FDImageCache : NSObject

+(void)getDataForURL:(NSString*)url onComplete:( void (^)(NSImage* data, NSError *error))callback;
+(FDImageCache*)instance;

@end
