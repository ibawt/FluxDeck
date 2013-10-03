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

@property (nonatomic, copy) NSString *flowID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *organization;
@property (nonatomic, copy) NSNumber *unreadMentions;
@property (nonatomic, copy) NSNumber *open;
@property (nonatomic, copy) NSNumber *joined;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *webUrl;
@property (nonatomic, copy) NSString *joinUrl;
@property (nonatomic, copy) NSString *accessMode;
@property (nonatomic, strong) NSMutableArray  *users;
@property (nonatomic, strong) NSMutableDictionary *userHash;

-(void)sortUsers;
-(void)setLastActivity:(NSDate*)date withUserID:(NSNumber*)userID;
-(FDUser*)userForID:(NSNumber*)uid;
@end
