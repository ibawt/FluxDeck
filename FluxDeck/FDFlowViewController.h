//
//  FDFlowViewController.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FDFlow.h"

@interface FDFlowViewController : NSViewController<NSTableViewDataSource,NSTableViewDelegate>

-(IBAction)textEntered:(id)sender;

@property (strong) IBOutlet NSTableView *chatTableView;
@property (strong) IBOutlet NSTableView *userTableView;
@property (strong) IBOutlet NSTableView *influxTableView;
@property (strong) IBOutlet NSString    *lastMessageID;
@property (nonatomic,strong) FDFlow *flow;
@property (nonatomic,strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *influx;
@end
