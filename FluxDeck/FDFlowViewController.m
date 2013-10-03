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
#import "FDTextView.h"
#import "FDUserTableCellView.h"
#import "FDChatTableCellView.h"

#include <math.h>

static const NSTimeInterval kFDFlowPollTime = 3.0;

static NSString *kBUILDOK_ICON = @"https://d2cxspbh1aoie1.cloudfront.net/avatars/ac9a7ed457c803acfe8d29559dd9b911/120";

const NSString *kFDUserLinkAttribute = @"FDUserLink";


static const NSUInteger kMAX_SCROLLBACK = 256;


@interface FDFlowViewController ()
@property (strong) FDRequest* requestStream;
@end

@implementation FDFlowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.messages = [[NSMutableArray alloc] init];
    self.influx = [[NSMutableArray alloc] init];
  }
    
  return self;
}

+(NSOperationQueue*)queue
{
	static NSOperationQueue *queue = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		queue = [[NSOperationQueue alloc] init];
	});
	return queue;
}

-(void)awakeFromNib
{
	NSNib *nib = [[NSNib alloc] initWithNibNamed:@"FDUserTableCellView" bundle:[NSBundle mainBundle]];
	[self.userTableView registerNib:nib forIdentifier:@"FDUserTableCellView"];

}

-(void)scrollToBottom
{
	[self.chatTableView scrollRowToVisible:self.messages.count -1];
}



-(void)parseMessages:(NSArray*)messages
{
	[[FDFlowViewController queue] addOperationWithBlock:^(void) {
		NSMutableArray *parsedMessages = [[NSMutableArray alloc] init];
		for( NSDictionary *d in messages ) {
			FDMessage *msg = [MTLJSONAdapter modelOfClass:FDMessage.class fromJSONDictionary:d error:nil];

			if( [msg.event isEqualToString:@"backend.join.user"] ) {
				FDUser *user = [MTLJSONAdapter modelOfClass:FDUser.class fromJSONDictionary:(NSDictionary*)msg.content error:nil];
				[self.flow.users addObject:user];
			} else if([msg.event isEqualToString:@"action"] ) {
				//idk
			}
			else if( [msg.event isEqualToString:@"user-edit"]) {
				//idk
			}
			else {
				switch( msg.app) {
				case FDChat:
						if( [msg.event isEqualToString:@"comment"]) {
							NSLog(@"%@", msg.description);
						}
					[parsedMessages addObject:msg];
					[msg parseContent];
					break;
				case FDInflux:
					[self.influx addObject:msg];
					break;
				case FDNull:
					if( [msg.event isEqualToString:@"activity.user"] ) {
						NSNumber *date = [msg.content valueForKey:@"last_activity"];
						if( date ) {
							[self.flow setLastActivity:[NSDate dateWithTimeIntervalSince1970:date.floatValue/1000.0] withUserID:msg.user];
						}
					}
					break;
				}
			}
		}
		if( parsedMessages.count > 0 ) {
			self.lastMessageID = [[parsedMessages objectAtIndex:parsedMessages.count-1] msgID];

			[[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
			if( self.onScreen ) {
				NSLog(@"on screen updating: %@", self.flow.name);
				[self.chatTableView beginUpdates];
				[self.messages addObjectsFromArray:parsedMessages];
				if( self.messages.count > kMAX_SCROLLBACK) {
					NSLog(@"trimming");
					[self.messages removeObjectsInRange:NSMakeRange(0, self.messages.count - kMAX_SCROLLBACK)];
				}
				[self.chatTableView endUpdates];
				[self.chatTableView reloadData];

				[self scrollToBottom];
			} else {
				NSLog(@"not on screen updating: %@", self.flow.name);
				[self.messages addObjectsFromArray:parsedMessages];
			}
		}];
		}

	}];
}

-(void)setOnScreen:(BOOL)onScreen
{
	if(!self.onScreen ) {
		[self.chatTableView reloadData];
	}
	_onScreen = onScreen;
	[self scrollToBottom];
}

-(void)fetchMessages:(NSDictionary*)options
{
 BOOL stream = NO;
  NSString *url;

  if( stream ) {
    url = [NSString stringWithFormat:@"%@", self.flow.url];
  }
  else if( self.lastMessageID) {
    url = [NSString stringWithFormat:@"%@/messages?limit=100&since_id=%@", self.flow.url, self.lastMessageID];
  } else {
    url = [NSString stringWithFormat:@"%@/messages?limit=100", self.flow.url];
  }
	
  [FDRequest initWithString:url withBlock:^(NSObject *object, NSError *error){
	  if( error ) {
		  [self performSelectorOnMainThread:@selector(fetchMessages:) withObject:nil waitUntilDone:NO];
	  } else {
		  NSArray *array;
		  if( [object isKindOfClass:NSDictionary.class]) {
			  array = [[NSArray alloc] initWithObjects:object, nil];
		  } else {
			  array = (NSArray*)object;
		  }
			[self parseMessages:array];
		  }
		[self performSelector:@selector(fetchMessages:) withObject:nil afterDelay:5];
	  }
	forStreaming:stream];
}


-(void)setFlow:(FDFlow *)flow
{
	_flow = flow;
	[self.flow sortUsers];
	[self populateUsers];
	[self fetchMessages:nil];
}

-(void)populateUsers
{
	[self.userTableView reloadData];
}

-(IBAction)textEntered:(id)sender
{
	NSTextField *tf = sender;

	if( tf.stringValue.length > 0 ) {
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		dict[@"event"] = @"message";
		dict[@"content"] = tf.stringValue;
		dict[@"tags"] = @"";
		NSError *error;
		NSArray *array = [self.flow.flowID componentsSeparatedByString:@":"];
		NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
		NSString *url = [NSString stringWithFormat:@"https://api.flowdock.com/flows/%@/%@/messages", array[0], array[1]];
		[FDRequest initWithString:url withBlock:^(NSObject *json, NSError* error) {
			NSLog(@"%@", json);
		} withData:data];
		tf.stringValue = @"";
	}
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
		return self.influx.count;
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

}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
	return NO;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if( tableView == self.chatTableView ) {
		return [self makeChatCell:nil withTableView:tableView withRow:row];
	} else if( tableView == self.userTableView ) {
		FDUserTableCellView *cell = [self.userTableView makeViewWithIdentifier:@"FDUserTableCellView" owner:self];
		FDUser *user = self.flow.users[row];
		cell.username.stringValue = user.nick;
		NSTimeInterval time = ABS([user.lastActivity timeIntervalSinceNow]);
		if( time > 60*60 ) {
			cell.lastActivity.stringValue = [NSString stringWithFormat:@"%.2f hours", time / (60*60)];
			// hours
		} else if( time > 60 ) {
			cell.lastActivity.stringValue = [NSString stringWithFormat:@"%d minutes", (int)(time / 60) ];
		} else {
			cell.lastActivity.stringValue = [NSString stringWithFormat:@"%d secs", (int)(time)];
			// seconds
		}
		if( time >  60*60*8 ) {
			cell.statusIcon.image = [NSImage imageNamed:NSImageNameStatusUnavailable];
		}
		else if( time > 60*15 ) {
			cell.statusIcon.image = [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
		} else {
			cell.statusIcon.image = [NSImage imageNamed:NSImageNameStatusAvailable];
		}

		[cell.username sizeToFit];
		CGRect rect = cell.lastActivity.frame;
		rect.origin.x = cell.username.frame.origin.x + cell.username.frame.size.width;
		cell.lastActivity.frame = rect;
		return cell;
	} else if( tableView == self.influxTableView ) {
		return [self makeChatCell:[self.influx objectAtIndex:row] withTableView:self.influxTableView withRow:row];

	}
	return nil;
}

-(NSArray*)getThreadByParent:(FDMessage*)message
{
	NSMutableArray* array = [[NSMutableArray alloc] initWithObjects:message, nil];
	NSLog(@"title: %@", message.content);
	for( FDMessage *msg in self.messages ) {
		if( [msg.event isEqualToString:@"comment"]) {
			if( [[msg.content valueForKey:@"title"] isEqualToString:(NSString*)message.content]) {
				[array addObject:msg];
				NSLog(@"comment: %@", [msg.content valueForKey:@"text"] );
			}
		}
	}
	return array;
}


-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	if( tableView == self.chatTableView ) {
		FDMessage* msg = [self.messages objectAtIndex:row];
		return [msg rowHeightForWidth:tableView.frame.size.width-80];
	} else if( tableView == self.influxTableView) {
	}
	return 22;
}

-(NSView*)makeChatCell:(NSMutableDictionary*)msg withTableView:(NSTableView*)tableView withRow:(NSInteger)row
{
	if( tableView == self.influxTableView ) {
	}
	else if( self.chatTableView == tableView ) {
		FDChatTableCellView *cell = [tableView makeViewWithIdentifier:@"ChatTableCellView" owner:self];
		if( cell == nil ) {
			cell = [[FDChatTableCellView alloc] initWithFrame:NSMakeRect(0, 0, tableView.frame.size.width, 0)];
			cell.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
			cell.textView = [[FDTextView alloc] initWithFrame:NSMakeRect(80, 0, tableView.bounds.size.width-80, 0)];
			cell.textView.identifier = @"ChatTableViewCell";
			[cell.textView setHorizontallyResizable:NO];
			//cell.textView.textContainerInset = NSMakeSize(0, 1.5);
			cell.textView.menu = [[NSMenu alloc] initWithTitle:@"Debug"];

			cell.usernameField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 80, 0)];
			[cell.usernameField setDrawsBackground:NO];
			[cell.usernameField setBordered:NO];
			[cell.usernameField setBezeled:NO];
			cell.usernameField.textColor = [NSColor colorWithSRGBRed:0.3 green:0.3 blue:0.3 alpha:1.0f];
			[cell addSubview:cell.textView];
			[cell addSubview:cell.usernameField];
		}
		CGRect frame = cell.frame;
		FDMessage *msg = self.messages[row];
		frame.size.height = [msg rowHeightForWidth:tableView.frame.size.width-80];
		cell.frame = frame;
		[cell.textView.textStorage setAttributedString:msg.displayString];
		[cell.textView sizeToFit];
		frame = cell.textView.frame;
		frame.origin.y = 0;
		cell.textView.frame = frame;

		FDUser *user = [self.flow userForID:msg.user];
		FDMessage *nextUser = (row > 0) ? self.messages[row-1] : nil;
		if( nextUser && [nextUser.user isEqualToNumber:user.userID] ) {
			cell.usernameField.stringValue = @"";
		} else {
			cell.usernameField.stringValue = user.nick;
		}
		[cell.usernameField sizeToFit];
		frame = cell.usernameField.frame;
		frame.origin.y = cell.textView.frame.size.height - frame.size.height + 3;
		cell.usernameField.frame = frame;
		if(![msg verifyRowHeightForWidth:cell.frame.size.width withHeight:cell.frame.size.height]) {
			[tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
		}
		return cell;
	}
	return nil;
}
@end
