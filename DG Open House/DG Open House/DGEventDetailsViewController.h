//
//  DGEventDetailsViewController.h
//  DG Open House
//
//  Created by Chase Acton on 5/5/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RLMEvent;

@interface DGEventDetailsViewController : UIViewController

@property (nonatomic) RLMEvent *selectedEvent;

@end