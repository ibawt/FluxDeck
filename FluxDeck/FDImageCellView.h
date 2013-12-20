//
//  FDImageCellView.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-10-06.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "RBLTableCellView.h"
#import "FDMessage.h"

@interface FDImageCellView : RBLTableCellView

@property (nonatomic,weak) FDMessage *message;
@property (nonatomic,strong) NSImage *image;
@property (nonatomic,assign) BOOL onScreen;
@property (nonatomic,assign) NSTimeInterval lastDrawTime;
@property (nonatomic,assign) BOOL isAnimated;
@property (nonatomic,assign) NSColor *threadColor;

@end
