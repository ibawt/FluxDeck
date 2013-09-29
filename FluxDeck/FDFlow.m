//
//  FDFlow.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDFlow.h"
#import "FDUser.h"

@implementation FDFlow

+(NSDictionary*)JSONKeyPathsByPropertyKey
{
	return @{ @"flowID" : @"id",
			  @"name" : @"name",
			  @"organization" : @"organization",
			  @"unreadMentions" : @"unread_mentions",
			  @"open" : @"open",
			  @"joined" : @"joined",
			  @"url" : @"url",
			  @"webUrl" : @"web_url",
			  @"join_url" : @"join_url",
			  @"accessMode" : @"access_mode",
			  @"users" : @"users"
			  };
}

+(NSValueTransformer*)usersJSONTransformer
{
	return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:FDUser.class];
}


-(void)sortUsers
{
	[self.users sortUsingComparator:^(FDUser *u1, FDUser *u2) {
		return [u2.lastActivity compare:u1.lastActivity];
	}];
}
@end
