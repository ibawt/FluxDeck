//
//  FluxDeckViewController.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Rebel.h>

@interface FluxDeckViewController : RBLViewController
-(void)getFlows;
+(FluxDeckViewController*)instance;
@property (nonatomic,strong) NSMutableArray *flowButtons;
@property (nonatomic,weak) IBOutlet RBLView* tabView;
@property (nonatomic,weak) IBOutlet RBLView* flowView;
@property (nonatomic,strong) IBOutlet NSButton* flowSettings;
@property (nonatomic,strong) NSMutableDictionary *users;
@property (nonatomic,strong) NSMutableDictionary *flows;
@property (nonatomic,strong) NSMutableArray *viewControllers;
@end
