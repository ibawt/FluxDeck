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

@property (nonatomic,copy) NSArray  *attachments;
@property (nonatomic,copy) NSObject *content;
@property (nonatomic,copy) NSString *edited;
@property (nonatomic,copy) NSString *flow;
@property (nonatomic,copy) NSNumber *msgID;
@property (nonatomic,copy) NSDate *sent;
@property (nonatomic,copy) NSArray  *tags;
@property (nonatomic,copy) NSNumber *user;
@property (nonatomic,copy) NSString *uuid;
@property (nonatomic,copy) NSString *event;
@property (nonatomic,assign) FDApp app;
@property (nonatomic,strong) NSAttributedString* displayString;
@property (nonatomic,assign) CGFloat rowWidth;
@property (nonatomic,assign) CGFloat rowHeight;
-(BOOL)verifyRowHeightForWidth:(CGFloat)width withHeight:(CGFloat)height;
-(CGFloat)rowHeightForWidth:(CGFloat)width;
-(void)parseContent;
@end

