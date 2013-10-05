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
-(IBAction)attachFilePushed:(id)sender;
@property (nonatomic,weak) IBOutlet NSTextField *titleField;
@property (nonatomic,weak) IBOutlet RBLView *userView;
@property (nonatomic,weak) IBOutlet RBLView *titleView;
@property (nonatomic,weak) IBOutlet RBLTableView *chatTableView;
@property (nonatomic,weak) IBOutlet RBLTableView *userTableView;
@property (nonatomic,weak) IBOutlet NSTableView *influxTableView;
@property (nonatomic,strong) NSNumber *lastMessageID;
@property (nonatomic,strong) FDFlow *flow;
@property (nonatomic,strong) NSMutableArray *messages;
@property (nonatomic,strong) NSMutableArray *influx;
@property (nonatomic,assign) BOOL onScreen;

@end
