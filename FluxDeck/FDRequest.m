//
//  FDRequest.m
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "FDRequest.h"

static const NSString *kUSER_KEY = @"498b1444cbd39f0b03addb2ea7383c75";
static const NSString *kFLOW_DOCK_ENDPOINT = @"https://api.flowdock.com";

@implementation FDRequest

+(FDRequest*)initWithString:(NSString *)url withBlock:(FDRequestCallback)block
{
	FDRequest *req = [[FDRequest alloc] init];
	req.callback = block;
	NSURL *nsurl = nil;

	if( [url hasPrefix:@"http" ] ) {
		nsurl = [NSURL URLWithString:url];
	} else {
		nsurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kFLOW_DOCK_ENDPOINT, url]];
	}
	
	NSURLConnection *urlConn = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:nsurl] delegate:req];

	[urlConn start];
	return req;
}


-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	NSURLCredential *cred = [NSURLCredential credentialWithUser:(NSString*)kUSER_KEY password:@"" persistence:NSURLCredentialPersistencePermanent];

	[challenge.sender useCredential:cred forAuthenticationChallenge:challenge];
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{
	if( self.data == nil ) {
		self.data = [[NSMutableData alloc] initWithData:data];
	} else {
		[self.data appendData:data];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSError *error = nil;

	NSObject *obj = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&error];

	self.callback(obj, nil);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	self.callback(nil, error);
}
@end
