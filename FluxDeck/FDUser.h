//
//  FDUser.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>

@interface FDUser : MTLModel<MTLJSONSerializing>

@property (nonatomic,copy) NSNumber *userID;
@property (nonatomic,copy) NSString *email;
@property (nonatomic,copy) NSString *nick;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *avatar;
@property (nonatomic,copy) NSString *status;
@property (nonatomic,copy) NSNumber *disabled;
@property (nonatomic,copy) NSDate *lastActivity;
@property (nonatomic,copy) NSDate *lastPing;

-(BOOL)isIdle;
@end


FDUser *FDGetUserFromID(NSString *userID);
