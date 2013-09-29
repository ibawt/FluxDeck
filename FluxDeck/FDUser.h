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
@property (nonatomic,strong) NSString *nick;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *avatar;
@property (nonatomic,strong) NSString *status;
@property (nonatomic,strong) NSNumber *disabled;
@property (nonatomic,strong) NSDate *lastActivity;
@property (nonatomic,strong) NSDate *lastPing;

-(BOOL)isIdle;
@end


FDUser *FDGetUserFromID(NSString *userID);
