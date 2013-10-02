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
#import "FDFlowButton.h"

static FluxDeckViewController* instance = nil;

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
	[FDRequest initWithString:@"https://api.flowdock.com/flows?users=1" withBlock:^(NSObject *responseObject, NSError* error) {
		if( !error ) {
			NSArray *jsonFlows = (NSArray*)responseObject;
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

		}
	}];
}

@end
