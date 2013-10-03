//
//  FDChatTableCellView.h
//  FluxDeck
//
//  Created by Ian Quick on 2013-10-02.
//  Copyright (c) 2013 Ian Quick. All rights reserved.
//

#import "RBLTableCellView.h"

@interface FDChatTableCellView : RBLTableCellView

@property (nonatomic,strong) NSTextView *textView;
@property (nonatomic,strong) NSTextField *usernameField;

@end
