//
//  DGAttendeeNotesTableViewCell.h
//  DG Open House
//
//  Created by Chase Acton on 5/1/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGAttendeeNotesTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *keyLabel;
@property (weak) IBOutlet UITextView *notesTextView;

@end