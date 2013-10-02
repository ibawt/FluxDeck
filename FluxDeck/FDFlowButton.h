//
//  FDFlowButton.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-09-28.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "RBLView.h"


typedef void (^FDButtonCallback)(void);

@interface FDFlowButton : RBLView

@property (nonatomic,strong) IBOutlet NSButton* button;
@property (nonatomic,strong) IBOutlet NSImageView *lock;
@property (nonatomic,strong) IBOutlet NSImageView *close;

@property (nonatomic,strong) FDButtonCallback callback;
@end
