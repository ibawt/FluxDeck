//
//  FDMessage.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDMessage.h"

@implementation FDMessage

-(void)parseJSON:(NSObject *)obj
{
	NSDictionary *o = (NSDictionary*)obj;

	self.app = [o valueForKey:@"app"];
	self.attachments = o[@"attachments"];
	self.content = o[@"content"];
	self.edited = [o valueForKey:@"edited"];
	self.flow = [o valueForKey:@"flow"];
	self.msgID = [NSString stringWithFormat:@"%@",[o valueForKey:@"id"]];
	self.sent = [NSString stringWithFormat:@"%@",[o valueForKey:@"sent"]];
	self.tags = [o valueForKey:@"tags"];
	self.user = [NSString stringWithFormat:@"%@",[o valueForKey:@"user"]];
	self.uuid = [o valueForKey:@"uuid"];
}

@end
