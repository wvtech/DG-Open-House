//
//  DGAttendeeDetailsViewController.h
//  DG Open House
//
//  Created by Chase Acton on 4/24/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RLMAttendee;

@interface DGAttendeeDetailsViewController : UIViewController

@property (nonatomic) RLMAttendee *selectedAttendee;

@end