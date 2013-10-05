//
//  FDRequest.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FDRequestCallback)(NSData *data, NSError *error);

@interface FDRequest : NSObject<NSURLConnectionDelegate>
+(FDRequest*) initWithString:(NSString *)url withBlock:(FDRequestCallback)block;
+(FDRequest*) initWithString:(NSString *)url withBlock:(FDRequestCallback)block	forStreaming:(BOOL)isStreaming;
+(FDRequest*)initWithString:(NSString *)url withBlock:(FDRequestCallback)block withData:(NSData*)data;
+(FDRequest*)initWithString:(NSString *)url withBlock:(FDRequestCallback)block withLocalFile:(NSURL*)file;
@property (nonatomic,strong) NSMutableData *data;
@property (nonatomic,copy) FDRequestCallback callback;
@property (nonatomic,assign) BOOL isActive;
@property (nonatomic,copy) NSString *mimeType;
@end
