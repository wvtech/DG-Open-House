//
//  DGEventDetailsViewController.m
//  DG Open House
//
//  Created by Chase Acton on 5/5/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIImageView+AFNetworking.h>

#import "DGEventDetailsViewController.h"
#import "DGConstants.h"
#import "AFNetworkReachabilityManager.h"
#import "UIButton+Extensions.h"
#import "SlideNavigationController.h"
#import "DGEvent.h"
#import "UIButton+BackgroundColor.h"
#import "DGUserManager.h"
#import "DGEventSignInViewController.h"
#import "DGLeadsViewController.h"
#import "DGAPI.h"
#import "UIImage+DGImage.h"
#import "DGGalleryViewController.h"
#import "DGEventsManager.h"
#import "RLMEvent.h"
#import "NSUserDefaults+Convenience.h"

@interface DGEventDetailsViewController () <UIScrollViewDelegate>

@property (weak) IBOutlet UIButton *menuButton;
@property (weak) IBOutlet UIButton *safeAgentButton;

@property (weak) IBOutlet UILabel *titleLabel;

@property (weak) IBOutlet UILabel *agentNameLabel;
@property (weak) IBOutlet UILabel *agentTitleLabel;
@property (weak) IBOutlet UILabel *agentPhoneLabel;
@property (weak) IBOutlet UILabel *agentEmailLabel;
@property (weak) IBOutlet UIImageView *agentImageView;

@property (weak) IBOutlet UIButton *photosButton;
@property (weak) IBOutlet UIButton *startButton;
@property (weak) IBOutlet UIButton *leadsButton;

@property (weak) IBOutlet UIImageView *photosIcon;
@property (weak) IBOutlet UIImageView *startIcon;

@property (weak) IBOutlet UIScrollView *scrollView;

@end

@implementation DGEventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkReachableNotification:) name:DGNetworkReachableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkUnreachableNotification:) name:DGNetworkUnreachableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSafeAgentCheckNotification:) name:DGSafeAgentCheckNotification object:nil];
    
    [self.menuButton setHitTestEdgeInsets:UIEdgeInsetsMake(-30, -30, -30, -30)];
    
    RLMEvent *event = [[DGEventsManager sharedInstance] eventWithID:self.selectedEvent.eventID];
    if (event){
        self.titleLabel.text = [NSString stringWithFormat:@"%@ %@",event.name, event.prettyDate];
    }
    
    RLMAgent *agent = [DGUserManager sharedInstance].currentAgent;
    self.agentNameLabel.text = agent.fullName;
    self.agentTitleLabel.text = agent.title;
    self.agentEmailLabel.text = agent.email;
    self.agentImageView.image = [UIImage agentImage];

    if (agent.phone.length == 10){
        NSString *first = [agent.phone substringToIndex:3];
        NSString *second = [agent.phone substringWithRange:NSMakeRange(3, 3)];
        NSString *third = [agent.phone substringFromIndex:6];
        
        self.agentPhoneLabel.text = [NSString stringWithFormat:@"(%@) %@-%@",
                                     first,
                                     second,
                                     third];
        
    }else{
        self.agentPhoneLabel.text = nil;
    }
    
    [self.photosButton makeDGButtonWithIcon];
    [self.startButton makeDGButtonWithIcon];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (![[AFNetworkReachabilityManager sharedManager] isReachable] || ![NSUserDefaults shouldEnableSafeAgent]){
        self.safeAgentButton.hidden = YES;
    }
    
    [self.leadsButton setBackgroundColor:[UIColor colorWithRed:0.8588 green:0.8667 blue:0.8745 alpha:1.0] forState:UIControlStateDisabled];
    
    if (self.selectedEvent.attendees.count == 0){
        self.leadsButton.enabled = NO;
    }else{
        self.leadsButton.enabled = YES;
    }
    
    [self addImages];
}

- (void)didReceiveNetworkReachableNotification:(NSNotification *)notification{
    if ([NSUserDefaults shouldEnableSafeAgent]){
        self.safeAgentButton.hidden = NO;
    }
}

- (void)didReceiveNetworkUnreachableNotification:(NSNotification *)notification{
    self.safeAgentButton.hidden = YES;
}

- (void)didReceiveSafeAgentCheckNotification:(NSNotification *)notification{
    if ([[AFNetworkReachabilityManager sharedManager] isReachable] && [NSUserDefaults shouldEnableSafeAgent]){
        self.safeAgentButton.hidden = NO;
    }
}

- (IBAction)openMenu{
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)openSafeAgent{
    [self performSegueWithIdentifier:ShowSafeAgentSegue sender:self];
}

- (void)addImages{
    // Setup the array of UIImageViews
    NSMutableArray *imgArray = [[NSMutableArray alloc] init];
    UIImageView *tempImageView;
    for (int i = 0; i < [self.selectedEvent.images count]; i++){
        tempImageView = [[UIImageView alloc] init];
        tempImageView.contentMode = UIViewContentModeScaleAspectFill;
        tempImageView.clipsToBounds = YES;
        
        //Image
        if ([self.selectedEvent.images count] > 0){
            RealmString *string = self.selectedEvent.images[i];
            UIImage *image = [UIImage imageWithFilename:string.stringValue];
            tempImageView.image = image;
        }
        
        [imgArray addObject:tempImageView];
    }
    
    for (int i = 1; i < [self.selectedEvent.images count] % 2; i++){
        tempImageView = [[UIImageView alloc] init];
        [imgArray addObject:tempImageView];
    }
    
    NSUInteger page = 0;
    for(UIView *view in imgArray) {
        [self.scrollView addSubview:view];
        
        // This is the important line
        view.frame = CGRectMake((self.view.bounds.size.width/2) * page++,
                                0,
                                self.view.bounds.size.width/2,
                                410);
    }
    
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width/2 * [imgArray count], 410);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"DGStartEventSegue"]){
        DGEventSignInViewController *vc = segue.destinationViewController;
        vc.currentEvent = self.selectedEvent;
        
    }else if ([segue.identifier isEqualToString:@"ShowLeadsSegue"]){
        DGLeadsViewController *vc = segue.destinationViewController;
        vc.selectedEvent = self.selectedEvent;
        
    }else if ([segue.identifier isEqualToString:@"DGShowGallerySegue"]){
        DGGalleryViewController *vc = segue.destinationViewController;
        vc.event = self.selectedEvent;
    }
}

@end