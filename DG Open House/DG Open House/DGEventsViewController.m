//
//  DGEventsViewController.m
//  DG Open House
//
//  Created by Chase Acton on 5/5/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGEventsViewController.h"
#import "DGConstants.h"
#import "AFNetworkReachabilityManager.h"
#import "UIButton+Extensions.h"
#import "SlideNavigationController.h"
#import "DGEventsManager.h"
#import "DGListingCollectionViewCell.h"
#import "DGAddListingCollectionViewCell.h"
#import "DGEventDetailsViewController.h"
#import "UIButton+BackgroundColor.h"
#import "DGLeadTableViewCell.h"
#import "NSArray+Utilities.h"
#import "UITextField+Utilities.h"
#import "NSDate+Utilities.h"
#import "SVProgressHUD.h"
#import "DGUserManager.h"
#import "DGListingsManager.h"
#import "IQKeyboardManager.h"
#import "RLMEvent.h"
#import "UIImage+DGImage.h"
#import "RealmString.h"
#import "NSUserDefaults+Convenience.h"

static NSString * const DGShowEventDetailsSegue = @"DGShowEventDetailsSegue";

@interface DGEventsViewController () <UIPopoverControllerDelegate, DGListingCollectionViewCellDelegate, DGLeadTableViewCellDelegate>

@property (weak) IBOutlet UIButton *menuButton;
@property (weak) IBOutlet UIButton *safeAgentButton;
@property (weak) IBOutlet UIButton *addEventButton;

@property (weak) IBOutlet UICollectionView *collectionView;
@property (weak) IBOutlet UITableView *tableView;

@property (weak) IBOutlet UIButton *galleryButton;
@property (weak) IBOutlet UIButton *listButton;

@property (weak) IBOutlet UILabel *titleLabel;
@property (weak) IBOutlet UILabel *tableHeader1;
@property (weak) IBOutlet UILabel *tableHeader2;

@property (nonatomic) NSArray *events;

//Search
@property (nonatomic) BOOL isSearching;
@property (nonatomic) BOOL shouldBeginEditing;
@property (nonatomic) NSArray *searchResults;
@property (weak) IBOutlet UISearchBar *searchBar;

//Add event
@property (nonatomic) EditField editField;

@property (nonatomic) UIDatePicker *datePicker;

@property (weak) IBOutlet UIView *addEventView;
@property (weak) IBOutlet UILabel *errorLabel;
@property (weak) IBOutlet UITextField *eventNameField;
@property (weak) IBOutlet UITextField *dateField;
@property (weak) IBOutlet UIButton *addCancelButton;
@property (weak) IBOutlet UIButton *addCreateButton;

@property (weak) IBOutlet UIView *overlayView;

@property (nonatomic) NSDate *eventDate;

@end

@implementation DGEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkReachableNotification:) name:DGNetworkReachableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkUnreachableNotification:) name:DGNetworkUnreachableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSafeAgentCheckNotification:) name:DGSafeAgentCheckNotification object:nil];
    
    [self.menuButton setHitTestEdgeInsets:UIEdgeInsetsMake(-30, -30, -30, -30)];
    
    [self.galleryButton setBackgroundColor:[UIColor colorWithRed:0.8588 green:0.8667 blue:0.8745 alpha:1.0] forState:UIControlStateDisabled];
    [self.listButton setBackgroundColor:[UIColor colorWithRed:0.8588 green:0.8667 blue:0.8745 alpha:1.0] forState:UIControlStateDisabled];
    
    [self.galleryButton makeDGButton];
    [self.listButton makeDGButton];
    [self.addEventButton makeDGButton];
    
    [self.addCancelButton makeDGButton];
    [self.addCreateButton makeDGButton];
    
    
    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.galleryButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    [self setupTextFields];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (![[AFNetworkReachabilityManager sharedManager] isReachable] || ![NSUserDefaults shouldEnableSafeAgent]){
        self.safeAgentButton.hidden = YES;
    }
    
    [self loadData];
    
    if (self.addEvent){
        [self addNewEvent];
    }
}

- (void)loadData{
    self.events = [[DGEventsManager sharedInstance].allEvents sortedByKey:@"eventDate" ascending:NO];
    
    [self.collectionView reloadData];
    [self.tableView reloadData];
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

- (IBAction)showList{
    self.collectionView.hidden = YES;
    
    self.tableView.hidden = NO;
    self.addEventButton.hidden = NO;
    
    self.galleryButton.enabled = YES;
    self.listButton.enabled = NO;
    
    self.titleLabel.hidden = YES;
    
    self.galleryButton.layer.borderColor = [UIColor colorWithRed:0.1725 green:0.4549 blue:0.7765 alpha:1.0].CGColor;
    self.listButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.tableHeader1.hidden = NO;
    self.tableHeader2.hidden = NO;
}

- (IBAction)showGallery{
    self.collectionView.hidden = NO;
    
    self.tableView.hidden = YES;
    self.addEventButton.hidden = YES;
    
    self.galleryButton.enabled = NO;
    self.listButton.enabled = YES;
    
    self.titleLabel.hidden = NO;
    
    self.galleryButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.listButton.layer.borderColor = [UIColor colorWithRed:0.1725 green:0.4549 blue:0.7765 alpha:1.0].CGColor;
    
    self.tableHeader1.hidden = YES;
    self.tableHeader2.hidden = YES;
}

- (IBAction)addNewEvent{
    [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:160];

    [self showView:self.overlayView];
    [self showView:self.addEventView];
}

- (IBAction)addEventCancel{
    [self.view endEditing:YES];

    [self setupTextFields];
    self.errorLabel.text = nil;
    
    self.eventDate = nil;
    
    self.eventNameField.text = nil;
    self.dateField.text = nil;
    
    [self hideView:self.overlayView];
    [self hideView:self.addEventView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.addEventView.alpha > 0){
        [self addEventCancel];
    }
}

- (IBAction)showPicker{
    //build our custom popover view
    [self.view endEditing:YES];
    
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
    CGRect frame = self.dateField.frame;
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    if (self.eventDate){
        self.datePicker.date = self.eventDate;
    }
    
    //Present the popover
    [popoverControllerForDate presentPopoverFromRect:frame inView:self.addEventView permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:self.eventNameField]) {
        [self showPicker];
        
    } else if ([textField isEqual:self.dateField]) {
        [self.dateField resignFirstResponder];
    }
    
    return NO;
}

- (void)dateChanged:(id)sender{
    self.eventDate = self.datePicker.date;
    [self updateFields];
}

- (IBAction)addEventCreate{
    [self setupTextFields];
    self.errorLabel.text = nil;
    
    if (self.eventNameField.text.length == 0){
        [self.eventNameField shake];
        [self.eventNameField showError];
        
        self.errorLabel.text = @"Event name required";
        
        return;
    }
    
    //Validate dates
    if ([self.eventDate isInPast]){
        [self.dateField shake];
        [self.dateField showError];
        
        self.errorLabel.text = @"Date can't be in the past";
        
        return;
    }
    
    [self hideView:self.overlayView];
    [self hideView:self.addEventView];
    
    //Add the event
    NSString *uuid = [[[NSUUID UUID] UUIDString] lowercaseString];

    RLMEvent *event = [[RLMEvent alloc] init];
    event.eventID = uuid;
    event.name = self.eventNameField.text;
    event.agentID = [DGUserManager sharedInstance].currentAgent.agentID;
    event.eventDate = self.eventDate;
    event.needsSynced = YES;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:event];
    [realm commitWriteTransaction];
    
    [[DGEventsManager sharedInstance] loadEventsFromDisk];
    
    //Refresh
    [self loadData];
    [SVProgressHUD showSuccessWithStatus:@"Event Added!"];
}

#pragma mark - View Setup

- (void)updateFields{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"M/d/yyyy"];
    
    if (self.eventDate){
        self.dateField.text = [dateFormat stringFromDate:self.eventDate];
    }
}

- (void)setupTextFields{
    [self styleTextField:self.dateField];
    [self styleTextField:self.eventNameField];
}

- (void)styleTextField:(UITextField *)textField{
    [textField addLeftPadding];
    [textField setBorderColor:[UIColor lightGrayColor]];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if (self.isSearching){
        return [self.searchResults count] + 1;
        
    }else{
        return [self.events count] + 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){
        DGAddListingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DGAddListingCell" forIndexPath:indexPath];
        return cell;
        
    }else{
        DGListingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DGEventCell" forIndexPath:indexPath];
        cell.delegate = self;
        RLMEvent *event;
        
        if (self.isSearching){
            event = self.searchResults[indexPath.row - 1];
            
        }else{
            event = self.events[indexPath.row - 1];
        }
        
        cell.deleteButton.hidden = event.attendees.count > 0;
        cell.addressLabel.text = event.name;
        cell.mlsNumberLabel.text = event.prettyDate;
        
        //Image
        if ([event.images count] > 0){
            RealmString *string = event.images[0];
            UIImage *image = [UIImage imageWithFilename:string.stringValue];
            if (image){
                cell.imageView.image = image;
            }else{
                cell.imageView.image = [UIImage imageNamed:@"EventPlaceholder"];
            }
        }else{
            cell.imageView.image = [UIImage imageNamed:@"EventPlaceholder"];
        }
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){
        [self addNewEvent];
        
    }else{
        RLMEvent *event;
        
        if (self.isSearching){
            event = self.searchResults[indexPath.row - 1];
            
        }else{
            event = self.events[indexPath.row - 1];
        }
        
        [self performSegueWithIdentifier:DGShowEventDetailsSegue sender:event];
    }
}

- (void)deleteButtonPressedInCell:(DGListingCollectionViewCell *)cell{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    RLMEvent *event;
    
    if (self.isSearching){
        event = self.searchResults[indexPath.row - 1];
    }else{
        event = self.events[indexPath.row - 1];
    }
    
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete the event \"%@\"?", event.name];
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Delete Event?"
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action){
                             [self deleteEvent:event];
                             
                         }];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:nil];
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteButtonPressedInTableViewCell:(DGLeadTableViewCell *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    RLMEvent *event;
    
    if (self.isSearching){
        event = self.searchResults[indexPath.row];
    }else{
        event = self.events[indexPath.row];
    }
    
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete the event \"%@\"", event.name];
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Delete Event?"
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action){
                             [self deleteEvent:event];
                             
                         }];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:nil];
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteEvent:(RLMEvent *)event{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteObject:event];
    [realm commitWriteTransaction];
    
    [[DGEventsManager sharedInstance] loadEventsFromDisk];
    
    //Refresh
    [self loadData];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isSearching){
        return [self.searchResults count];
        
    }else{
        return [self.events count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DGLeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeadCell" forIndexPath:indexPath];
    cell.delegate = self;
    
    RLMEvent *event;
    
    if (self.isSearching){
        event = self.searchResults[indexPath.row];
        
    }else{
        event = self.events[indexPath.row];
    }
    
    cell.addressLabel.text = event.name;
    cell.nameLabel.text = event.prettyDate;
    cell.deleteButton.hidden = event.attendees.count > 0;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RLMEvent *event;
    
    if (self.isSearching){
        event = self.searchResults[indexPath.row];
        
    }else{
        event = self.events[indexPath.row];
    }
    
    [self performSegueWithIdentifier:DGShowEventDetailsSegue sender:event];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:DGShowEventDetailsSegue]){
        DGEventDetailsViewController *vc = segue.destinationViewController;
        vc.selectedEvent = (RLMEvent *)sender;
    }
}

#pragma mark - UISearchBar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.isSearching = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(![searchBar isFirstResponder]) {
        // user tapped the 'clear' button
        self.shouldBeginEditing = NO;
        [self.collectionView setContentOffset:CGPointZero animated:YES];
        [self.tableView setContentOffset:CGPointZero animated:YES];
    }
    
    if([searchText length] != 0){
        [self search];
        
    }else{
        self.isSearching = NO;
    }
    
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.isSearching = NO;
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self search];
}

- (void)search{
    self.isSearching = YES;
    self.searchResults = [self.events filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[c] %@", self.searchBar.text]];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)bar {
    BOOL boolToReturn = self.shouldBeginEditing;
    self.shouldBeginEditing = YES;
    return boolToReturn;
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