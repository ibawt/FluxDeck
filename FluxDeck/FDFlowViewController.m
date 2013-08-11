//
//  FDFlowViewController.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDFlowViewController.h"
#import "FDRequest.h"
#import "FDMessage.h"
#import "FDUser.h"
#import "FluxDeckViewController.h"
#import "FDImageCache.h"

@interface FDFlowViewController ()

@end

@implementation FDFlowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.messages = [[NSMutableArray alloc] init];
        // Initialization code here.
    }
    
    return self;
}

-(void)setFlow:(FDFlow *)flow
{
	_flow = flow;
	[self fetchMessages];
	[self populateUsers];
}

-(void)populateUsers
{
	[self.userTableView reloadData];
}

-(IBAction)textEntered:(id)sender
{

}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if( aTableView == self.chatTableView) {
		return [self.messages count];
	}
	else if( aTableView == self.userTableView ) {
		return [self.flow.users count];
	}
	else if( aTableView == self.influxTableView ) {
		
	}
	NSAssert(true, @"Invalid table view sent to controller");
	return -1;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	if( tableView == self.chatTableView ) {
		// Get a new ViewCell
		NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];

		// Since this is a single-column table view, this would not be necessary.
		// But it's a good practice to do it in order by remember it when a table is multicolumn.
		if( [tableColumn.identifier isEqualToString:@"ChatColumn"] )
		{
			FDMessage *msg = [self.messages objectAtIndex:row];
			cellView.textField.stringValue = msg.content;
			return cellView;
		}
		return cellView;
	} else if( tableView == self.userTableView ) {
		NSTableCellView *cell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
		NSDictionary *users = [FluxDeckViewController instance].users;
		NSString *userID = [self.flow.users objectAtIndex:row];
		FDUser *user = [users objectForKey:userID];
		cell.textField.stringValue = user.nick;
		[FDImageCache getDataForURL:user.avatar onComplete:^(NSData *data, NSError *error){
			cell.imageView.image = [[NSImage alloc] initWithData:data];
		}];
		return cell;
	} else if( tableView == self.influxTableView ) {

	}
	return nil;
}

-(void)fetchMessages
{
	NSString *url = [NSString stringWithFormat:@"%@/messages", self.flow.url];

	[FDRequest initWithString:url withBlock:^(NSObject* o, NSError *error) {
		NSArray *array = (NSArray*)o;
		NSMutableArray *msgs = [[NSMutableArray alloc]init];
		for( NSDictionary *d in array ) {
			NSString *event = [d valueForKey:@"event"];

			if( [event isEqualToString:@"message"]) {
				FDMessage *msg = [[FDMessage alloc] init];
				[msg parseJSON:d];
				[msgs addObject:msg];
			}
		}

		[self.messages addObjectsFromArray:msgs];
		[self.chatTableView reloadData];
		[self.chatTableView scrollRowToVisible:[self.messages count] -1 ];
	}];
}


@end
