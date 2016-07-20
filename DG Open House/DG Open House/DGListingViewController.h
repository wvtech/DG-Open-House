//
//  DGListingViewController.h
//  DG Open House
//
//  Created by Chase Acton on 2/11/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RLMListing.h"
#import "SlideNavigationController.h"

@interface DGListingViewController : UIViewController <SlideNavigationControllerDelegate>

@property (nonatomic) RLMListing *listing;

@end