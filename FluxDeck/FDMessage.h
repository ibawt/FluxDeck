//
//  FDMessage.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>

typedef enum : NSUInteger {
	FDChat,
	FDInflux,
	FDNull

} FDApp;

@interface FDMessage : MTLModel<MTLJSONSerializing>

@property (nonatomic,strong) NSArray  *attachments;
@property (nonatomic,strong) NSObject *content;
@property (strong) NSString *edited;
@property (strong) NSString *flow;
@property (strong) NSNumber *msgID;
@property (strong) NSDate *sent;
@property (strong) NSArray  *tags;
@property (strong) NSNumber *user;
@property (strong) NSString *uuid;
@property (strong) NSString *event;
@property (nonatomic,assign) FDApp app;
@property (nonatomic,strong) NSAttributedString* displayString;
@property (nonatomic,strong) NSMutableDictionary *rowHeightCache;

-(CGFloat)rowHeightForWidth:(CGFloat)width;
-(void)parseContent;
@end

