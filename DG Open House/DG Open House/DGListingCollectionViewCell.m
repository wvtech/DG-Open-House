//
//  DGListingCollectionViewCell.m
//  DG Open House
//
//  Created by Chase Acton on 2/11/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGListingCollectionViewCell.h"

@implementation DGListingCollectionViewCell

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

- (void)prepareForReuse{
    self.imageView.image = nil;
}

- (IBAction)delete:(id)sender{
    if ([self.delegate respondsToSelector:@selector(deleteButtonPressedInCell:)]) {
        [self.delegate deleteButtonPressedInCell:self];
    }
}

@end