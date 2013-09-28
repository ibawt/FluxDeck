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
#import "FDRequestManager.h"

static FluxDeckViewController* instance = nil;

@interface FluxDeckViewController ()

@end

@implementation FluxDeckViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		instance = self;

		self.flows = [[NSMutableDictionary alloc] init];
		self.viewControllers = [[NSMutableArray alloc] init];
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

-(void)getFlows
{
	FDRequestManager *manager = [FDRequestManager manager];
	
	AFHTTPRequestOperation *operation = [manager GET:@"https://api.flowdock.com/flows" parameters:@{@"users":@"1"} success:^(AFHTTPRequestOperation* operation, id responseObject) {

		NSArray *jsonFlows = responseObject;

		for( NSDictionary *dict in jsonFlows) {
			FDFlow* flow = [MTLJSONAdapter modelOfClass:FDFlow.class fromJSONDictionary:dict error:nil];
			if( [flow.open boolValue] ) {
				self.flows[flow.flowID] = flow;
				NSTabViewItem *item = [[NSTabViewItem alloc] init];
				item.label = flow.name;
				FDFlowViewController *viewController = [[FDFlowViewController alloc] initWithNibName:@"FDFlowViewController" bundle:nil];
				[self.viewControllers addObject:viewController];
				[self.tabView addTabViewItem:item];
				[item setView:viewController.view];
				viewController.flow = flow;
			}
		}

	} failure: ^(AFHTTPRequestOperation *operation, NSError* error) {
		NSAssert(false, @"caught error in getting flows %@", error);
	}];

	[operation start];
}

@end
