//
//  DGAttendeeRatingTableViewCell.h
//  DG Open House
//
//  Created by Chase Acton on 5/1/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DGAttendeeRatingTableViewCellDelegate <NSObject>

@optional
- (void)didSelectRating:(NSInteger)rating;
@end

@interface DGAttendeeRatingTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *keyLabel;

@property (nonatomic, weak) IBOutlet UIButton *star1Button;
@property (nonatomic, weak) IBOutlet UIButton *star2Button;
@property (nonatomic, weak) IBOutlet UIButton *star3Button;
@property (nonatomic, weak) IBOutlet UIButton *star4Button;
@property (nonatomic, weak) IBOutlet UIButton *star5Button;

@property (nonatomic, weak) id<DGAttendeeRatingTableViewCellDelegate>delegate;

@end