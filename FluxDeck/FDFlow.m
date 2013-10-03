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

-(id)init
{
	if( self = [super init] ) {
		self.userHash = nil;
	}
	return self;
}

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
	if( !self.userHash ) {
		self.userHash = [[NSMutableDictionary alloc] init];

		for( FDUser *user in self.users ) {
			[self.userHash setObject:user forKey:user.userID];
		}
	}
	[self.users sortUsingComparator:^(FDUser *u1, FDUser *u2) {
		return [u2.lastActivity compare:u1.lastActivity];
	}];
}

-(FDUser*)userForID:(NSNumber *)uid
{
	FDUser *user = self.userHash[uid];
	NSAssert(user != nil, @"User not found uid: %@", uid);
	return user;
}

-(void)setLastActivity:(NSDate *)date withUserID:(NSNumber *)userID
{
	[self.userHash[userID] setLastActivity:date];
}

@end
