//
//  FluxDeckViewController.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FluxDeckViewController.h"
#import "FDRequest.h"
#import "FDFlow.h"
#import "FDUser.h"
#import "FDFlowViewController.h"

static FluxDeckViewController* instance = nil;

@interface FluxDeckViewController ()

@end

@implementation FluxDeckViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		instance = self;

		self.users = [[NSMutableDictionary alloc] init];
		self.flows = [[NSMutableDictionary alloc] init];
		self.viewControllers = [[NSMutableArray alloc] init];
        // Initialization code here.
    }
    
    return self;
}

+(FluxDeckViewController*)instance
{
	return instance;
}

-(void)awakeFromNib
{
	[self getFlows];
}

-(NSArray*)parseUsers:(NSArray*)users
{
	NSMutableArray *ids = [[NSMutableArray alloc] init];
	for( NSDictionary* dict in users) {
		FDUser *u = [[FDUser alloc] init];
		[u updateFromJSON:dict];
		[self.users setValue:u forKey:u.userID];
		[ids addObject:u.userID];
	}
	return ids;
}


-(void)getFlows
{
	[FDRequest initWithString:@"/flows?users=1" withBlock:^(NSObject *o, NSError *error) {
		NSArray *array = (NSArray*)o;

		for( NSDictionary *f in array ) {
			FDFlow *flow = [[FDFlow alloc] init];
			[flow fromJSON:f];

			[self.flows setValue:flow forKey:flow.flowID];

			NSArray *users = [f objectForKey:@"users"];
			if( users ) {
				NSArray *ids = [self parseUsers:users];
				flow.users = ids;
			}

			NSTabViewItem *item = [[NSTabViewItem alloc] init];
			item.label = flow.name;

			[self.tabView addTabViewItem:item];

			FDFlowViewController *viewController = [[FDFlowViewController alloc] initWithNibName:@"FDFlowViewController" bundle:nil];

			[item setView:viewController.view];

			[viewController setFlow:flow];
			[self.viewControllers addObject:viewController];
		}
	}];

}

@end
