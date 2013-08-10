//
//  FDFlow.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FDFlow : NSObject

-(void)fromJSON:(NSDictionary*)dict;

@property (nonatomic, strong) NSString *flowID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *organization;
@property (nonatomic, strong) NSString *unreadMentions;
@property (nonatomic, strong) NSString *open;
@property (nonatomic, strong) NSString *joined;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *webUrl;
@property (nonatomic, strong) NSString *joinUrl;
@property (nonatomic, strong) NSString *accessMode;
@property (nonatomic, strong) NSArray  *users;

@end
