//
//  DGListingsViewController.m
//  DG Open House
//
//  Created by Chase Acton on 2/10/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIImageView+AFNetworking.h>

#import "DGListingsViewController.h"
#import "DGAddListingCollectionViewCell.h"
#import "DGListingCollectionViewCell.h"
#import "DGListingViewController.h"
#import "UIColor+DGColor.h"
#import "DGAPI.h"
#import "SlideNavigationController.h"
#import "DGListingsManager.h"
#import "SGConstants.h"
#import "UIButton+Extensions.h"
#import "DGConstants.h"
#import "AFNetworkReachabilityManager.h"
#import "NSUserDefaults+Convenience.h"
#import "DGUserManager.h"
#import "CAUpdateChecker.h"
#import "SVProgressHUD.h"
#import "UIButton+BackgroundColor.h"
#import "UITextField+Utilities.h"
#import "IQKeyboardManager.h"
#import "NSString+Utilities.h"
#import "UIImage+DGImage.h"
#import "DGSyncService.h"
//Cells
static NSString * const DGAddListingCellIdentifier      = @"DGAddListingCell";
static NSString * const DGListingCellIdentifier         = @"DGListingCell";

//Segues
static NSString * const DGShowListingSegue              = @"ShowListingSegue";

@interface DGListingsViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, DGListingCollectionViewCellDelegate>

@property (weak) IBOutlet UICollectionView *listingsCollectionView;
@property (weak) IBOutlet UILabel *titleLabel;
@property (weak) IBOutlet UILabel *statusLabel;

@property (weak) IBOutlet UIButton *menuButton;
@property (weak) IBOutlet UIButton *safeAgentButton;

@property (nonatomic) RLMListing *listingToAdd;

@property (weak) IBOutlet UIView *overlayView;

//Confirm add listing view
@property (weak) IBOutlet UIView *confirmView;
@property (weak) IBOutlet UILabel *confirmAddressLabel;
@property (weak) IBOutlet UILabel *confirmStatusLabel;
@property (weak) IBOutlet UIButton *confirmCancelButton;
@property (weak) IBOutlet UIButton *confirmAddButton;
@property (weak) IBOutlet UIImageView *confirmListingImageView;

//Manual add event
@property (weak) IBOutlet UIView *manualView;
@property (weak) IBOutlet UITextField *mlsField;
@property (weak) IBOutlet UITextField *addressField;
@property (weak) IBOutlet UITextField *townField;
@property (weak) IBOutlet UITextField *stateField;
@property (weak) IBOutlet UITextField *zipField;
@property (weak) IBOutlet UILabel *errorLabel;

@property (weak) IBOutlet UIButton *manualCancelButton;
@property (weak) IBOutlet UIButton *manualAddButton;

//Search
@property (nonatomic) BOOL isSearching;
@property (nonatomic) BOOL shouldBeginEditing;
@property (nonatomic) NSArray *searchResults;
@property (weak) IBOutlet UISearchBar *searchBar;

@end

@implementation DGListingsViewController

#pragma mark - View lifecycle

- (IBAction)openMenu{
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.menuButton setHitTestEdgeInsets:UIEdgeInsetsMake(-30, -30, -30, -30)];
   
   // [self loadData];
 //   [self performSelectorInBackground:@selector(loadData) withObject:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"Loaddata" object:nil];
    
    if ([self shouldUpdateProfile]){
        [self openSafeAgentProfile];
    }
    
    if (![[AFNetworkReachabilityManager sharedManager] isReachable] || ![NSUserDefaults shouldEnableSafeAgent]){
        self.safeAgentButton.hidden = YES;
    }
    
    [CAUpdateChecker checkForUpdate];
}

- (void)viewDidAppear:(BOOL)animated {
   // [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateAllData:) userInfo:nil repeats:YES];
   
    [self loadData];
}

- (int) updateAllData:(NSTimer *) timer1{
    
   
    return 0;
}

- (void)didReceiveSafeAgentCheckNotification:(NSNotification *)notification{
    if ([[AFNetworkReachabilityManager sharedManager] isReachable] && [NSUserDefaults shouldEnableSafeAgent]){
        self.safeAgentButton.hidden = NO;
    }
}

- (void)loadData{
    if (self.addListing){
        [self configureViewForAddListing];
        
    }else{
        if (self.showActiveListings){
            [self configureViewForActiveListings];
            
        }else{
            [self configureViewForInactiveListings];
        }
    }
}

- (IBAction)openSafeAgent{
    [self performSegueWithIdentifier:ShowSafeAgentSegue sender:self];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    intTimeCounter = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkReachableNotification:) name:DGNetworkReachableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkUnreachableNotification:) name:DGNetworkUnreachableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSafeAgentCheckNotification:) name:DGSafeAgentCheckNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSafeAgentCheckNotification:) name:DGSafeAgentCheckNotification object:nil];
    
    [self.manualAddButton makeDGButton];
    [self.manualCancelButton makeDGButton];
    [self.confirmAddButton makeDGButton];
    [self.confirmCancelButton makeDGButton];
    
    [self setupTextFields];
    
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
//    [DGSyncService downloadAllDataWithHUD:YES callback:^(BOOL success, NSError *error) {
//        [NSUserDefaults setHasDownloadedAllData:YES];
//        [NSUserDefaults setHasSignedInBefore:YES];
//    }];
}

- (void)setupTextFields{
    [self styleTextField:self.mlsField];
    [self styleTextField:self.addressField];
    [self styleTextField:self.townField];
    [self styleTextField:self.stateField];
    [self styleTextField:self.zipField];
}

- (void)styleTextField:(UITextField *)textField{
    [textField addLeftPadding];
    [textField setBorderColor:[UIColor lightGrayColor]];
}

- (void)didReceiveNetworkReachableNotification:(NSNotification *)notification{
    if ([NSUserDefaults shouldEnableSafeAgent]){
        self.safeAgentButton.hidden = NO;
    }
}

- (void)didReceiveNetworkUnreachableNotification:(NSNotification *)notification{
    self.safeAgentButton.hidden = YES;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldUpdateProfile{
    NSString *agentID = [DGUserManager sharedInstance].currentAgent.agentID;
    
    if ([NSUserDefaults shouldEnableSafeAgent]){
        if (![NSUserDefaults firstNameForAgent:agentID] ||
            ![NSUserDefaults lastNameForAgent:agentID] ||
            ![NSUserDefaults phoneForAgent:agentID] ||
            ![NSUserDefaults pinForAgent:agentID]){
            return YES;
        }
    }
    
    return NO;
}

- (void)openSafeAgentProfile{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"SafeAgent" bundle: nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"DGSafeAgentProfileViewController"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:NO
                                                                     andCompletion:nil];
}

#pragma mark - Main methods

- (void)configureViewForAddListing{
    self.titleLabel.text = @"All Daniel Gale Listings";
    self.statusLabel.text = nil;
    
    self.listings = [DGListingsManager sharedInstance].listingsToAdd;
    [self.listingsCollectionView reloadData];
    
    self.searchBar.hidden = NO;
}

- (void)configureViewForActiveListings{
    self.titleLabel.text = @"MY LISTINGS/OPEN HOUSES";
    self.statusLabel.text = @"ACTIVE";
    self.statusLabel.textColor = [UIColor greenStatusColor];
    
    self.listings = [DGListingsManager sharedInstance].activeListings;
    [self.listingsCollectionView reloadData];
    
    self.searchBar.hidden = YES;
}

- (void)configureViewForInactiveListings{
    self.titleLabel.text = @"MY LISTINGS/OPEN HOUSES";
    self.statusLabel.text = @"INACTIVE";
    self.statusLabel.textColor = [UIColor redColor];
    
    self.listings = [DGListingsManager sharedInstance].inactiveListings;
    [self.listingsCollectionView reloadData];
    
    self.searchBar.hidden = YES;
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if (self.isSearching){
        return [self.searchResults count] + ((self.showActiveListings || self.addListing) ? 1 : 0); // +1 for add new listing cell or manual entry cell
        
    }else{
        return [self.listings count] + ((self.showActiveListings || self.addListing) ? 1 : 0); // +1 for add new listing cell or manual entry cell
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.showActiveListings || self.addListing){
        
        if (indexPath.row == 0){
            //Add listing
            DGAddListingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DGAddListingCellIdentifier forIndexPath:indexPath];
            
            cell.layer.borderWidth = 1.0;
            cell.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            cell.titleLabel.text = self.addListing ? @"Manual Entry" : @"Add Open House";
            
            return cell;
            
        }else{
            //Standard listing cell
            DGListingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DGListingCellIdentifier forIndexPath:indexPath];
            cell.delegate = self;
            
            RLMListing *listing;
            
            if (self.isSearching){
                listing = self.searchResults[indexPath.row - 1];
                
            }else{
                listing = self.listings[indexPath.row - 1];
            }
            
            cell.addressLabel.text = listing.prettyAddress;
            
            if (self.addListing){
                cell.deleteButton.hidden = YES;
            }else{
                if (self.showActiveListings == NO){
                    cell.deleteButton.hidden = YES;
                }else{
                    if (listing.attendees.count > 0){
                        cell.deleteButton.hidden = YES;
                    }else{
                        if (listing.userAdded){
                            cell.deleteButton.hidden = NO;
                        }else{
                            cell.deleteButton.hidden = YES;
                        }
                    }
                }
            }
            
            if (self.showActiveListings){
                cell.addressLabel.textColor = [UIColor colorWithRed:0.0 green:0.0863 blue:0.1059 alpha:1.0];
                cell.addressLabel.backgroundColor = [UIColor whiteColor];
                
                cell.mlsNumberLabel.textColor = [UIColor colorWithRed:0.0 green:0.0863 blue:0.1059 alpha:1.0];
                cell.mlsNumberLabel.backgroundColor = [UIColor whiteColor];
                
            }else{
                cell.addressLabel.textColor = [UIColor whiteColor];
                cell.addressLabel.backgroundColor = [UIColor darkGrayColor];
                
                cell.mlsNumberLabel.textColor = [UIColor whiteColor];
                cell.mlsNumberLabel.backgroundColor = [UIColor darkGrayColor];
            }
            
            cell.mlsNumberLabel.text = [NSString stringWithFormat:@"MLS #%@", listing.mlsNumber];
            
            //Image
            if ([self isOnline]){
                //Load from url
           //     NSLog(@"Online limage = %@", [DGAPI photoForListing:listing atIndex:0]);
                [cell.imageView setImageWithURL:[DGAPI photoForListing:listing atIndex:0]];
                /// If we are in online mode then we are doing another stuff that we can download the image here, if it is exist then it cannot be download but if it is not exist then image will be download
               NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                
                NSString * strMLSNo = [NSString stringWithFormat:@"dgPhotos/dgfoto/%@_0.jpg", listing.mlsNumber];
                NSString* foofile = [documentsPath stringByAppendingPathComponent:strMLSNo];
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
                if(fileExists) { /// No need to download the file
                
                } else { /// Need to download the file...
                    NSLog(@"[DGAPI photoForListing:listing atIndex:0] = %@", [DGAPI photoForListing:listing atIndex:0]);
                    NSString * strUrl = [NSString stringWithFormat:@"%@", [DGAPI photoForListing:listing atIndex:0]];
                    NSArray * arr = [NSArray arrayWithObjects:strUrl, strMLSNo, nil];
                    NSLog(@"arr = %@", arr);
                    [self performSelectorInBackground:@selector(downloadImageFileInBackgroundWithUrlandFileName:) withObject:arr];
                }
                
            }else{
              //  NSLog(@"Offline");
                
                //Load from disk
            //    NSLog(@"listing.mlsNumber = %@", listing.mlsNumber);
                UIImage *image = [UIImage imageForListing:listing.mlsNumber atIndex:0];
                if (image){
                    cell.imageView.image = image;
                }else{
                    cell.imageView.image = [UIImage imageNamed:@"ListingPlaceholder"];
                }
            }
            
            cell.layer.borderWidth = 1.0;
            cell.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            
            return cell;
        }
        
    }else{
        //Standard listing cell
        DGListingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DGListingCellIdentifier forIndexPath:indexPath];
        RLMListing *listing = self.listings[indexPath.row];
        
        cell.addressLabel.text = listing.prettyAddress;
        
        if (self.showActiveListings){
            cell.addressLabel.textColor = [UIColor colorWithRed:0.0 green:0.0863 blue:0.1059 alpha:1.0];
            cell.addressLabel.backgroundColor = [UIColor whiteColor];
            
            cell.mlsNumberLabel.textColor = [UIColor colorWithRed:0.0 green:0.0863 blue:0.1059 alpha:1.0];
            cell.mlsNumberLabel.backgroundColor = [UIColor whiteColor];
            
        }else{
            cell.addressLabel.textColor = [UIColor whiteColor];
            cell.addressLabel.backgroundColor = [UIColor darkGrayColor];
            
            cell.mlsNumberLabel.textColor = [UIColor whiteColor];
            cell.mlsNumberLabel.backgroundColor = [UIColor darkGrayColor];
        }
        
        cell.mlsNumberLabel.text = [NSString stringWithFormat:@"MLS #%@", listing.mlsNumber];
        cell.deleteButton.hidden = YES;
        
        //Image
        if ([self isOnline]){
            //Load from url
            NSLog(@"Online [DGAPI photoForListing:listing atIndex:0] = %@", [DGAPI photoForListing:listing atIndex:0]);
            [cell.imageView setImageWithURL:[DGAPI photoForListing:listing atIndex:0]];
            
            NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString * strMLSNo = [NSString stringWithFormat:@"dgPhotos/dgfoto/%@_0.jpg", listing.mlsNumber];
            NSString* foofile = [documentsPath stringByAppendingPathComponent:strMLSNo];
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
            if(fileExists) { /// No need to download the file
                
            } else { /// Need to download the file...
                NSLog(@"[DGAPI photoForListing:listing atIndex:0] = %@", [DGAPI photoForListing:listing atIndex:0]);
                NSString * strUrl = [NSString stringWithFormat:@"%@", [DGAPI photoForListing:listing atIndex:0]];
                NSArray * arr = [NSArray arrayWithObjects:strUrl, strMLSNo, nil];
                NSLog(@"arr = %@", arr);
                [self performSelectorInBackground:@selector(downloadImageFileInBackgroundWithUrlandFileName:) withObject:arr];
            }

        }else{
            //NSLog(@"Offline");
            
            //Load from disk
            UIImage *image = [UIImage imageForListing:listing.mlsNumber atIndex:0];
            if (image){
                cell.imageView.image = image;
            }else{
                cell.imageView.image = [UIImage imageNamed:@"ListingPlaceholder"];
            }
        }
        
        cell.layer.borderWidth = 1.0;
        cell.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.showActiveListings || self.addListing){
        if (indexPath.row == 0){
            //Add listing
            if (self.addListing){
                [self addManualListing];
                
            }else{
                self.addListing = YES;
                [self configureViewForAddListing];
            }
        }else{
            RLMListing *listing;
             DGListingCollectionViewCell *cell = (DGListingCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
            if (self.isSearching){
                listing = self.searchResults[indexPath.row - 1];
                
            }else{
                listing = self.listings[indexPath.row - 1];
            }
            
            if (self.addListing){
                [self promptAddListing:listing and:cell.imageView.image];
                
            }else{
                NSLog(@"listing = %@", listing);
                [self performSegueWithIdentifier:DGShowListingSegue sender:listing];
            }
        }
        
        //Inactive listings
    }else{
        RLMListing *listing = self.listings[indexPath.row];
        [self performSegueWithIdentifier:DGShowListingSegue sender:listing];
    }
}


- (void) downloadImageFileInBackgroundWithUrlandFileName:(NSArray *) arr {
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:arr[0]]];
    
    // find Documents directory and append your local filename
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    documentsURL = [documentsURL URLByAppendingPathComponent:arr[1]];
    NSLog(@"Download and save filePath = %@", documentsURL);
    // and finally save the file
    [data writeToURL:documentsURL atomically:YES];
}

- (BOOL)isOnline{
    return [[AFNetworkReachabilityManager sharedManager] isReachable];
}

#pragma mark - Delete Listing

- (void)deleteButtonPressedInCell:(DGListingCollectionViewCell *)cell{
    NSIndexPath *indexPath = [self.listingsCollectionView indexPathForCell:cell];
    
    RLMListing *listing;
    
    if (self.showActiveListings || self.addListing){
        if (indexPath.row == 0){
        }else{
            if (self.isSearching){
                listing = self.searchResults[indexPath.row - 1];
                
            }else{
                listing = self.listings[indexPath.row - 1];
            }
        }
    }else{
        listing = self.listings[indexPath.row];
    }
    
    NSLog(@"delete: %@", listing.address);
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Delete Listing?"
                                message:@"Are you sure you want to remove the selected listing?"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action){
                             [self deleteListing:listing];
                             
                         }];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:nil];
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteListing:(RLMListing *)listing{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    listing.needsSynced = NO;
    listing.userAdded = NO;
    [realm commitWriteTransaction];
    
    [[DGListingsManager sharedInstance] loadListingsFromDisk];
    
    //Refresh
    [self loadData];
}

#pragma mark - Add listing

- (void)promptAddListing:( RLMListing *)listing and:(UIImage *)image{
    self.listingToAdd = listing;
    
//    //Image
//    UIImage *image = [UIImage imageForListing:listing.mlsNumber atIndex:0];
   if (image){
       self.confirmListingImageView.image = image;
   }else{
       self.confirmListingImageView.image = [UIImage imageNamed:@"ListingPlaceholder"];
   }
    
    self.confirmAddressLabel.text = [NSString stringWithFormat:@"%@\nMLS# %@",listing.prettyFullAddressNoMLS,listing.mlsNumber];
    
    [self.view bringSubviewToFront:self.confirmView];
    
    [self showView:self.overlayView];
    [self showView:self.confirmView];
}

- (IBAction)confirmAddListing{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction]; //TODO: Don't need this?
    self.listingToAdd.needsSynced = YES;
    self.listingToAdd.userAdded = YES;
    [realm commitWriteTransaction];
    
    //Hide add listing view
    [self cancelAddListing];
    
    [[DGListingsManager sharedInstance] loadListingsFromDisk];
    
    [SVProgressHUD showSuccessWithStatus:@"Listing Added!"];
    
    self.addListing = NO;
    self.showActiveListings = YES;
    
    [self loadData];
}

- (IBAction)cancelAddListing{
    self.listingToAdd = nil;
    
    [self hideView:self.overlayView];
    [self hideView:self.confirmView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.confirmView.alpha > 0){
        [self cancelAddListing];
        
    }else if (self.manualView.alpha > 0){
        [self cancelManualAddListing];
    }
}

#pragma mark - Add Manual Listing

- (void)addManualListing{
    [self showView:self.overlayView];
    [self showView:self.manualView];
}

- (IBAction)cancelManualAddListing{
    [self hideView:self.overlayView];
    [self hideView:self.manualView];
    
    [self setupTextFields];
}

- (BOOL)validListingForm{
    BOOL valid = YES;
    
    //mls, address, town, state, zip
    
    NSString *zip = [[self.zipField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    if (zip.length != 5){
        valid = NO;
        self.errorLabel.text = @"Invalid ZIP code.";
        [self.zipField showError];
    }
    
    NSString *state = [self.stateField.text trimWhitespace];
    if (state.length != 2){
        valid = NO;
        self.errorLabel.text = @"Invalid state abbreviation.";
        [self.stateField showError];
    }
    
    NSString *town = [self.townField.text trimWhitespace];
    if (town.length < 1){
        valid = NO;
        self.errorLabel.text = @"Town name required.";
        [self.townField showError];
    }
    
    NSString *address = [self.addressField.text trimWhitespace];
    if (address.length < 1){
        valid = NO;
        self.errorLabel.text = @"Address required.";
        [self.addressField showError];
    }
    
    NSString *mls = [[self.mlsField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    if (mls.length < 1){
        valid = NO;
        self.errorLabel.text = @"MLS number required.";
        [self.mlsField showError];
    }
    
    return valid;
}

- (IBAction)submitManualListing{
    self.errorLabel.text = nil;
    
    if (![self validListingForm]){
        return;
    }
    
    [self.view endEditing:YES];
    
    NSString *mls       = [[self.mlsField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    NSString *address   = [self.addressField.text trimWhitespace];
    NSString *town      = [self.townField.text trimWhitespace];
    NSString *state     = [self.stateField.text trimWhitespace];
    NSString *zip       = [[self.zipField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    
    RLMListing *newListing = [[ RLMListing alloc] init];
    
    NSString *uuid = [[[NSUUID UUID] UUIDString] lowercaseString];
    
    newListing.listingID        = uuid;
    newListing.mlsNumber        = mls;
    newListing.address          = address;
    newListing.town             = town;
    newListing.state            = state;
    newListing.zip              = zip;
    newListing.status           = @"A";
    newListing.manuallyAdded    = YES;
    newListing.isActive = YES;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:newListing];
    [realm commitWriteTransaction];
    
    [self setupTextFields];
    
    [[DGListingsManager sharedInstance] loadListingsFromDisk];
    
    [self hideView:self.manualView];
    [self hideView:self.overlayView];
    
    [SVProgressHUD showSuccessWithStatus:@"Listing Added!"];
    
    self.addListing = NO;
    self.showActiveListings = YES;
    
    [self loadData];
}

#pragma mark - UISearchBar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.isSearching = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(![searchBar isFirstResponder]) {
        // user tapped the 'clear' button
        self.shouldBeginEditing = NO;
        [self.listingsCollectionView setContentOffset:CGPointZero animated:YES];
    }
    
    if([searchText length] != 0){
        [self search];
        
    }else{
        self.isSearching = NO;
    }
    
    [self.listingsCollectionView reloadData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)bar {
    BOOL boolToReturn = self.shouldBeginEditing;
    self.shouldBeginEditing = YES;
    return boolToReturn;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.isSearching = NO;
    [self.listingsCollectionView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self search];
}

- (void)search{
    self.isSearching = YES;
    self.searchResults = [self.listings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"prettyFullAddress contains[c] %@", self.searchBar.text]];
}

#pragma mark - UITextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.mlsField) {
        [self.addressField becomeFirstResponder];
        
    } else if (textField == self.addressField) {
        [self.townField becomeFirstResponder];
        
    }else if (textField == self.townField) {
        [self.stateField becomeFirstResponder];
        
    }else if (textField == self.stateField) {
        [self.zipField becomeFirstResponder];
        
    }else if (textField == self.zipField) {
        [self.zipField resignFirstResponder];
    }
    
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSInteger fieldHeight = 48;
    NSInteger topSpace = 222;
    
    if (textField == self.mlsField){
        [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:topSpace];
        
    }else if (textField == self.addressField){
        [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:topSpace - (fieldHeight * 1)];
        
    }else if (textField == self.townField){
        [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:topSpace - (fieldHeight * 2)];
        
    }else if (textField == self.stateField || textField == self.zipField){
        [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:topSpace - (fieldHeight * 3)];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSInteger maxLength;
    
    if (textField == self.mlsField){
        maxLength = 20;
        
    }else if (textField == self.addressField){
        maxLength = 200;
        
    }else if (textField == self.townField){
        maxLength = 200;
        
    }else if (textField == self.stateField){
        maxLength = 2;
        
    }else if (textField == self.zipField){
        maxLength = 5;
    }
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return !([newString length] > maxLength);
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:DGShowListingSegue]){
        DGListingViewController *vc = segue.destinationViewController;
        vc.listing = ( RLMListing *)sender;
    }
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