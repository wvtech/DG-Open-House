//
//  DGAttendeeRatingTableViewCell.m
//  DG Open House
//
//  Created by Chase Acton on 5/1/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGAttendeeRatingTableViewCell.h"

@implementation DGAttendeeRatingTableViewCell

- (IBAction)selectRating:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(didSelectRating:)]){
        [self.delegate didSelectRating:sender.tag];
    }
}

@end