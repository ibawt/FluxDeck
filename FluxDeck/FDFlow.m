//
//  FDFlow.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDFlow.h"

@implementation FDFlow

-(void)fromJSON:(NSDictionary *)dict
{
	self.flowID = [dict valueForKey:@"id"];
	self.name = [dict valueForKey:@"name"];
	self.organization = [dict valueForKey:@"organization"];
	self.unreadMentions = [dict valueForKey:@"unread_mentions"];
	self.open = [dict valueForKey:@"open"];
	self.joined = [dict valueForKey:@"joined"];
	self.url = [dict valueForKey:@"url"];
	self.webUrl = [dict valueForKey:@"web_url"];
	self.joinUrl = [dict valueForKey:@"join_url"];
	self.accessMode = [dict valueForKey:@"access_mode"];
}

@end
