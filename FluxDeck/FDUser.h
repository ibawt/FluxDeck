//
//  FDUser.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FDUser : NSObject

-(void)updateFromJSON:(NSObject *)json;

@property (nonatomic,strong) NSString *userID;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSString *nick;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *avatar;
@property (nonatomic,strong) NSString *status;
@property (nonatomic,strong) NSString*disabled;
@property (nonatomic,strong) NSString *lastActivity;
@property (nonatomic,strong) NSString *lastPing;

@end
