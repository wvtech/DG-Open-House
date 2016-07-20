//
//  DGGalleryViewController.h
//  DG Open House
//
//  Created by Chase Acton on 5/8/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RLMListing.h"
#import "RLMEvent.h"

@interface DGGalleryViewController : UIViewController

@property (nonatomic) RLMListing *listing;
@property (nonatomic) RLMEvent *event;

@end