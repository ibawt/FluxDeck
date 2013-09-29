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
#import "FDFlowButton.h"

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

		self.flowButtons = [[NSMutableArray alloc] init];
    }
    
    return self;
}

+(FluxDeckViewController*)instance
{
	return instance;
}

-(void)awakeFromNib
{
	self.tabView.backgroundColor = [NSColor blackColor];
	//[self.flowSettings setWantsLayer:YES];
	//self.flowSettings.layer.backgroundColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0);
	[self getFlows];
}

-(void)selectFlow:(NSInteger)index
{
	if( self.flowView.subviews.count > 0 )
		[self.flowView.subviews[0] removeFromSuperview];

	NSView *view = (NSView*)[self.viewControllers[index] view];
	view.frame = self.flowView.frame;
	[self.flowView addSubview:[self.viewControllers[index] view]];

	for( int i = 0 ; i < self.viewControllers.count ; ++i ) {
		FDFlowButton *fb = self.flowButtons[i];
		NSButtonCell * cell = fb.button.cell;

		if( i != index ) {
			[fb.button setBordered:NO];
			cell.backgroundStyle = NSBackgroundStyleDark;
			cell.backgroundColor = [NSColor blackColor];
		} else {
			[fb.button setBordered:YES];
		}
	}

}

-(void)getFlows
{
	FDRequestManager *manager = [FDRequestManager manager];
	
	AFHTTPRequestOperation *operation = [manager GET:@"https://api.flowdock.com/flows" parameters:@{@"users":@"1"} success:^(AFHTTPRequestOperation* operation, id responseObject) {

		NSArray *jsonFlows = responseObject;
		CGFloat x = self.flowSettings.frame.origin.x + self.flowSettings.frame.size.width;
		for( NSDictionary *dict in jsonFlows) {
			FDFlow* flow = [MTLJSONAdapter modelOfClass:FDFlow.class fromJSONDictionary:dict error:nil];
			if( [flow.open boolValue] ) {
				self.flows[flow.flowID] = flow;
				FDFlowViewController *viewController = [[FDFlowViewController alloc] initWithNibName:@"FDFlowViewController" bundle:nil];
				[self.viewControllers addObject:viewController];
				viewController.flow = flow;
				NSArray *array = nil;
				[[NSBundle mainBundle] loadNibNamed:@"FDFlowButton" owner:nil topLevelObjects:&array];
				FDFlowButton *fb = nil;
				for( id i in array ) {
					if( [i isKindOfClass:FDFlowButton.class]) {
						fb = i;
						break;
					}
				}
				[self.flowButtons addObject:fb];
				fb.backgroundColor = [NSColor whiteColor];
				fb.button.title = flow.name;
				[self.tabView addSubview:fb];
				CGRect rect = fb.frame;
				rect.origin.x = x;
				x += rect.size.width;
				fb.frame = rect;
			}
		}
		[self selectFlow:0];

	} failure: ^(AFHTTPRequestOperation *operation, NSError* error) {
		NSAssert(false, @"caught error in getting flows %@", error);
	}];

	[operation start];
}

@end
