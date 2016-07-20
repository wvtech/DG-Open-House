//
//  DGSelectLeadTableViewCell.h
//  DG Open House
//
//  Created by Chase Acton on 5/4/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGSelectLeadTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *icon;

@end