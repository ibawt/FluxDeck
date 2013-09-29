//
//  FDFlowViewController.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FDFlow.h"
#import <Rebel.h>

@interface FDFlowViewController : RBLViewController<NSTableViewDataSource,NSTableViewDelegate>

-(IBAction)textEntered:(id)sender;


@property (nonatomic,strong) IBOutlet NSTextField *titleField;
@property (nonatomic,strong) IBOutlet RBLView *inputView;
@property (nonatomic,strong) IBOutlet RBLView *userView;
@property (nonatomic,strong) IBOutlet RBLScrollView *messageView;
@property (nonatomic,strong) IBOutlet RBLView *titleView;
@property (strong) IBOutlet RBLTableView *chatTableView;
@property (strong) IBOutlet RBLTableView *userTableView;
@property (strong) IBOutlet NSTableView *influxTableView;
@property (strong) IBOutlet NSString    *lastMessageID;
@property (nonatomic,strong) FDFlow *flow;
@property (nonatomic,strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *influx;
@end
