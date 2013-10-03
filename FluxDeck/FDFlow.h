//
//  FDFlow.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>
#import "FDMessage.h"
#import "FDUser.h"

@interface FDFlow : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong) NSString *flowID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *organization;
@property (nonatomic, strong) NSNumber *unreadMentions;
@property (nonatomic, strong) NSNumber *open;
@property (nonatomic, strong) NSNumber *joined;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *webUrl;
@property (nonatomic, strong) NSString *joinUrl;
@property (nonatomic, strong) NSString *accessMode;
@property (nonatomic, strong) NSMutableArray  *users;
@property (nonatomic, strong) NSMutableDictionary *userHash;

-(void)sortUsers;
-(void)setLastActivity:(NSDate*)date withUserID:(NSNumber*)userID;
-(FDUser*)userForID:(NSNumber*)uid;
@end
