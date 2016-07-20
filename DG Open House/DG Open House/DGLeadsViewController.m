//
//  DGLeadsViewController.m
//  DG Open House
//
//  Created by Chase Acton on 4/24/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGLeadsViewController.h"
#import "DGListingsManager.h"
#import "DGListing.h"
#import "SlideNavigationController.h"
#import "DGLeadTableViewCell.h"
#import "DGAttendee.h"
#import "UIButton+BackgroundColor.h"
#import "DGAttendeeDetailsViewController.h"
#import "SGFormatter.h"
#import "UIButton+Extensions.h"
#import "DGConstants.h"
#import "AFNetworkReachabilityManager.h"
#import "DGCSVHelper.h"
#import "DGServer.h"
#import "SVProgressHUD.h"
#import "NSDate+Utilities.h"
#import "UITextField+Utilities.h"
#import "DGSelectLeadTableViewCell.h"
#import "DGAlert.h"
#import "NSArray+Utilities.h"
#import "RLMListing.h"
#import "DGEventsManager.h"
#import "NSUserDefaults+Convenience.h"

typedef NS_ENUM(NSUInteger, SortType) {
    SortTypeAll,
    SortTypeBuyers,
    SortTypeAgents
};

@interface DGLeadsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPopoverControllerDelegate>

@property (nonatomic) NSMutableArray *allLeads;
@property (nonatomic) NSMutableArray *buyers;
@property (nonatomic) NSMutableArray *agents;
@property (nonatomic) NSMutableArray *currentLeads;

@property (weak) IBOutlet UITableView *tableView;
@property (weak) IBOutlet UIButton *sortButton;
@property (weak) IBOutlet UIButton *exportButton;
@property (weak) IBOutlet UISearchBar *searchBar;

@property (weak) IBOutlet UILabel *titleLabel;
@property (weak) IBOutlet UILabel *header1;
@property (weak) IBOutlet UILabel *header2;

@property (weak) IBOutlet NSLayoutConstraint *emailButtonHeightConstraint;
@property (weak) IBOutlet NSLayoutConstraint *backButtonWidthConstraint;
@property (weak) IBOutlet UIButton *emailButton;
@property (weak) IBOutlet UIButton *backButton;
@property (weak) IBOutlet UIButton *menuButton;
@property (weak) IBOutlet UIButton *safeAgentButton;
@property (weak) IBOutlet UIImageView *backButtonIcon;

//Select leads
@property (nonatomic) NSMutableArray *selectedLeads;
@property (weak) IBOutlet UIView *selectLeadsView;
@property (weak) IBOutlet UITableView *leadsTableView;
@property (weak) IBOutlet UIButton *selectAllButton;
@property (weak) IBOutlet UIButton *selectLeadsNextButton;

//Promote
@property (weak) IBOutlet UIView *overlayView;

@property (nonatomic) NSDate *openHouseDate;
@property (nonatomic) NSDate *startTime;
@property (nonatomic) NSDate *endTime;

//Promote view
@property (nonatomic) EditField editField;

@property (nonatomic) UIDatePicker *datePicker;

@property (weak) IBOutlet UIView *promoteView;
@property (weak) IBOutlet UILabel *errorLabel;
@property (weak) IBOutlet UITextField *dateField;
@property (weak) IBOutlet UITextField *startTimeField;
@property (weak) IBOutlet UITextField *endTimeField;
@property (weak) IBOutlet UIButton *promoteSubmitButton;

//Confirm view
@property (weak) IBOutlet UIView *confirmView;
@property (weak) IBOutlet UIButton *confirmCancelButton;
@property (weak) IBOutlet UIButton *confirmYesButton;
@property (weak) IBOutlet UILabel *confirmTitleLabel;

//Search
@property (nonatomic) BOOL isSearching;
@property (nonatomic) BOOL shouldBeginEditing;
@property (nonatomic) NSArray *searchResults;

@end

@implementation DGLeadsViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkReachableNotification:) name:DGNetworkReachableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkUnreachableNotification:) name:DGNetworkUnreachableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSafeAgentCheckNotification:) name:DGSafeAgentCheckNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSyncCompleteNotification:) name:DGSyncCompleteNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.menuButton setHitTestEdgeInsets:UIEdgeInsetsMake(-30, -30, -30, -30)];
    
    [self setupView];
    
    [self loadData];
    
    //Promote
    [self.promoteSubmitButton makeDGButton];
    [self.confirmCancelButton makeDGButton];
    [self.confirmYesButton makeDGButton];
    [self.selectAllButton makeDGButton];
    [self.selectLeadsNextButton makeDGButton];
    
    [self setupTextFields];
    
    NSDate *noon =  [[[NSCalendar currentCalendar] startOfDayForDate:[NSDate date]] dateByAddingHours:12];
    self.startTime = noon;
    self.endTime = [noon dateByAddingHours:2];
    
    [self updateFields];
    
    self.confirmTitleLabel.text = [NSString stringWithFormat:@"Are you sure you'd like to email the selected leads for %@ to promote the open house?", self.selectedListing.prettyAddress];
}

- (void)loadData{
    if (self.selectedListing){
        [self setupLeadsForListing];
        
    }else if (self.selectedEvent){
        [self setupEvents];
        
    }else{
        [self setupLeads];
    }
}

- (void)didReceiveSyncCompleteNotification:(NSNotification *)notification{
    [self loadData];
}

- (void)toggleBackButton{
    NSInteger stackCount = [self.navigationController.viewControllers count];
    
    if (stackCount >= 3){
        self.backButton.hidden = NO;
        self.backButtonIcon.hidden = NO;
        self.backButtonWidthConstraint.constant = 215;
        
    }else{
        self.backButton.hidden = YES;
        self.backButtonIcon.hidden = YES;
        self.backButtonWidthConstraint.constant = 0;
    }
    
    [self.backButton setNeedsLayout];
}

- (void)setupEmailButton{
    if (![[AFNetworkReachabilityManager sharedManager] isReachable]){
        self.emailButtonHeightConstraint.constant = 0;
    }else{
        if (self.selectedListing){
            self.emailButtonHeightConstraint.constant = 46;
        }else{
            self.emailButtonHeightConstraint.constant = 0;
        }
    }
    [self.emailButton setNeedsLayout];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (![[AFNetworkReachabilityManager sharedManager] isReachable] || ![NSUserDefaults shouldEnableSafeAgent]){
        self.safeAgentButton.hidden = YES;
    }
    
    [self toggleBackButton];
    [self setupEmailButton];
}

- (void)didReceiveNetworkReachableNotification:(NSNotification *)notification{
    if ([NSUserDefaults shouldEnableSafeAgent]){
        self.safeAgentButton.hidden = NO;
    }
    [self setupEmailButton];
}

- (void)didReceiveNetworkUnreachableNotification:(NSNotification *)notification{
    self.safeAgentButton.hidden = YES;
    [self setupEmailButton];
}

- (void)didReceiveSafeAgentCheckNotification:(NSNotification *)notification{
    if ([[AFNetworkReachabilityManager sharedManager] isReachable] && [NSUserDefaults shouldEnableSafeAgent]){
        self.safeAgentButton.hidden = NO;
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupView{
    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.leadsTableView.layer.borderWidth = 1;
    self.leadsTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.leadsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.exportButton makeDGButtonWithIcon];
    [self.sortButton makeDGButton];
    [self.emailButton makeDGButton];
    [self.backButton makeDGButton];
    
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
}

#pragma mark - View Setup

- (void)updateFields{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"M/d/yyyy"];
    
    if (self.openHouseDate){
        self.dateField.text = [dateFormat stringFromDate:self.openHouseDate];
    }
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"h:mm a"];
    
    self.startTimeField.text = [timeFormat stringFromDate:self.startTime];
    self.endTimeField.text = [timeFormat stringFromDate:self.endTime];
}

- (void)setupTextFields{
    [self styleTextField:self.dateField];
    [self styleTextField:self.startTimeField];
    [self styleTextField:self.endTimeField];
}

- (void)styleTextField:(UITextField *)textField{
    [textField addLeftPadding];
    [textField setBorderColor:[UIColor lightGrayColor]];
}

- (IBAction)export{
    NSData *csv;
    NSString *filename;
    
    if (self.selectedEvent){
        csv = [DGCSVHelper eventCsvFromAttendees:self.allLeads];
        filename = [NSString stringWithFormat:@"Attendees-%@.csv", self.selectedEvent.eventID];
    }else{
        csv = [DGCSVHelper csvFromAttendees:self.allLeads];
        filename = [NSString stringWithFormat:@"Attendees-%@.csv", self.selectedListing.mlsNumber];
    }
    
    NSString* newStr = [NSString stringWithUTF8String:[csv bytes]];
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(useCacheDirectory ? NSCachesDirectory : NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"Attendees.csv"];
    
    NSError *error;
    
    [newStr writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    NSError *error2 = nil;
    BOOL success = [[NSURL fileURLWithPath:filePath] setResourceValue:[NSNumber numberWithBool: YES]
                                                             forKey: NSURLIsExcludedFromBackupKey error: &error2];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [[NSURL URLWithString:filePath] lastPathComponent], error2);
    }
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    NSArray *dataToShare = @[url];
    UIActivityViewController* activityViewController =[[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop, UIActivityTypePrint, UIActivityTypePostToVimeo, UIActivityTypeSaveToCameraRoll];
    [activityViewController setModalPresentationStyle:UIModalPresentationPopover];
    
    UIPopoverPresentationController *popPresenter = [activityViewController popoverPresentationController];
    popPresenter.barButtonItem = self.navigationItem.rightBarButtonItem;
    popPresenter.sourceView = self.exportButton;
    popPresenter.sourceRect = self.exportButton.bounds;
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (IBAction)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)openMenu{
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (void)setupLeads{
    self.allLeads       = [[NSMutableArray alloc] init];
    self.currentLeads   = [[NSMutableArray alloc] init];
    self.buyers         = [[NSMutableArray alloc] init];
    self.agents         = [[NSMutableArray alloc] init];
    
    for (RLMListing *listing in [DGListingsManager sharedInstance].activeListings){
        for (RLMAttendee *attendee in listing.attendees){
            [self.allLeads addObject:attendee];
        }
    }
    
    for (RLMAttendee *attendee in self.allLeads){
        if (attendee.isBuyer){
            [self.buyers addObject:attendee];
        }else{
            [self.agents addObject:attendee];
        }
    }
    
    self.currentLeads = self.allLeads;
    
    self.header1.text = @"PROPERTY";
    self.header2.text = [NSString stringWithFormat:@"%@ (%@)",
                         self.currentLeads.count == 1 ? @"ATTENDEE" : @"ATTENDEES",
                         @(self.currentLeads.count)];
    
    //Sort
    self.allLeads       = [[self.allLeads sortedByKey:@"date" ascending:NO] mutableCopy];
    self.currentLeads   = [[self.currentLeads sortedByKey:@"date" ascending:NO] mutableCopy];
    self.buyers         = [[self.buyers sortedByKey:@"date" ascending:NO] mutableCopy];
    self.agents         = [[self.agents sortedByKey:@"date" ascending:NO] mutableCopy];
    
    [self.tableView reloadData];
}

- (void)setupLeadsForListing{
    self.selectedListing = [[DGListingsManager sharedInstance] listingWithID:self.selectedListing.listingID];
    
    self.allLeads = [[NSMutableArray alloc] init];
    for (RLMAttendee *attendee in self.selectedListing.attendees){
        [self.allLeads addObject:attendee];
    }
    
    self.currentLeads = [[NSMutableArray alloc] init];
    self.buyers = [[NSMutableArray alloc] init];
    self.agents = [[NSMutableArray alloc] init];
    
    for (RLMAttendee *attendee in self.allLeads){
        if (attendee.isBuyer){
            [self.buyers addObject:attendee];
        }else{
            [self.agents addObject:attendee];
        }
    }
    
    self.currentLeads = self.allLeads;
    
    self.header1.text = [NSString stringWithFormat:@"%@ (%@)",
                         self.currentLeads.count == 1 ? @"ATTENDEE" : @"ATTENDEES",
                         @(self.currentLeads.count)];
    
    self.header2.text = @"PHONE";
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@ from\n%@ • MLS #%@",
                            @(self.currentLeads.count),
                            self.currentLeads.count == 1 ? @"Lead" : @"Leads",
                            self.selectedListing.prettyAddress,
                            self.selectedListing.mlsNumber];
    
    self.selectedLeads = [[NSMutableArray alloc] initWithArray:self.currentLeads];
    
    //Sort
    self.allLeads       = [[self.allLeads sortedByKey:@"date" ascending:NO] mutableCopy];
    self.currentLeads   = [[self.currentLeads sortedByKey:@"date" ascending:NO] mutableCopy];
    self.buyers         = [[self.buyers sortedByKey:@"date" ascending:NO] mutableCopy];
    self.agents         = [[self.agents sortedByKey:@"date" ascending:NO] mutableCopy];
    
    [self.tableView reloadData];
}

- (void)setupEvents{
    self.selectedEvent = [[DGEventsManager sharedInstance] eventWithID:self.selectedEvent.eventID];
    
    self.allLeads = [[NSMutableArray alloc] init];
    for (RLMAttendee *attendee in self.selectedEvent.attendees){
        [self.allLeads addObject:attendee];
    }
    
    self.currentLeads = [[NSMutableArray alloc] initWithArray:self.allLeads];
    
    [self.tableView reloadData];
    
    self.header1.text = [NSString stringWithFormat:@"%@ (%@)",
                         self.currentLeads.count == 1 ? @"ATTENDEE" : @"ATTENDEES",
                         @(self.currentLeads.count)];
    
    self.header2.text = @"PHONE";
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@ at\n%@ • %@",
                            @(self.currentLeads.count),
                            self.currentLeads.count == 1 ? @"Lead" : @"Leads",
                            self.selectedEvent.name,
                            self.selectedEvent.prettyDate];
    
    self.selectedLeads = [[NSMutableArray alloc] initWithArray:self.currentLeads];
    
    self.sortButton.hidden = YES;
}

- (IBAction)emailAttendees{
    if (![[AFNetworkReachabilityManager sharedManager] isReachable]){
        [DGAlert alertWithTitle:@"Internet Unavailable" message:@"Please connect to a network and try again." sender:self];
        return;
    }
    
    if ([self.selectedLeads count] == 0){
        self.selectLeadsNextButton.enabled = NO;
    }else{
        self.selectLeadsNextButton.enabled = YES;
    }
    
    [self showView:self.overlayView];
    [self showView:self.selectLeadsView];
}

- (IBAction)selectAttendees{
    [self hideView:self.selectLeadsView];
    [self showView:self.promoteView];
}

- (IBAction)openSafeAgent{
    [self performSegueWithIdentifier:ShowSafeAgentSegue sender:self];
}

- (IBAction)sort{
    UIAlertController * alert =   [UIAlertController
                                   alertControllerWithTitle:nil
                                   message:nil
                                   preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *all = [UIAlertAction
                          actionWithTitle:@"View All"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action){
                              [self sortBy:SortTypeAll];
                          }];
    
    UIAlertAction *buyers = [UIAlertAction
                             actionWithTitle:@"Only Buyers"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action){
                                 [self sortBy:SortTypeBuyers];
                             }];
    
    UIAlertAction *agents = [UIAlertAction
                             actionWithTitle:@"Only Agents"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action){
                                 [self sortBy:SortTypeAgents];
                             }];
    
    [alert addAction:all];
    [alert addAction:buyers];
    [alert addAction:agents];
    
    [alert setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
    popPresenter.barButtonItem = self.navigationItem.rightBarButtonItem;
    
    popPresenter.sourceView = self.sortButton;
    popPresenter.sourceRect = self.sortButton.bounds;
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)sortBy:(SortType)type{
    switch (type) {
        case SortTypeAll:
            [self.sortButton setTitle:@"View All  ▾" forState:UIControlStateNormal];
            self.currentLeads = self.allLeads;
            NSLog(@"s1");
            break;
            
        case SortTypeBuyers:
            [self.sortButton setTitle:@"Buyers Only  ▾" forState:UIControlStateNormal];
            self.currentLeads = self.buyers;
            NSLog(@"s2");
            
            break;
            
        case SortTypeAgents:
            [self.sortButton setTitle:@"Agents Only  ▾" forState:UIControlStateNormal];
            self.currentLeads = self.agents;
            NSLog(@"s3");
            
            break;
            
        default:
            break;
    }
    
    [self.tableView reloadData];
    
    if (self.selectedListing){
        self.header1.text = [NSString stringWithFormat:@"%@ (%@)",
                             self.currentLeads.count == 1 ? @"ATTENDEE" : @"ATTENDEES",
                             @(self.currentLeads.count)];
    }else{
        self.header2.text = [NSString stringWithFormat:@"%@ (%@)",
                             self.currentLeads.count == 1 ? @"ATTENDEE" : @"ATTENDEES",
                             @(self.currentLeads.count)];
    }
}

- (IBAction)selectAll{
    [self.selectedLeads removeAllObjects];
    [self.selectedLeads addObjectsFromArray:self.currentLeads];
    [self.leadsTableView reloadData];
    
    if ([self.selectedLeads count] == 0){
        self.selectLeadsNextButton.enabled = NO;
    }else{
        self.selectLeadsNextButton.enabled = YES;
    }
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isSearching){
        return [self.searchResults count];
    }else{
        return [self.currentLeads count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RLMAttendee *attendee;
    
    if (self.isSearching){
        attendee = self.searchResults[indexPath.row];
    }else{
        attendee = self.currentLeads[indexPath.row];
    }
    
    if (tableView == self.tableView){
        DGLeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeadCell"];
        
        if (attendee.cardFileID){
            cell.cardIcon.hidden = NO;
        }else{
            cell.cardIcon.hidden = YES;
        }
        
        if (self.selectedListing || self.selectedEvent){
            if (attendee.firstName){
                cell.addressLabel.text = attendee.fullName;
            }else{
                cell.addressLabel.text = @"(Not Available)";
            }
            
            cell.nameLabel.text = [SGFormatter formatPhoneNumber:attendee.phone deleteLastChar:NO];
            
        }else{
            RLMListing *listing = [[DGListingsManager sharedInstance] listingWithID:attendee.listingID];
            if (listing){
                cell.addressLabel.text = listing.prettyAddress;
            }
            
            if (attendee.firstName){
                cell.nameLabel.text = attendee.fullName;
            }else{
                cell.nameLabel.text = @"(Not Available)";
            }
        }
        
        //Date label
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"M/d/yyyy";
        cell.dateLabel.text = [dateFormatter stringFromDate:attendee.date];
        
        //Stars
        if (attendee.rating >= 1){
            cell.star1ImageView.image = [UIImage imageNamed:@"Star_Blue"];
        }else{
            cell.star1ImageView.image = [UIImage imageNamed:@"Star_White"];
        }
        
        if (attendee.rating >= 2){
            cell.star2ImageView.image = [UIImage imageNamed:@"Star_Blue"];
        }else{
            cell.star2ImageView.image = [UIImage imageNamed:@"Star_White"];
        }
        
        if (attendee.rating >= 3){
            cell.star3ImageView.image = [UIImage imageNamed:@"Star_Blue"];
        }else{
            cell.star3ImageView.image = [UIImage imageNamed:@"Star_White"];
        }
        
        if (attendee.rating >= 4){
            cell.star4ImageView.image = [UIImage imageNamed:@"Star_Blue"];
        }else{
            cell.star4ImageView.image = [UIImage imageNamed:@"Star_White"];
        }
        
        if (attendee.rating >= 5){
            cell.star5ImageView.image = [UIImage imageNamed:@"Star_Blue"];
        }else{
            cell.star5ImageView.image = [UIImage imageNamed:@"Star_White"];
        }
        
        return cell;
        
    }else if (tableView == self.leadsTableView){
        DGSelectLeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectLeadCell"];
        
        if (attendee.firstName){
            cell.nameLabel.text = attendee.fullName;
        }else{
            cell.nameLabel.text = @"(Not Available)";
        }
        
        //Date label
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"M/d/yyyy";
        cell.dateLabel.text = [dateFormatter stringFromDate:attendee.date];
        
        if ([self.selectedLeads containsObject:attendee]){
            cell.icon.image = [UIImage imageNamed:@"Check"];
        }else{
            cell.icon.image = [UIImage imageNamed:@"Check_Gray"];
        }
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RLMAttendee *attendee;
    
    if (self.isSearching){
        attendee = self.searchResults[indexPath.row];
    }else{
        attendee = self.currentLeads[indexPath.row];
    }
    
    if (tableView == self.tableView){
        [self performSegueWithIdentifier:@"ShowAttendeeDetailsSegue" sender:attendee];
        
    }else if (tableView == self.leadsTableView){
        if ([self.selectedLeads containsObject:attendee]){
            [self.selectedLeads removeObject:attendee];
        }else{
            [self.selectedLeads addObject:attendee];
        }
        
        if ([self.selectedLeads count] == 0){
            self.selectLeadsNextButton.enabled = NO;
        }else{
            self.selectLeadsNextButton.enabled = YES;
        }
        
        [self.leadsTableView reloadData];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ShowAttendeeDetailsSegue"]){
        DGAttendeeDetailsViewController *vc = segue.destinationViewController;
        vc.selectedAttendee = (RLMAttendee *)sender;
    }
}

#pragma mark - Open House Promotion

- (IBAction)sendEmails{
    [SVProgressHUD show];
    
    [self hideView:self.confirmView];
    [self hideView:self.overlayView];
    
    [DGServer emailAttendees:self.selectedLeads date:self.openHouseDate start:self.startTime end:self.endTime callback:^(BOOL success, NSError *error) {
        [SVProgressHUD showSuccessWithStatus:@"Promotions sent!"];
    }];
}

- (IBAction)promote{
    [self showView:self.overlayView];
    [self showView:self.promoteView];
}

- (void)showPicker{
    //build our custom popover view
    UIView *v = [[UIView alloc] init];
    CGRect pickerFrame = CGRectMake(0, 0, 320, 216);
    self.datePicker = [[UIDatePicker alloc] initWithFrame:pickerFrame];
    
    self.datePicker.frame = pickerFrame;
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    self.datePicker.minuteInterval = 5;
    
    //self.datePicker = pView;
    [v addSubview:self.datePicker];
    UIViewController *popoverContent = [[UIViewController alloc]init];
    popoverContent.view = v;
    popoverContent.view.backgroundColor = [UIColor clearColor];
    
    //resize the popover view shown
    //in the current view to the view's size
    popoverContent.preferredContentSize = CGSizeMake(320, 216);
    
    
    //create a popover controller with my DatePickerViewController in it
    UIPopoverController *popoverControllerForDate = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    
    //Set the delegate to self to receive the data of the Datepicker in the popover
    popoverControllerForDate.delegate = self;
    
    //Figure out which field to display it from
    CGRect frame;
    
    if (self.editField == EditFieldOpenHouseDate){
        frame = self.dateField.frame;
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        if (self.openHouseDate){
            self.datePicker.date = self.openHouseDate;
        }
    }else if (self.editField == EditFieldStartTime){
        frame = self.startTimeField.frame;
        self.datePicker.datePickerMode = UIDatePickerModeTime;
        self.datePicker.date = self.startTime;
        
    }else if (self.editField == EditFieldEndTime){
        frame = self.endTimeField.frame;
        self.datePicker.datePickerMode = UIDatePickerModeTime;
        self.datePicker.date = self.endTime;
    }
    
    //Present the popover
    [popoverControllerForDate presentPopoverFromRect:frame inView:self.promoteView permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (IBAction)cancelPromotion{
    [self hideView:self.confirmView];
    [self showView:self.promoteView];
}

- (void)dateChanged:(id)sender{
    if (self.editField == EditFieldOpenHouseDate){
        self.openHouseDate = self.datePicker.date;
        
    }else if (self.editField == EditFieldStartTime){
        self.startTime = self.datePicker.date;
        self.endTime = [self.startTime dateByAddingHours:2];

    }else if (self.editField == EditFieldEndTime){
        self.endTime = self.datePicker.date;
    }
    
    [self updateFields];
}

- (IBAction)sendPromotion{
    [self setupTextFields];
    self.errorLabel.text = nil;
    
    //Validate dates
    if ([self.openHouseDate isInPast]){
        [self.dateField shake];
        [self.dateField showError];
        
        self.errorLabel.text = @"Date can't be in the past";
        
        return;
    }
    
    if (!self.openHouseDate){
        [self.dateField shake];
        [self.dateField showError];
        
        self.errorLabel.text = @"Date required";
        
        return;
    }
    
    if ([self.endTime isEarlierThanDate:self.startTime]){
        [self.endTimeField shake];
        [self.endTimeField showError];
        
        self.errorLabel.text = @"End time must be after start time";
        
        return;
    }
    
    [self hideView:self.promoteView];
    [self showView:self.confirmView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.promoteView.alpha > 0){
        [self hideView:self.overlayView];
        [self hideView:self.promoteView];
    }
    
    if (self.selectLeadsView.alpha > 0){
        [self hideView:self.overlayView];
        [self hideView:self.selectLeadsView];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (textField == self.dateField){
        self.editField = EditFieldOpenHouseDate;
        
    }else if (textField == self.startTimeField){
        self.editField = EditFieldStartTime;
        
    }else if (textField == self.endTimeField){
        self.editField = EditFieldEndTime;
    }
    
    [self showPicker];
    
    return NO;
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
    self.searchResults = [self.currentLeads filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"fullName contains[c] %@ OR listing.prettyAddress  contains[c] %@", self.searchBar.text, self.searchBar.text]];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)bar {
    BOOL boolToReturn = self.shouldBeginEditing;
    self.shouldBeginEditing = YES;
    return boolToReturn;
}

@end