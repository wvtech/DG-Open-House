//
//  DGLeadsViewController.h
//  DG Open House
//
//  Created by Chase Acton on 4/24/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RLMListing.h"
#import "RLMEvent.h"

@interface DGLeadsViewController : UIViewController

@property (nonatomic) RLMListing *selectedListing;
@property (nonatomic) RLMEvent *selectedEvent;

@end