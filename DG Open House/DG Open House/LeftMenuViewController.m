//
//  MenuViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <UIImageView+AFNetworking.h>

#import "LeftMenuViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"
#import "DGListingsViewController.h"
#import "DGMenuItemTableViewCell.h"
#import "DGUserManager.h"
#import "DGConstants.h"
#import "SlideNavigationController.h"
#import "CAUpdateChecker.h"
#import "DGEventsViewController.h"
#import "UIImage+DGImage.h"
#import "AFNetworkReachabilityManager.h"
#import "UIImageView+WebCache.h"
@interface LeftMenuViewController ()

@property (nonatomic, weak) IBOutlet UILabel *agentNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *agentTitleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *agentImageView;

@end

@implementation LeftMenuViewController

#pragma mark - UIViewController Methods -

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self.slideOutAnimationEnabled = YES;
    
    return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self loadAgentData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SlideNavigationControllerDidRevealNotification:) name:SlideNavigationControllerDidReveal object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkReachableNotification:) name:DGNetworkReachableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkUnreachableNotification:) name:DGNetworkUnreachableNotification object:nil];
}

- (void)didReceiveNetworkReachableNotification:(NSNotification *)notification{
    [self.tableView reloadData];
}

- (void)didReceiveNetworkUnreachableNotification:(NSNotification *)notification{
    [self.tableView reloadData];
}

- (void)SlideNavigationControllerDidRevealNotification:(NSNotification *)notification{
    [self loadAgentData];
}

- (BOOL)reachable{
    if ([[AFNetworkReachabilityManager sharedManager] isReachable]){
        return YES;
    }
    return NO;
}

- (void)loadAgentData{
    RLMAgent *agent = [DGUserManager sharedInstance].currentAgent;
    
    self.agentNameLabel.text = agent.fullName;
    self.agentTitleLabel.text = agent.title;
    self.agentImageView.layer.cornerRadius = 30;
    
    //Image
    [self performSelectorInBackground:@selector(loadAgentImage:) withObject:agent.photoURL];
}

- (void) loadAgentImage:(NSString *) strUrl {
    if ([self reachable]){
        //Load from url
        
        NSURL * imgUrl = [NSURL URLWithString:[DGBasePhotoURL stringByAppendingString:strUrl]];

        [self.agentImageView sd_setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"default_image"]];
        //     [self.agentImageView setImageWithURL:[NSURL URLWithString:[DGBasePhotoURL stringByAppendingString:agent.photoURL]]];
        
        NSData *data = [NSData dataWithContentsOfURL:imgUrl];
        
        // find Documents directory and append your local filename
        NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        documentsURL = [documentsURL URLByAppendingPathComponent:DGImageKeyAgent];
        
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        documentsPath = [documentsPath stringByAppendingPathComponent:DGImageKeyAgent];
        
        
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:documentsPath];
       // if(!fileExists) { ///  need to download the file
                // and finally save the file
        [data writeToURL:documentsURL atomically:YES];
        //}
        
    }else{
        self.agentImageView.image = [UIImage agentImage];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableView Delegate & Datasrouce -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 3;
    }else if (section == 1){
        return 2;
    }else if (section == 2){
        return 2;
    }else if (section == 3){
        return [self reachable] ? 1 : 0; //Only show log out button if internet available
    }
    return 0;
}

#pragma mark - Header

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 3){
        return 1;
    }
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 3){
        return nil;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.tableView.frame.size.width, 40)];
    
    if (section == 0){
        titleLabel.text = @"LISTINGS";
        
    }else if (section == 1){
        titleLabel.text = @"LEADS";
        
    }else if (section == 2){
        titleLabel.text = @"EVENTS";
    }
    
    [view addSubview:titleLabel];
    return view;
}

#pragma mark - Footer

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 3){
        return nil;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    view.backgroundColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:199.0/255.0 alpha:1.0];
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DGMenuItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCell"];
    cell.titleLabel.textColor = [UIColor blackColor];
    
    if (indexPath.section == 0){
        
        switch (indexPath.row)
        {
            case 0:
                cell.titleLabel.text = @"Active Listings";
                cell.icon.image = [UIImage imageNamed:@"ActiveListings"];
                break;
                
            case 1:
                cell.titleLabel.text = @"Inactive Listings";
                cell.icon.image = [UIImage imageNamed:@"InactiveListings"];
                break;
                
            case 2:
                cell.titleLabel.text = @"Add Open House";
                cell.icon.image = [UIImage imageNamed:@"add-1"];
                break;
        }
        
    }else if (indexPath.section == 1){
        
        switch (indexPath.row)
        {
            case 0:
                cell.titleLabel.text = @"All Leads";
                cell.icon.image = [UIImage imageNamed:@"Leads"];
                break;
                
            case 1:
                cell.titleLabel.text = @"Leads By Property";
                cell.icon.image = [UIImage imageNamed:@"Leads_by_property"];
                break;
        }
        
    }else if (indexPath.section == 2){
        
        switch (indexPath.row)
        {
            case 0:
                cell.titleLabel.text = @"All Events";
                cell.icon.image = [UIImage imageNamed:@"Events"];
                break;
                
            case 1:
                cell.titleLabel.text = @"Add Event";
                cell.icon.image = [UIImage imageNamed:@"add-1"];
                break;
        }
        
    }else if (indexPath.section == 3){
        cell.icon.image = nil;
        
        switch (indexPath.row)
        {
//            case 0:
//                cell.titleLabel.text = @"Safe Agent Profile";
//                cell.icon.image = [UIImage imageNamed:@"wrench"];
//                
//                [cell.icon setTintColor:[UIColor darkGrayColor]];
//                cell.icon.image = [cell.icon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//                break;
                
            case 0:
                cell.titleLabel.text = @"Logout";
                cell.icon.image = [UIImage imageNamed:@"reply"];
                
                [cell.icon setTintColor:[UIColor darkGrayColor]];
                cell.icon.image = [cell.icon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                break;
        }
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [CAUpdateChecker checkForUpdate];

    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIStoryboard *eventStoryboard = [UIStoryboard storyboardWithName:@"Event" bundle: nil];

    DGListingsViewController *home = [mainStoryboard instantiateViewControllerWithIdentifier:@"DGListingsViewController"];
    DGEventsViewController *leads = [eventStoryboard instantiateViewControllerWithIdentifier:@"DGEventsViewController"];

    if (indexPath.section == 0){
        switch (indexPath.row){
            case 0:
                home.showActiveListings = YES;
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:home
                                                                         withSlideOutAnimation:NO
                                                                                 andCompletion:nil];
                break;
                
            case 1:
                home.showActiveListings = NO;
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:home
                                                                         withSlideOutAnimation:NO
                                                                                 andCompletion:nil];
                break;
                
            case 2:
                home.addListing = YES;
                home.showActiveListings = YES;
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:home
                                                                         withSlideOutAnimation:NO
                                                                                 andCompletion:nil];
                break;
        }
        
    }else if (indexPath.section == 1){
        switch (indexPath.row){
            case 0:
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"DGLeadsViewController"]
                                                                         withSlideOutAnimation:NO
                                                                                 andCompletion:nil];
                break;
                
            case 1:
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"DGLeadsByListingViewController"]
                                                                         withSlideOutAnimation:NO
                                                                                 andCompletion:nil];
                break;
        }
        
    }else if (indexPath.section == 2){
        switch (indexPath.row){
            case 0:
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:[eventStoryboard instantiateViewControllerWithIdentifier:@"DGEventsViewController"]
                                                                         withSlideOutAnimation:NO
                                                                                 andCompletion:nil];
                break;
                
            case 1:
                leads.addEvent = YES;
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:leads
                                                                         withSlideOutAnimation:NO
                                                                                 andCompletion:nil];
                break;
        }
        
    }else if (indexPath.section == 3){
        if (indexPath.row == 0){
//            [self openSafeAgentProfile];
            [self promptToSignOut];
            
        }else if (indexPath.row == 1){
            [self promptToSignOut];
        }
    }else{
        [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
    }
}

- (void)promptToSignOut{
    [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
    
    UIAlertController *alert = [UIAlertController
                                  alertControllerWithTitle:@"Sign Out"
                                  message:@"Are you sure you want to sign out?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"Yes"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action){
                             [self signOut];
                             
                         }];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:nil];
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [[self topViewController] presentViewController:alert animated:YES completion:nil];
}

- (UIViewController *)topViewController{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

- (void)openSafeAgentProfile{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"SafeAgent" bundle: nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"DGSafeAgentProfileViewController"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:NO
                                                                     andCompletion:nil];
}

- (void)signOut{
    //Sign out
    [[DGUserManager sharedInstance] signOut];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"DGLoginViewController"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:NO
                                                                     andCompletion:nil];
}

@end