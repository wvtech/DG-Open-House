//
//  DGLeadTableViewCell.m
//  DG Open House
//
//  Created by Chase Acton on 4/24/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGLeadTableViewCell.h"

@implementation DGLeadTableViewCell

- (IBAction)delete:(id)sender{
    if ([self.delegate respondsToSelector:@selector(deleteButtonPressedInTableViewCell:)]) {
        [self.delegate deleteButtonPressedInTableViewCell:self];
    }
}

@end