//
//  DGListingCollectionViewCell.h
//  DG Open House
//
//  Created by Chase Acton on 2/11/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DGListingCollectionViewCell;

@protocol DGListingCollectionViewCellDelegate <NSObject>

@optional
- (void)deleteButtonPressedInCell:(DGListingCollectionViewCell *)cell;

@end

@interface DGListingCollectionViewCell : UICollectionViewCell

@property (weak) IBOutlet UILabel *addressLabel;
@property (weak) IBOutlet UILabel *mlsNumberLabel;
@property (weak) IBOutlet UIImageView *imageView;
@property (weak) IBOutlet UIButton *deleteButton;

@property (nonatomic, weak) id<DGListingCollectionViewCellDelegate> delegate;

@end