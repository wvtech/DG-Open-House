//
//  DGAttendeeKeyValueTableViewCell.h
//  DG Open House
//
//  Created by Chase Acton on 4/30/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGAttendeeKeyValueTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *keyLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;

@end