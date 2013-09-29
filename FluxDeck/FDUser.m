//
//  FDUser.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDUser.h"
#import "FDRequest.h"
#import "FDImageCache.h"
#import "FluxDeckViewController.h"
#import "FluxDeck.h"

@implementation FDUser

+(NSDictionary *)JSONKeyPathsByPropertyKey
{
	return @{
			 @"userID" : @"id",
			 @"email" : @"email",
			 @"nick" : @"nick",
			 @"name" : @"name",
			 @"avatar" : @"avatar",
			 @"status" : @"status",
			 @"disabled" : @"disabled",
			 @"lastActivity" : @"last_activity",
			 @"lastPing" : @"last_ping"
			 };
}

+(NSValueTransformer*)lastActivityJSONTransformer
{
	return FDTimestampValueTransformer();
}

+(NSValueTransformer*)lastPingJSONTransformer
{
	return FDTimestampValueTransformer();
}

-(BOOL)isIdle
{
	static const NSTimeInterval kIDLE_MAX = 60*15;
	NSTimeInterval idleTime = ABS([self.lastPing timeIntervalSinceNow]);

	return idleTime > kIDLE_MAX;
}

@end



FDUser *FDGetUserFromID(NSString *userID)
{
	return [[FluxDeckViewController instance].users objectForKey:userID];
}