//
//  DGAttendeeTableViewCell.h
//  DG Open House
//
//  Created by Chase Acton on 4/23/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGAttendeeTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *star1ImageView;
@property (nonatomic, weak) IBOutlet UIImageView *star2ImageView;
@property (nonatomic, weak) IBOutlet UIImageView *star3ImageView;
@property (nonatomic, weak) IBOutlet UIImageView *star4ImageView;
@property (nonatomic, weak) IBOutlet UIImageView *star5ImageView;

@end