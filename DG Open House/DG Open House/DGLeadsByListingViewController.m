//
//  DGLeadsByListingViewController.m
//  DG Open House
//
//  Created by Chase Acton on 4/25/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGLeadsByListingViewController.h"
#import "DGListingsManager.h"
#import "DGLeadListingTableViewCell.h"
#import "SlideNavigationController.h"
#import "DGLeadsViewController.h"
#import "UIButton+Extensions.h"
#import "DGConstants.h"
#import "AFNetworkReachabilityManager.h"
#import "RLMListing.h"
#import "NSUserDefaults+Convenience.h"

@interface DGLeadsByListingViewController ()

@property (nonatomic) NSMutableArray *listings;

@property (weak) IBOutlet UITableView *tableView;

@property (weak) IBOutlet UIButton *menuButton;

@property (weak) IBOutlet UIButton *safeAgentButton;

//Search
@property (nonatomic) BOOL isSearching;
@property (nonatomic) BOOL shouldBeginEditing;
@property (nonatomic) NSArray *searchResults;
@property (weak) IBOutlet UISearchBar *searchBar;
@end

@implementation DGLeadsByListingViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkReachableNotification:) name:DGNetworkReachableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkUnreachableNotification:) name:DGNetworkUnreachableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSafeAgentCheckNotification:) name:DGSafeAgentCheckNotification object:nil];
    
    self.listings = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    [self.menuButton setHitTestEdgeInsets:UIEdgeInsetsMake(-30, -30, -30, -30)];
    
    if (![[AFNetworkReachabilityManager sharedManager] isReachable] || ![NSUserDefaults shouldEnableSafeAgent]){
        self.safeAgentButton.hidden = YES;
    }
    
    [self setupLeads];
}

- (void)setupLeads{
    [self.listings removeAllObjects];
    
    for (RLMListing *listing in [DGListingsManager sharedInstance].activeListings){
        if ([listing.attendees count] > 0){
            [self.listings addObject:listing];
        }
    }
    
    [self.tableView reloadData];
}

- (IBAction)openSafeAgent{
    [self performSegueWithIdentifier:ShowSafeAgentSegue sender:self];
}

- (IBAction)openMenu{
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
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

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UISearchBar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.isSearching = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(![searchBar isFirstResponder]) {
        // user tapped the 'clear' button
        self.shouldBeginEditing = NO;
        [self.tableView setContentOffset:CGPointZero animated:YES];
    }

    if([searchText length] != 0){
        [self search];
        
    }else{
        self.isSearching = NO;
    }
    
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.isSearching = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self search];
}

- (void)search{
    self.isSearching = YES;
    self.searchResults = [self.listings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"prettyFullAddress contains[c] %@", self.searchBar.text]];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)bar {
    BOOL boolToReturn = self.shouldBeginEditing;
    self.shouldBeginEditing = YES;
    return boolToReturn;
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isSearching){
        return [self.searchResults count];
    }else{
        return [self.listings count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DGLeadListingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeadCell"];
    
    RLMListing *listing;
    
    if (self.isSearching){
        listing = self.searchResults[indexPath.row];
    }else{
        listing = self.listings[indexPath.row];
    }
    
    cell.propertyLabel.text = listing.prettyAddress;
    cell.mlsLabel.text = listing.mlsNumber;
    cell.leadCountLabel.text = [NSString stringWithFormat:@"%@", @(listing.attendees.count)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.view endEditing:YES];
    
    RLMListing *listing;
    
    if (self.isSearching){
        listing = self.searchResults[indexPath.row];
    }else{
        listing = self.listings[indexPath.row];
    }
    
    [self performSegueWithIdentifier:@"ShowLeadsSegue" sender:listing];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ShowLeadsSegue"]){
        DGLeadsViewController *vc = segue.destinationViewController;
        vc.selectedListing = (RLMListing *)sender;
    }
}

@end