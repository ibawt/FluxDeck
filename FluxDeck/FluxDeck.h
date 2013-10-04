//
//  FluxDeck.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-09-28.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FDFlow.h"
#import "FDMessage.h"
#import "FDUser.h"
#import "FDUserTableCellView.h"
#import "FDChatTableCellView.h"
#import "FDFlowViewController.h"
#import "FluxDeckViewController.h"

NSValueTransformer* FDTimestampValueTransformer(void);
NSValueTransformer* FDBooleanValueTransformer(void);

#define kFDChatLinePadding 7.0f

extern int ddLogLevel;
