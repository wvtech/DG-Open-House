//
//  DGImageCollectionViewCell.m
//  DG Open House
//
//  Created by Chase Acton on 3/22/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGImageCollectionViewCell.h"

@implementation DGImageCollectionViewCell

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

- (void)prepareForReuse{
    self.imageView.image = nil;
}

@end