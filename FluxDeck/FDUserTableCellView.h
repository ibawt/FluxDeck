//
//  FDUserTableCelLView.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-09-29.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "RBLTableCellView.h"

@interface FDUserTableCellView : RBLTableCellView

@property (nonatomic,weak) IBOutlet NSImageView *statusIcon;
@property (nonatomic,weak) IBOutlet NSTextField *username;
@property (nonatomic,weak) IBOutlet NSTextField *lastActivity;

@end
