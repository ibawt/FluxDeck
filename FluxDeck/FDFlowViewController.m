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
#import "FDTextView.h"
#import <WebKit/WebKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FDRequestManager.h"
#import "FDUserTableCellView.h"
#include <math.h>

#import "LBYouTube.h"

static NSString *kBUILDOK_ICON = @"https://d2cxspbh1aoie1.cloudfront.net/avatars/ac9a7ed457c803acfe8d29559dd9b911/120";

NSAttributedString * makeAttributeStringFromHTML(NSString *html)
{
	NSData *d = [html dataUsingEncoding:NSUTF8StringEncoding];
	return [[NSAttributedString alloc] initWithString:html];
}


const NSString *kFDUserLinkAttribute = @"FDUserLink";

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

-(void)awakeFromNib
{
	self.chatTableView = [[RBLTableView alloc] initWithFrame:self.messageView.bounds];
	RBLClipView *clipView = [[RBLClipView alloc] initWithFrame:self.messageView.bounds];
	[self.messageView setContentView:clipView];
	NSNib *nib = [[NSNib alloc] initWithNibNamed:@"FDUserTableCellView" bundle:[NSBundle mainBundle]];
	[self.userTableView registerNib:nib forIdentifier:@"FDUserTableCellView"];
}


-(NSAttributedString*)parseMessageContent:(NSDictionary*)fd
{
  @try {
    NSError *error = nil;

    NSString *str;

    str = fd[@"content"];
	  NSString *userString = nil;
	  NSObject *o = fd[@"user"];
	  if(! [o respondsToSelector:@selector(stringValue)] ) {
		  NSLog(@"argh");
		  userString = o;
	  }
	  FDUser *user = FDGetUserFromID(userString ? userString : [fd[@"user"] stringValue]);

    str = [NSString stringWithFormat:@"%@: %@", user.name, str];

    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:(NSTextCheckingTypes)NSTextCheckingTypeLink error:&error];

    NSArray *matches = [linkDetector matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:str];

    NSMutableDictionary *linkAttr = [[NSMutableDictionary alloc] init];

    linkAttr[NSForegroundColorAttributeName] = [NSColor colorWithSRGBRed:1.0f green:0.5f blue:0.2f alpha:1.0f],
      linkAttr[NSCursorAttributeName] = [NSCursor pointingHandCursor];
    linkAttr[NSFontAttributeName] =[NSFont boldSystemFontOfSize:12.0];
    if( user ) {
      linkAttr[kFDUserLinkAttribute] = user;
    }
    [attrString addAttributes:linkAttr range:NSMakeRange(0, user.name.length )];
    for (NSTextCheckingResult *match in matches) {
      if (match.URL) {
		NSDictionary *linkAttributes = @{
		NSLinkAttributeName: match.URL,
		};
		[attrString addAttributes:linkAttributes range:match.range];
      }
    }
    return attrString;
  } @catch (NSException *e) {
    NSLog(@"%@", e);
		
  }
  return [[NSAttributedString alloc] initWithString:@""];
}

-(void)fetchMessages:(NSDictionary*)options
{
	[[FDRequestManager manager] GET:self.flow.url parameters:@{ @"limit" : @"100" } success:^(AFHTTPRequestOperation *op, NSDictionary* response) {
		
	} failure:^(AFHTTPRequestOperation *op, NSError *error) {

	}];
	/*
	@try {
  BOOL stream = [self.messages count] != 0;
  NSString *url;

  if( stream ) {
    url = [NSString stringWithFormat:@"%@", self.flow.url];
  }
  else if( self.lastMessageID) {
    url = [NSString stringWithFormat:@"%@/messages?limit=100&since_id=%@", self.flow.url, self.lastMessageID];
  } else {
    url = [NSString stringWithFormat:@"%@/messages?limit=100", self.flow.url];
  }
	
  self.requestStream = [FDRequest initWithString:url withBlock:^(NSObject *object, NSError *error){
	  if( error ) {
		  [self performSelectorOnMainThread:@selector(fetchMessages) withObject:nil waitUntilDone:NO];
	  } else {
		  [self.chatTableView beginUpdates];
		  [self.influxTableView beginUpdates];
		  if( [object isKindOfClass:[NSDictionary class]]) {
			  [self parseEvent:(NSMutableDictionary*)object];
		  } else {
			  for( NSMutableDictionary *d in (NSArray*)object) {
				  [self parseEvent:d];
			  }
		  }
		  [self.chatTableView endUpdates];
		  [self.influxTableView endUpdates];
		  [self.chatTableView reloadData];
		  [self.influxTableView reloadData];
		  if( !stream ) {
			  [self.chatTableView scrollRowToVisible:[self.messages count] -1 ];
			  [self performSelector:@selector(fetchMessages) withObject:nil afterDelay:5];
		  }
	  }
	} forStreaming:stream];
	} @catch (NSException *e) {
		// try again
		[self performSelectorOnMainThread:@selector(fetchMessages) withObject:nil waitUntilDone:NO];
	}
	 */
}


-(void)parseEvent:(NSMutableDictionary*)event
{
  NSString *app = event[@"app"];

  if(  !app || [app isKindOfClass:[NSNull class]]) {
    return;
  }

  if( [app isEqualToString:@"chat"]) {
    if( [event[@"event"] isEqualToString:@"message"] ) {
      [self.messages addObject:event];
      NSArray *tags = (NSArray*)event[@"tags"];
      BOOL hasURL = false;
      for( NSString *t in tags ) {
		//NSLog(@"tag = %@", t);
		if( [t isEqualToString:@":url"]) {
		  hasURL = true;
		  break;
		}
      }

      NSAttributedString *str = [self parseMessageContent:event];
	  event[@"attributedString"] = str;
      if( hasURL ) {
		NSAttributedString *content = str;
		[content enumerateAttributesInRange:NSMakeRange(0, content.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
			if( [attrs objectForKey:@"NSLink"]) {
			  NSURL *link = attrs[@"NSLink"];
			  NSLog(@"abs string: %@", link.absoluteString);
			  if( [link.absoluteString  hasPrefix:@"http://www.youtube.com"]) {
				LBYouTubeExtractor *lb = [[LBYouTubeExtractor alloc] initWithURL:link quality:LBYouTubeVideoQualityLarge];
				[lb extractVideoURLWithCompletionBlock:^(NSURL*url, NSError*error) {
					event[@"youtube_link"] = url;

				  }];
			  }
			}
		  }];

      }

    } else if( [event[@"event"] isEqualToString:@"file"]) {
      [self.messages addObject:event];
    }
    else {
      //NSLog(@"%@", event.description);
    }
  }
  else if( [ app isEqualToString:@"influx"]) {
    [self.influx addObject:event];
  }
  else {
  }
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
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	if( tableView == self.chatTableView ) {
		NSMutableDictionary *msg = [self.messages objectAtIndex:row];
		return [self makeChatCell:msg withTableView:tableView withRow:row];
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

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	if( tableView == self.chatTableView ) {
		NSDictionary* msg = [self.messages objectAtIndex:row];

		if( msg[@"youtube_link"]) {
			return 256;
		}

		if( msg[@"textHeight"] ) {
			return MAX(1,[(NSNumber*)msg[@"textHeight"] floatValue]);
		}
		if( [msg[@"event"] isEqualToString:@"message"] ) {
			NSAttributedString *str = msg[@"attributedString"];

			NSRect bounds = [str boundingRectWithSize: NSMakeSize(tableView.bounds.size.width, 0) options: NSStringDrawingUsesLineFragmentOrigin];

			return bounds.size.height + 15;
		} else if( [msg[@"event"] isEqualToString:@"file"] ) {
			NSString *height = msg[@"content"][@"image"][@"height"];
			NSString *width = msg[@"content"][@"image"][@"width"];
			NSSize size = NSMakeSize([width floatValue], [height floatValue]);
			if( size.width > self.chatTableView.frame.size.width ) {
				size.height = self.chatTableView.frame.size.width * size.height / size.width;
			}
			return MAX(1,size.height);
		}

	} else if( tableView == self.influxTableView) {
		NSDictionary *msg = self.influx[row];
		if( msg[@"textHeight"] ) {
			return [msg[@"textHeight"] floatValue];
		} else {
			NSString *html = nil;
			NSMutableDictionary *msg = [self.influx objectAtIndex:row];
			if( [msg[@"event"] isEqualToString:@"vcs"] ) {
				html = @"vcs";
			}else {
				NSDictionary *m = msg[@"content"];
				html = m[@"content"];
			}
			if( !html ) {
				html = @"";
			}
			NSAttributedString *attrString = makeAttributeStringFromHTML(html);

			msg[@"attributedString"] = attrString;
			NSRect bounds = [attrString boundingRectWithSize:NSMakeSize(tableView.bounds.size.width, 0) options:NSStringDrawingUsesLineFragmentOrigin];
			bounds.size.height = MIN(256, bounds.size.height );
			msg[@"textHeight"] = [NSNumber numberWithFloat:bounds.size.height+15];
			return bounds.size.height + 15;
		}
	}
	return 22;
}

-(NSView*)makeChatCell:(NSMutableDictionary*)msg withTableView:(NSTableView*)tableView withRow:(NSInteger)row
{
	if( tableView == self.influxTableView ) {
		NSView *uberCell = [[NSView alloc] init];
		FDTextView *cell = nil;
		//NSLog(@"%@", msg.description);
		cell = [tableView makeViewWithIdentifier:@"TextChatCell" owner:self];
		if( cell == nil ) {
			cell = [[FDTextView alloc] initWithFrame:NSMakeRect(0, 0, self.influxTableView.bounds.size.width, 0)];
			[cell setHorizontallyResizable:NO];
			cell.identifier = @"TextChatCell";
		}
		NSAttributedString *attr = nil;

		if( [msg[@"event"] isEqualToString:@"vcs"]) {
			attr = [[NSAttributedString alloc] initWithString:@"vcs"];
		} else {
			NSDictionary *content = msg[@"content"];
			NSDictionary *from = content[@"from"][0];

			if( [from[@"address"] isEqualToString:@"build+ok@flowdock.com"])  {
				NSImageView *iv = [[NSImageView alloc] init];
				//			[FDImageCache getDataForURL:kBUILDOK_ICON onComplete:^(NSData *data, NSError *error) {
				//				NSImage *image = [[NSImage alloc] initWithData:data];
				//				iv.image = image;
				//			}
				//			 ];
				[uberCell addSubview:iv];
				//return uberCell;
			}
			attr = msg[@"attributedString"];
		}

		[cell.textStorage setAttributedString:attr];
		[cell sizeToFit];
		[cell setTextContainerInset:NSMakeSize(3, 3)];
		[tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
		msg[@"textHeight"] = [NSNumber numberWithFloat:cell.frame.size.height];

		return cell;

	}
	else if( [msg[@"event"] isEqualToString:@"message"] ) {

		if( [msg[@"content"] hasSuffix:@"png"]  || [msg[@"content"] rangeOfString:@".gif"].length > 0) {
			NSImageView *iv = [tableView makeViewWithIdentifier:@"ImageCell" owner:self];
			if( iv == nil ) {
				iv = [[NSImageView alloc] init];
				iv.identifier = @"ImageCell";
			}
			if( msg[@"cached_image"] ) {
				iv.image = msg[@"cached_image"];
			} else {
				//			  [FDImageCache getDataForURL:msg[@"content"] onComplete:^(NSData *data, NSError *error){
				//				  if( data ) {
				//					  NSImage *image = [[NSImage alloc] initWithData:data];
				//					  iv.image = image;
				//					  msg[@"textHeight"] = [NSNumber numberWithFloat:iv.image.size.height];
				//					  [tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
				//				  }
				//
				//		  }];
			}

			return iv;
		}
		if( msg[@"youtube_link"] ) {
			NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, self.chatTableView.frame.size.width, 256)];
			[view setWantsLayer:YES];
			AVPlayer *av = [AVPlayer playerWithURL:msg[@"youtube_link"]];
			AVPlayerLayer *avp = [AVPlayerLayer playerLayerWithPlayer:av];
			[avp setFrame:view.frame];
			[view.layer addSublayer:avp];
			[tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
			return view;
		}
		FDTextView *cell = nil;
		cell = [tableView makeViewWithIdentifier:@"TextChatCell" owner:self];
		if( cell == nil ) {
			cell = [[FDTextView alloc] initWithFrame:NSMakeRect(0, 0, self.chatTableView.bounds.size.width, 0)];
			[cell setHorizontallyResizable:NO];
			cell.identifier = @"TextChatCell";
		}
		NSAttributedString *attr = msg[@"attributedString"];
		[cell.textStorage setAttributedString:attr];
		[cell sizeToFit];
		[cell setTextContainerInset:NSMakeSize(7, 7)];
		[tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
		msg[@"textHeight"] = [NSNumber numberWithFloat:cell.frame.size.height];

		return cell;
	} else if( [msg[@"event"] isEqualToString:@"file"] ) {
		if( msg[@"content"][@"image"] ) {
			NSImageView *iv = [tableView makeViewWithIdentifier:@"ImageCell" owner:self];
			if( iv == nil ) {
				iv = [[NSImageView alloc] init];
				iv.identifier = @"ImageCell";
			}
			//      [FDImageCache getDataForURL:[NSString stringWithFormat:@"https://api.flowdock.com/%@", msg[@"content"][@"path"] ]onComplete:^(NSData *data, NSError *error){
			//		  iv.image = [[NSImage alloc] initWithData:data];
			//		}];
			return iv;
		}

	}
	return nil;
}
@end
