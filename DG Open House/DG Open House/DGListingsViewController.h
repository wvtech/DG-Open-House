//
//  DGListingsViewController.h
//  DG Open House
//
//  Created by Chase Acton on 2/10/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

@interface DGListingsViewController : UIViewController{ //<SlideNavigationControllerDelegate> {

    NSTimer * timer;
    int intTimeCounter;
    
}

@property (nonatomic) NSArray *listings;
@property (nonatomic) BOOL showActiveListings;
@property (nonatomic) BOOL addListing;

@end