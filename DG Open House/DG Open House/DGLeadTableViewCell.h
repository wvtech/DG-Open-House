//
//  DGLeadTableViewCell.h
//  DG Open House
//
//  Created by Chase Acton on 4/24/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DGLeadTableViewCell;

@protocol DGLeadTableViewCellDelegate <NSObject>

@optional
- (void)deleteButtonPressedInTableViewCell:(DGLeadTableViewCell *)cell;

@end

@interface DGLeadTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

@property (nonatomic, weak) IBOutlet UIImageView *cardIcon;

@property (nonatomic, weak) IBOutlet UIImageView *star1ImageView;
@property (nonatomic, weak) IBOutlet UIImageView *star2ImageView;
@property (nonatomic, weak) IBOutlet UIImageView *star3ImageView;
@property (nonatomic, weak) IBOutlet UIImageView *star4ImageView;
@property (nonatomic, weak) IBOutlet UIImageView *star5ImageView;

@property (weak) IBOutlet UIButton *deleteButton;

@property (nonatomic, weak) id<DGLeadTableViewCellDelegate> delegate;

@end