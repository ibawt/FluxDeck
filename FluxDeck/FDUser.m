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

@implementation FDUser

-(void)updateFromJSON:(NSObject *)json
{
	if( [json isKindOfClass:[NSDictionary class]]) {
		NSDictionary *dict = (NSDictionary*)json;
		self.userID = [NSString stringWithFormat:@"%@",[dict valueForKey:@"id"]];
		self.email = [dict valueForKey:@"email"];
		self.nick = [dict valueForKey:@"nick"];
		self.name = [dict valueForKey:@"name"];
		self.avatar = [dict valueForKey:@"avatar"];
		self.status = [dict valueForKey:@"status"];
		self.disabled = [dict valueForKey:@"disabled"];
		self.lastActivity = [dict valueForKey:@"last_activity"];
		self.lastPing = [dict valueForKey:@"last_ping"];
	}
}
@end


FDUser *FDGetUserFromID(NSString *userID)
{
	return [[FluxDeckViewController instance].users objectForKey:userID];
}