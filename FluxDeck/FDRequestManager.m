//
//  FDRequestManager.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-09-28.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDRequestManager.h"

static FDRequestManager* manager = nil;

@implementation FDRequestManager

-(id)init
{
	if( self = [super initWithBaseURL:nil]) {
	}
	return self;
}

+(FDRequestManager*)manager
{
	if( manager == nil ) {
		manager = [[FDRequestManager alloc] init];
	}
	return manager;
}


@end
