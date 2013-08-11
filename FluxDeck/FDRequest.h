//
//  FDRequest.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FDRequestCallback)(NSObject *json, NSError *error);

@interface FDRequest : NSObject<NSURLConnectionDelegate>

+(FDRequest*) initWithString:(NSString *)url withBlock:(FDRequestCallback)block;
+(FDRequest*) initWithString:(NSString *)url withBlock:(FDRequestCallback)block	forStreaming:(BOOL)isStreaming;
@property (nonatomic,strong) NSMutableData *data;
@property (nonatomic,strong) NSDictionary* json;
@property (nonatomic,strong) FDRequestCallback callback;
@property (assign) BOOL isActive;
@end
