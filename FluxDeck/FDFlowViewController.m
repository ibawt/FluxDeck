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
@property (strong) FDRequest* requestStream;
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


-(NSAttributedString*)parseMessageContent:(NSString*)str
{
	NSError *error = nil;

	NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:(NSTextCheckingTypes)NSTextCheckingTypeLink error:&error];

	NSArray *matches = [linkDetector matchesInString:str options:0 range:NSMakeRange(0, str.length)];
	NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:str];

	for (NSTextCheckingResult *match in matches) {
		if (match.URL) {
			NSDictionary *linkAttributes = @{
				   NSLinkAttributeName: match.URL,
			};
			[attrString addAttributes:linkAttributes range:match.range];
		}
	}
	return attrString;
}

-(void)setFlow:(FDFlow *)flow
{
	_flow = flow;
	[self fetchMessages];
	[self populateUsers];
	[self.chatTableView setDoubleAction:@selector(doubleClicked)];
	
	self.requestStream = [FDRequest initWithString:[NSString stringWithFormat:@"%@/messages", self.flow.url] withBlock:^(NSObject *object, NSError *error){
		
	} forStreaming:YES ];
}

-(void)populateUsers
{
	[self.userTableView reloadData];
}

-(IBAction)textEntered:(id)sender
{

}
/*
-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
	NSInteger selected = row;

    // Get row at specified index
    NSTableCellView *selectedRow = [tableView viewAtColumn:0 row:selected makeIfNecessary:YES];

    // Get row's text field
    NSTextField *selectedRowTextField = [selectedRow textField];

    // Focus on text field to make it auto-editable
    [[self.view window] makeFirstResponder:selectedRowTextField];

    // Set the keyboard carat to the beginning of the text field
    [[selectedRowTextField currentEditor] setSelectedRange:NSMakeRange(0, 0)];
	return YES;
}
 */

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
- (BOOL)tableView:(NSTableView *)aTableView
shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	return NO;
}

-(IBAction)doubleClicked:(id)sender
{
	;
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
			cellView.textField.attributedStringValue = [self parseMessageContent:[NSString stringWithFormat:@"%@: %@", FDGetUserFromID(msg.user).nick, msg.content]];
			[cellView.textField setSelectable:YES];
			return cellView;
		}
		return cellView;
	} else if( tableView == self.userTableView ) {
		NSTableCellView *cell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
		NSDictionary *users = [FluxDeckViewController instance].users;
		NSString *userID = [self.flow.users objectAtIndex:row];
		FDUser *user = [users objectForKey:userID];
		cell.textField.stringValue = user.nick;

		cell.toolTip = user.name;

		[FDImageCache getDataForURL:user.avatar onComplete:^(NSData *data, NSError *error){
			cell.imageView.image = [[NSImage alloc] initWithData:data];
		}];
		return cell;
	} else if( tableView == self.influxTableView ) {

	}
	return nil;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	if( tableView == self.chatTableView ) {
		NSString *c = [[self.messages objectAtIndex:row] content];
		NSRect rect = [c boundingRectWithSize:NSMakeSize(self.chatTableView.frame.size.width, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:nil];
		return MAX( rect.size.height, 40);
	}
	return 40;
}

-(void)fetchMessages
{
	NSString *url = [NSString stringWithFormat:@"%@/messages", self.flow.url];

	[FDRequest initWithString:url withBlock:^(NSObject* o, NSError *error) {
		NSArray *array = (NSArray*)o;
		NSMutableArray *msgs = [[NSMutableArray alloc] init];
		for( NSDictionary *d in array ) {
			NSString *event = [d valueForKey:@"event"];
			NSLog(@"event name: %@", event);
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
