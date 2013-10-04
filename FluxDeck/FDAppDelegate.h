//
//  FDAppDelegate.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-10.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FluxDeckViewController.h"

@interface FDAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic,weak) IBOutlet NSView   *mainView;
@property (nonatomic,weak) IBOutlet NSWindow *window;
@property (nonatomic,strong) FluxDeckViewController *viewController;

@end
