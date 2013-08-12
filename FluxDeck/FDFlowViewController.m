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
#import "FDChatLineView.h"

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


-(NSAttributedString*)parseMessageContent:(FDMessage*)fd
{
	NSError *error = nil;

	NSString *str = fd.content;

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

-(void)fetchMessages
{
	NSString *url;
	if( self.lastMessageID) {
		url = [NSString stringWithFormat:@"%@/messages?limit=100&since_id=%@", self.flow.url, self.lastMessageID];
	} else {
		url = [NSString stringWithFormat:@"%@/messages?limit=100", self.flow.url];
	}
	
	self.requestStream = [FDRequest initWithString:url withBlock:^(NSObject *object, NSError *error){
		NSMutableArray *msgs = [[NSMutableArray alloc] init];

		if( [object isKindOfClass:[NSDictionary class]]) {
			// one item

			NSDictionary *dict = (NSDictionary*)object;

			if( [dict[@"event"] isEqualToString:@"message"]) {
				FDMessage *msg = [[FDMessage alloc] init];
				[msg parseJSON:dict];
				NSLog(@"%@", msg.content);
				[msgs addObject:msg];

			}
		} else {
			NSArray *array = (NSArray*)object;
			for( NSDictionary *d in array ) {
				NSString *event = [d valueForKey:@"event"];
				if( [event isEqualToString:@"message"]) {
					FDMessage *msg = [[FDMessage alloc] init];
					[msg parseJSON:d];
					[msgs addObject:msg];
					self.lastMessageID = msg.msgID;
					//[self makeChatCell:msg];
				}
			}

			[self.chatTableView beginUpdates];
			[self.messages addObjectsFromArray:msgs];
			[self.chatTableView endUpdates];
			[self.chatTableView reloadData];
			[self.chatTableView scrollRowToVisible:[self.messages count] -1 ];


		}
		[self performSelector:@selector(fetchMessages) withObject:nil afterDelay:5];
	} forStreaming:NO ];

}

-(void)setFlow:(FDFlow *)flow
{
	_flow = flow;
	//[self fetchMessages];
	[self populateUsers];
	[self.chatTableView setDoubleAction:@selector(doubleClicked)];

	[self fetchMessages];
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
- (BOOL)tableView:(NSTableView *)aTableView
shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	return NO;
}

-(IBAction)doubleClicked:(id)sender
{
	;
}


-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
	return NO;
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	if( tableView == self.chatTableView ) {
		FDMessage *msg = [self.messages objectAtIndex:row];
		return [self makeChatCell:msg];
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
		FDMessage* msg = [self.messages objectAtIndex:row];
		NSAttributedString *str = [self parseMessageContent:msg];

		NSRect bounds = [str boundingRectWithSize: NSMakeSize(tableView.bounds.size.width, 0) options: NSStringDrawingUsesLineFragmentOrigin];
		//v.frame = NSMakeRect(0, 0, v.bounds.size.width + 20, bounds.size.height + 20);
		//[//v.textView.layoutManager ensureLayoutForTextContainer:v.textView.textContainer];

		return bounds.size.height + 10;

	}
	return 40;
}

-(NSView*)makeChatCell:(FDMessage*)msg
{
	NSArray *objs = nil;

	[[NSBundle mainBundle] loadNibNamed:@"ChatLineView" owner:self topLevelObjects:&objs];

	FDChatLineView *v = nil;
	for( NSObject *o in objs ) {
		if( [o class]  == [FDChatLineView class] ) {
			v = (FDChatLineView*)o;
			break;
		}
	}

	NSAssert( v != nil, @"Can't find view in nib");
	[v setFrameSize:NSMakeSize(self.chatTableView.frame.size.width, 60 )];
	NSAttributedString *str = [self parseMessageContent:msg];
	[[v textStorage] setAttributedString:str];
	CGFloat width = self.chatTableView.bounds.size.width;
	NSRect bounds = [str boundingRectWithSize: NSMakeSize(width, 0) options: NSStringDrawingUsesLineFragmentOrigin];
	v.frame = NSMakeRect(0, 0, width + 20, bounds.size.height + 20);
	//[//v.textView.layoutManager ensureLayoutForTextContainer:v.textView.textContainer];
	
	return v;
	//[self.view addSubview:v];
}
@end
