//
//  FDRequest.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDRequest.h"
#import <FXKeychain.h>

static const NSString *kFLOW_DOCK_ENDPOINT = @"https://api.flowdock.com";

@interface FDRequest ()
@property (assign) BOOL isStreaming;
@end


@implementation FDRequest


-(id)init
{
	if( self = [super init] ) {
		self.isStreaming = false;
	}
	return self;
}

+(FDRequest*)initWithString:(NSString *)url withBlock:(FDRequestCallback)block
{
	return [FDRequest initWithString:url withBlock:block forStreaming:NO];
}

+(FDRequest*)initWithString:(NSString *)url withBlock:(FDRequestCallback)block withData:(NSData*)data
{
	FDRequest *req = [[FDRequest alloc] init];
	req.isStreaming = NO;
	req.callback = block;

	NSURL *nsurl = [NSURL URLWithString:url];

	NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:nsurl];
	[urlReq setHTTPBody:data];
	[urlReq setHTTPMethod:@"POST"];
	[urlReq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	NSString *length = [NSString stringWithFormat:@"%ld",data.length];
	[urlReq setValue:length forHTTPHeaderField:@"Content-Length"];

	NSURLConnection *urlConn = [[NSURLConnection alloc] initWithRequest:urlReq delegate:req];
	[urlConn start];
	return req;
}

+(FDRequest*)initWithString:(NSString *)url withBlock:(FDRequestCallback)block forStreaming:(BOOL)streaming
{
	FDRequest *req = [[FDRequest alloc] init];
	req.isStreaming = streaming;
	req.callback = block;
	NSURL *nsurl = nil;

	if(! [url hasPrefix:@"http" ] ) {
		url = [NSString stringWithFormat:@"%@/%@", kFLOW_DOCK_ENDPOINT, url];
	}

	if( streaming ) {
		url = [url stringByReplacingOccurrencesOfString:@"api" withString:@"stream"];
	}

	nsurl = [NSURL URLWithString:url];
	
	NSURLConnection *urlConn = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:nsurl] delegate:req];

	[urlConn start];
	req.isActive = YES;
	return req;
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if( [challenge previousFailureCount] ) {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"api_key"];
	}
	NSString *key = [[NSUserDefaults standardUserDefaults] objectForKey:@"api_key"];

	if( !key ) {
		NSAlert *alert = [NSAlert alertWithMessageText:@"Auth Failure" defaultButton:@"Ok" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"API Key: "];
		NSTextField *text = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 280, 30)];
		[alert setAccessoryView:text];

		NSInteger ret = [alert runModal];

		if( ret == NSAlertDefaultReturn ) {
			key = text.stringValue;
			[[NSUserDefaults standardUserDefaults] setObject:key forKey:@"api_key"];
		}
	}
	NSURLCredential *cred = [NSURLCredential credentialWithUser:key password:@"" persistence:NSURLCredentialPersistencePermanent];

	[challenge.sender useCredential:cred forAuthenticationChallenge:challenge];
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{
	if( [data length] == 1 && ((char*)data.bytes)[0] == '\n') {
		return;
	}
	if( self.data == nil ) {
		self.data = [[NSMutableData alloc] initWithData:data];
	} else {

		[self.data appendData:data];

		if( self.isStreaming ) {
			const uint8_t *left = self.data.bytes;
			const uint8_t *right = left;
			int bytesWritten = 0;
			for( int i = 0; i < self.data.length ; ++i ) {
				if( *right == '\r' ) {
					NSData *d = [NSData dataWithBytes:(void*)left length:(right - left)];
					bytesWritten += right - left;
					left = right + 1;
					right += 2;
					NSError *error = nil;
					self.callback(d, error);
				} else {
					right++;
				}
			}
			self.data = [[NSMutableData alloc] initWithBytes:self.data.bytes + bytesWritten length:self.data.length -bytesWritten];
		}
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	self.isActive = false;
	self.callback(self.data, nil);
	self.callback = nil;
	self.data = nil;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	self.isActive = NO;
	self.callback(nil, error);
	self.callback = nil;
	self.data = nil;
}
@end
