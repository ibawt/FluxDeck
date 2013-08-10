//
//  FluxDeckViewController.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FluxDeckViewController : NSViewController<NSTabViewDelegate>
-(void)getFlows;
+(FluxDeckViewController*)instance;


@property (nonatomic,strong) IBOutlet NSTabView *tabView;
@property (nonatomic,strong) NSMutableDictionary *users;
@property (nonatomic,strong) NSMutableDictionary *flows;
@property (nonatomic,strong) NSMutableArray *viewControllers;
@end
