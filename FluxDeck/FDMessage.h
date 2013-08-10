//
//  FDMessage.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FDMessage : NSObject

-(void)parseJSON:(NSObject*)o;

@property (nonatomic,strong) NSString *app;
@property (nonatomic,strong) NSArray  *attachments;
@property (nonatomic,strong) NSString *content;
@property (strong) NSString *edited;
@property (strong) NSString *flow;
@property (strong) NSString *msgID;
@property (strong) NSString *sent;
@property (strong) NSArray  *tags;
@property (strong) NSString *user;
@property (strong) NSString *uuid;

@end
