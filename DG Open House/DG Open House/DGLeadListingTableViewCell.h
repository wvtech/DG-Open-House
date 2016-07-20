//
//  DGLeadListingTableViewCell.h
//  DG Open House
//
//  Created by Chase Acton on 4/26/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGLeadListingTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *propertyLabel;
@property (nonatomic, weak) IBOutlet UILabel *mlsLabel;
@property (nonatomic, weak) IBOutlet UILabel *leadCountLabel;

@end