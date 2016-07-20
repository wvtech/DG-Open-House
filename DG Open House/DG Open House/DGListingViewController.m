//
//  DGListingViewController.m
//  DG Open House
//
//  Created by Chase Acton on 2/11/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIImageView+AFNetworking.h>

#import "DGListingViewController.h"
#import "DGUserManager.h"
#import "DGConstants.h"
#import "DGAPI.h"
#import "DGOpenHouseViewController.h"
#import "UIButton+BackgroundColor.h"
#import "DGQuestionTableViewCell.h"
#import "NSUserDefaults+Convenience.h"
#import "DGLeadsViewController.h"
#import "UIButton+Extensions.h"
#import "AFNetworkReachabilityManager.h"
#import "SVProgressHUD.h"
#import "DGGalleryViewController.h"
#import "UIImage+DGImage.h"

static NSString * const DGImageCellIdentifier = @"DGImageCell";

//Segues
static NSString * const DGShowGallerySegue = @"DGShowGallerySegue";

@interface DGListingViewController () <UIScrollViewDelegate>

@property (weak) IBOutlet UIScrollView *scrollView;

@property (weak) IBOutlet UILabel *addressLabel;
@property (weak) IBOutlet UILabel *statusLabel;

@property (weak) IBOutlet UILabel *agentNameLabel;
@property (weak) IBOutlet UILabel *agentTitleLabel;
@property (weak) IBOutlet UILabel *agentPhoneLabel;
@property (weak) IBOutlet UILabel *agentEmailLabel;
@property (weak) IBOutlet UIImageView *agentImageView;

@property (weak) IBOutlet UIButton *leadsButton;

@property (weak) IBOutlet UIButton *photosButton;
@property (weak) IBOutlet UIButton *shareButton;
@property (weak) IBOutlet UIButton *openHouseButton;

@property (weak) IBOutlet UIImageView *photosIcon;
@property (weak) IBOutlet UIImageView *shareIcon;
@property (weak) IBOutlet UIImageView *openHouseIcon;

@property (weak) IBOutlet NSLayoutConstraint *shareButtonHeightConstraint;

//Select questions
@property (weak) IBOutlet UIView *questionsView;
@property (weak) IBOutlet UITableView *questionsTable;
@property (weak) IBOutlet UIView *overlayView;

@property (weak) IBOutlet UIButton *menuButton;

@property (weak) IBOutlet UIButton *safeAgentButton;

@end

@implementation DGListingViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.menuButton setHitTestEdgeInsets:UIEdgeInsetsMake(-30, -30, -30, -30)];
    
    self.addressLabel.text = self.listing.prettyFullAddress;
    self.statusLabel.text = [NSString stringWithFormat:@"STATUS: %@", self.listing.isActive ? @"ACTIVE" : @"INACTIVE"];
    
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
    [self.shareButton makeDGButtonWithIcon];
    [self.openHouseButton makeDGButtonWithIcon];
    
    self.questionsTable.layer.borderWidth = 1;
    self.questionsTable.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.questionsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (!self.listing.isActive){
        self.photosButton.enabled = NO;
        self.shareButton.enabled = NO;
        self.openHouseButton.enabled = NO;
        
        self.photosButton.layer.borderColor = [UIColor clearColor].CGColor;
        self.shareButton.layer.borderColor = [UIColor clearColor].CGColor;
        self.openHouseButton.layer.borderColor = [UIColor clearColor].CGColor;
        
        self.photosIcon.image = [self.photosIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.shareIcon.image = [self.shareIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.openHouseIcon.image = [self.openHouseIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        self.photosIcon.tintColor = [UIColor whiteColor];
        self.shareIcon.tintColor = [UIColor whiteColor];
        self.openHouseIcon.tintColor = [UIColor whiteColor];
    }
    
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkReachableNotification:) name:DGNetworkReachableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkUnreachableNotification:) name:DGNetworkUnreachableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSafeAgentCheckNotification:) name:DGSafeAgentCheckNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (![[AFNetworkReachabilityManager sharedManager] isReachable] || ![NSUserDefaults shouldEnableSafeAgent]){
        self.safeAgentButton.hidden = YES;
    }
    
    [self.leadsButton setBackgroundColor:[UIColor colorWithRed:0.8588 green:0.8667 blue:0.8745 alpha:1.0] forState:UIControlStateDisabled];
    
    if (self.listing.attendees.count == 0){
        self.leadsButton.enabled = NO;
    }else{
        self.leadsButton.enabled = YES;
    }
    
    [self addImages];
}

- (void)setupShareButton{
    BOOL reachable = [[AFNetworkReachabilityManager sharedManager] isReachable];
    
    //Don't allow promoting event attendees
    if (!reachable){
        self.shareButtonHeightConstraint.constant = 0;
        self.shareButton.hidden = YES;
        self.shareIcon.hidden = YES;
        
    }else{
        self.shareButtonHeightConstraint.constant = 80;
        self.shareButton.hidden = NO;
        self.shareIcon.hidden = NO;
    }
    
    [self.shareButton setNeedsLayout];
}

- (void)didReceiveNetworkReachableNotification:(NSNotification *)notification{
    if ([NSUserDefaults shouldEnableSafeAgent]){
        self.safeAgentButton.hidden = NO;
    }
    [self setupShareButton];
}

- (void)didReceiveNetworkUnreachableNotification:(NSNotification *)notification{
    self.safeAgentButton.hidden = YES;
    [self setupShareButton];
}

- (void)didReceiveSafeAgentCheckNotification:(NSNotification *)notification{
    if ([[AFNetworkReachabilityManager sharedManager] isReachable] && [NSUserDefaults shouldEnableSafeAgent]){
        self.safeAgentButton.hidden = NO;
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Navigation

- (IBAction)openSafeAgent{
    [self performSegueWithIdentifier:ShowSafeAgentSegue sender:self];
}

- (IBAction)share{
    NSString *url = [[NSString stringWithFormat:@"http://www.danielgale.com/listing/%@",self.listing.mlsNumber] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSArray *dataToShare = @[url];
    UIActivityViewController* activityViewController =[[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
//    activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop, UIActivityTypePrint, UIActivityTypePostToVimeo, UIActivityTypeOpenInIBooks, UIActivityTypeSaveToCameraRoll];
    
    activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop,UIActivityTypePrint,UIActivityTypePostToVimeo,UIActivityTypeSaveToCameraRoll];
    
    
    
    [activityViewController setModalPresentationStyle:UIModalPresentationPopover];
    
    UIPopoverPresentationController *popPresenter = [activityViewController popoverPresentationController];
    popPresenter.barButtonItem = self.navigationItem.rightBarButtonItem;
    
    popPresenter.sourceView = self.shareButton;
    popPresenter.sourceRect = self.shareButton.bounds;
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (IBAction)openMenu{
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (IBAction)viewQuestions{
    [self showView:self.questionsView];
    [self showView:self.overlayView];
}

- (IBAction)saveQuestions{
    [self hideView:self.questionsView];
    [self hideView:self.overlayView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ShowOpenHouseSegue"]){
        DGOpenHouseViewController *vc = segue.destinationViewController;
        vc.currentListing = self.listing;
        
    }else if ([segue.identifier isEqualToString:@"ShowLeadsSegue"]){
        DGLeadsViewController *vc = segue.destinationViewController;
        vc.selectedListing = self.listing;
        
    }else if ([segue.identifier isEqualToString:@"DGShowGallerySegue"]){
        DGGalleryViewController *vc = segue.destinationViewController;
        vc.listing = self.listing;
    }
}

- (void)addImages{
    // Setup the array of UIImageViews
    NSMutableArray *imgArray = [[NSMutableArray alloc] init];
    UIImageView *tempImageView;
    
    NSLog(@"[self.listing.images count] = %d", [self.listing.images count]);
    for (int i = 0; i < [self.listing.images count]; i++){
        tempImageView = [[UIImageView alloc] init];
        tempImageView.contentMode = UIViewContentModeScaleAspectFill;
        tempImageView.clipsToBounds = YES;
        
        //Image
        if ([self.listing.images count] > 0){
            RealmString *string = self.listing.images[i];
            UIImage *image = [UIImage imageWithFilename:string.stringValue];
            
            if (image){
                tempImageView.image = image;
            }else{
                NSURL *photoURL = [DGAPI photoForListing:self.listing atIndex:i];
                [tempImageView setImageWithURL:photoURL];
            }
        }
        
        [imgArray addObject:tempImageView];
    }
    
    for (int i = 1; i < [self.listing.images count] % 2; i++){
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

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DGQuestionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuestionCell"];
    
    if (indexPath.row == 0){
        cell.titleLabel.text = @"How soon are you looking to buy?";
        
        if ([NSUserDefaults shouldAskBuyTimeQuestion]){
            cell.icon.image = [UIImage imageNamed:@"Check"];
        }else{
            cell.icon.image = [UIImage imageNamed:@"Check_Gray"];
        }
        
    }else if (indexPath.row == 1){
        cell.titleLabel.text = @"How did you hear about this listing?";
        
        if ([NSUserDefaults shouldAskReferralSourceQuestion]){
            cell.icon.image = [UIImage imageNamed:@"Check"];
        }else{
            cell.icon.image = [UIImage imageNamed:@"Check_Gray"];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0){
        [NSUserDefaults setShouldAskBuyTimeQuestion:![NSUserDefaults shouldAskBuyTimeQuestion]];
        
    }else if (indexPath.row == 1){
        [NSUserDefaults setShouldAskReferralSourceQuestion:![NSUserDefaults shouldAskReferralSourceQuestion]];
    }
    
    [tableView reloadData];
}

#pragma mark - Animation Helpers

- (void)showView:(id)view{
    [self setView:view toAlpha:1];
}

- (void)hideView:(id)view{
    [self setView:view toAlpha:0];
}

- (void)setView:(id)view toAlpha:(CGFloat) alpha{
    UIView *control = (UIView *)view;
    [UIView animateWithDuration:0.15 animations:^{
        control.alpha = alpha;
    }];
}

@end