//
//  FDTextView.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-08-17.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FDUser.h"

extern const NSString* kFDUserLinkAttribute;

@class FDTextView;

typedef void (^FDTextViewLinkClicked)(FDUser*user, FDTextView *view);

@interface FDTextView : NSTextView

@property (assign) FDTextViewLinkClicked linkBlock;

@end
