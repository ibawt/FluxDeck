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

@property (assign) IBOutlet NSView   *mainView;
@property (assign) IBOutlet NSWindow *window;
@property (nonatomic,strong) IBOutlet FluxDeckViewController *viewController;
@end
