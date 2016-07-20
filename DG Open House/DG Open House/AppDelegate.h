//
//  AppDelegate.h
//  DG Open House
//
//  Created by Chase Acton on 1/27/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property int intCounter, intPhaseNo;
@property BOOL flagIsLoginFirstTime;
@property (strong, nonatomic) NSMutableArray * arrListingData, * arrAlter;

@end