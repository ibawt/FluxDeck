//
//  FDRequestManager.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-09-28.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPRequestOperationManager.h>

@interface FDRequestManager : AFHTTPRequestOperationManager
+(FDRequestManager*)manager;
@end
