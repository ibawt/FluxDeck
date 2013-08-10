//
//  FDMessage.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDMessage.h"

@implementation FDMessage

-(void)parseJSON:(NSObject *)o
{
	self.app = [o valueForKey:@"app"];
	self.attachments = [o valueForKey:@"attachments"];
	self.content = [o valueForKey:@"content"];
	self.edited = [o valueForKey:@"edited"];
	self.flow = [o valueForKey:@"flow"];
	self.msgID = [o valueForKey:@"id"];
	self.sent = [o valueForKey:@"sent"];
	self.tags = [o valueForKey:@"tags"];
	self.user = [o valueForKey:@"user"];
	self.uuid = [o valueForKey:@"uuid"];
}

@end
