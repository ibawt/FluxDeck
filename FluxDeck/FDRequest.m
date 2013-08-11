//
//  FDRequest.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDRequest.h"

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
		url = [url stringByReplacingOccurrencesOfString:@"api" withString:@"streaming"];
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
	if( self.data == nil ) {
		self.data = [[NSMutableData alloc] initWithData:data];
	} else {
		[self.data appendData:data];

		if( self.isStreaming ) {
			const uint8_t *bytes = self.data.bytes;
			for( int i = (int)self.data.length - 1 ; i >= 0 ; --i ) {
				if( bytes[i] == '\r' ) {
					NSData *d = [NSData dataWithBytesNoCopy:(void*)self.data.bytes length:i-1];
					NSError *error = nil;
					NSObject *o = [NSJSONSerialization JSONObjectWithData:d options:0 error:&error];
					self.callback(o, error);
					[self.data setLength:0];
				}
			}
		}
	}

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSError *error = nil;

	NSObject *obj = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&error];
	self.isActive = false;
	self.callback(obj, nil);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	self.callback(nil, error);
}
@end
