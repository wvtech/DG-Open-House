//
//  DGAttendeeDetailsViewController.m
//  DG Open House
//
//  Created by Chase Acton on 4/24/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "DGAttendeeDetailsViewController.h"
#import "SlideNavigationController.h"
#import "UIButton+Extensions.h"
#import "DGAttendeeKeyValueTableViewCell.h"
#import "UIButton+BackgroundColor.h"
#import "DGConstants.h"
#import "AFNetworkReachabilityManager.h"
#import "UIColor+DGColor.h"
#import "DGAttendeeRatingTableViewCell.h"
#import "DGAttendeeNotesTableViewCell.h"
#import "IQKeyboardManager.h"
#import "SGFormatter.h"
#import "DGAlert.h"
#import "SVProgressHUD.h"
#import "UITextField+Utilities.h"
#import "NSDate+Utilities.h"
#import "DGServer.h"
#import "DGListingsManager.h"
#import "RLMAttendee.h"
#import "RLMListing.h"
#import "RLMFile.h"
#import "NSUserDefaults+Convenience.h"

@interface DGAttendeeDetailsViewController () <DGAttendeeRatingTableViewCellDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate, UIPopoverControllerDelegate>

@property (nonatomic) RLMAttendee *editedAttendee;

@property (weak) IBOutlet UIButton *safeAgentButton;

@property (weak) IBOutlet UIButton *menuButton;
@property (weak) IBOutlet UIButton *backButton;
@property (weak) IBOutlet UIButton *promoteButton;
@property (weak) IBOutlet UIButton *saveButton;
@property (weak) IBOutlet UIButton *discardButton;

@property (weak) IBOutlet NSLayoutConstraint *promoteButtonHeightConstraint;

@property (weak) IBOutlet UIImageView *promoteIcon;
@property (weak) IBOutlet UIImageView *saveIcon;
@property (weak) IBOutlet UIImageView *discardIcon;

@property (weak) IBOutlet UITableView *tableView;

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

@property (weak) IBOutlet UIImageView *cardImageView;
@property (weak) IBOutlet UIImageView *fullScreenCardImageView;

//Confirm view
@property (weak) IBOutlet UIView *confirmView;
@property (weak) IBOutlet UIButton *confirmCancelButton;
@property (weak) IBOutlet UIButton *confirmYesButton;
@property (weak) IBOutlet UILabel *confirmTitleLabel;

@end

@implementation DGAttendeeDetailsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.editedAttendee = [self.selectedAttendee copy];
    
    [self.menuButton setHitTestEdgeInsets:UIEdgeInsetsMake(-30, -30, -30, -30)];
    
    self.saveButton.enabled = NO;
    self.discardButton.enabled = NO;
    
    [self.backButton makeDGButtonWithIcon];
    [self.saveButton makeDGButtonWithIcon];
    [self.discardButton makeDGButtonWithIcon];
    [self.promoteButton makeDGButtonWithIcon];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkReachableNotification:) name:DGNetworkReachableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkUnreachableNotification:) name:DGNetworkUnreachableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSafeAgentCheckNotification:) name:DGSafeAgentCheckNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSyncCompleteNotification:) name:DGSyncCompleteNotification object:nil];

    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    //Tint icons
    [self.promoteIcon setTintColor:[UIColor buttonBlue]];
    [self disableButtons];
    
    self.promoteIcon.image  = [self.promoteIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.saveIcon.image     = [self.saveIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.discardIcon.image  = [self.discardIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:50];
    
    //Promote
    [self.promoteSubmitButton makeDGButton];
    [self.confirmCancelButton makeDGButton];
    [self.confirmYesButton makeDGButton];
    
    [self setupTextFields];
    
    NSDate *noon =  [[[NSCalendar currentCalendar] startOfDayForDate:[NSDate date]] dateByAddingHours:12];
    self.startTime = noon;
    self.endTime = [noon dateByAddingHours:2];
    
    [self updateFields];
    
    self.confirmTitleLabel.text = [NSString stringWithFormat:@"Are you sure you'd like to email the selected leads for %@ to promote the open house?", self.selectedAttendee.listing.prettyAddress];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.cardImageView addGestureRecognizer:singleFingerTap];

    [self setupEmailButton];
}

- (void)setupEmailButton{
    BOOL reachable = [[AFNetworkReachabilityManager sharedManager] isReachable];

    //Don't allow promoting event attendees
    if (self.selectedAttendee.eventID || !reachable){
        self.promoteButtonHeightConstraint.constant = 0;
        self.promoteButton.hidden = YES;
        self.promoteIcon.hidden = YES;
        
    }else{
        self.promoteButtonHeightConstraint.constant = 80;
        self.promoteButton.hidden = NO;
        self.promoteIcon.hidden = NO;
    }
    
    [self.promoteButton setNeedsLayout];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer{
    [self hideView:self.cardImageView];
    [self showView:self.overlayView];
    [self showView:self.fullScreenCardImageView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (![[AFNetworkReachabilityManager sharedManager] isReachable] || ![NSUserDefaults shouldEnableSafeAgent]){
        self.safeAgentButton.hidden = YES;
    }

    if (self.selectedAttendee.file){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(useCacheDirectory ? NSCachesDirectory : NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:self.selectedAttendee.file.filename];
        
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        self.cardImageView.image = image;
        self.fullScreenCardImageView.image = image;
    }
}

- (void)didReceiveSyncCompleteNotification:(NSNotification *)notification{
//    [self loadData];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - IBActions

- (IBAction)openMenu{
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (IBAction)back{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Safe Agent

- (IBAction)openSafeAgent{
    [self performSegueWithIdentifier:ShowSafeAgentSegue sender:self];
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

#pragma mark - Open House Promotion

- (IBAction)sendEmails{
    [SVProgressHUD show];
    
    [self hideView:self.confirmView];
    [self hideView:self.overlayView];
    
    [DGServer emailAttendees:@[self.selectedAttendee] date:self.openHouseDate start:self.startTime end:self.endTime callback:^(BOOL success, NSError *error) {
        [SVProgressHUD showSuccessWithStatus:@"Promotions sent!"];
    }];
}

- (IBAction)promote{
    if (![[AFNetworkReachabilityManager sharedManager] isReachable]){
        [DGAlert alertWithTitle:@"Internet Unavailable" message:@"Please connect to a network and try again." sender:self];
        return;
    }
    
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

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = 6; //Always at least 6 rows
    
    if (self.editedAttendee.buyTime){
        rows++;
    }
    
    if (self.editedAttendee.referralSourcePretty){
        rows++;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *key = [NSString stringWithFormat:@"%@", @(indexPath.row)];
    NSDictionary *row = [[self.editedAttendee tableViewDictionary] objectForKey:key];
    
    NSString *title = [row objectForKey:@"title"];
    NSString *value = [row objectForKey:@"value"];
    NSString *type = [row objectForKey:@"type"];
    
    if ([type isEqualToString:@"KeyValue"]){
        
        DGAttendeeKeyValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttendeeCell"];
        
        cell.keyLabel.text = title;
        
        if (indexPath.row == 2 || indexPath.row == 3){
            NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
            cell.valueLabel.attributedText = [[NSAttributedString alloc] initWithString:value attributes:underlineAttribute];
            
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }else{
            cell.valueLabel.text = value;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        return cell;
        
    }else if ([type isEqualToString:@"Notes"]){
        DGAttendeeNotesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotesCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.keyLabel.text = title;
        cell.notesTextView.text = value;
        cell.notesTextView.delegate = self;
        
        cell.notesTextView.layer.borderWidth = 1;
        cell.notesTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        return cell;
        
    }else{
        DGAttendeeRatingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RatingCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.delegate = self;
        
        cell.keyLabel.text = title;
        
        switch (self.editedAttendee.rating){
            case 0:
                [cell.star1Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
                [cell.star2Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
                [cell.star3Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
                [cell.star4Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
                [cell.star5Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
                break;
                
            case 1:
                [cell.star1Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
                [cell.star2Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
                [cell.star3Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
                [cell.star4Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
                [cell.star5Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
                break;
                
            case 2:
                [cell.star1Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
                [cell.star2Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
                [cell.star3Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
                [cell.star4Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
                [cell.star5Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
                break;
                
            case 3:
                [cell.star1Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
                [cell.star2Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
                [cell.star3Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
                [cell.star4Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
                [cell.star5Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
                break;
                
            case 4:
                [cell.star1Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
                [cell.star2Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
                [cell.star3Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
                [cell.star4Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
                [cell.star5Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
                break;
                
            case 5:
                [cell.star1Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
                [cell.star2Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
                [cell.star3Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
                [cell.star4Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
                [cell.star5Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
                break;
                
            default:
                break;
        }
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //Email
    if (indexPath.row == 2){
        if (self.selectedAttendee.email){
            [self sendEmail];
        }
    }
    
    //Phone
    if (indexPath.row == 3){
        if (self.selectedAttendee.phone){
            [self callPhone];
        }
    }
}

#pragma mark DGAttendeeRatingTableViewCellDelegate -

- (void)didSelectRating:(NSInteger)rating{
    self.editedAttendee.rating = rating;
    [self updateButtons];
    [self.tableView reloadData];
}

- (void)sendEmail{
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setToRecipients:@[self.editedAttendee.email]];
        mail.navigationBar.tintColor = [UIColor topBarBlue];
        mail.navigationBar.translucent = NO;
        
        [self presentViewController:mail animated:YES completion:nil];
    }else{
        [DGAlert errorWithMessage:NSLocalizedString(@"There is no email account set up on this device.", nil) sender:self];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (result == MFMailComposeResultSent){
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Message sent!", nil)];
        
    }else if (result == MFMailComposeResultFailed){
        [DGAlert errorWithMessage:NSLocalizedString(@"Error sending message. Please try again later.", nil) sender:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)callPhone{
    NSString *title = [NSString stringWithFormat:@"Call %@?", [SGFormatter formatPhoneNumber:self.editedAttendee.phone deleteLastChar:NO]];
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:nil
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:nil];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"Call"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action){
                             [self actuallyCallPhone];
                         }];
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)actuallyCallPhone{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel:%@", self.editedAttendee.phone]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]){
        [[UIApplication sharedApplication] openURL:phoneUrl];
        
    } else {
        [DGAlert errorWithMessage:@"This device can't make phone calls" sender:self];
    }
}

- (void)updateButtons{
    if ([self.selectedAttendee hash] == [self.editedAttendee hash]){
        [self disableButtons];
        
    }else{
        [self enableButtons];
    }
}

- (void)enableButtons{
    [self.saveIcon setTintColor:[UIColor buttonBlue]];
    [self.discardIcon setTintColor:[UIColor buttonBlue]];
    
    self.saveButton.enabled = YES;
    self.discardButton.enabled = YES;
}

- (void)disableButtons{
    [self.saveIcon setTintColor:[UIColor whiteColor]];
    [self.discardIcon setTintColor:[UIColor whiteColor]];
    
    self.saveButton.enabled = NO;
    self.discardButton.enabled = NO;
}

- (IBAction)discard{
    self.editedAttendee = self.selectedAttendee;
    [self updateButtons];
    [self.tableView reloadData];
}

- (IBAction)save{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];

    self.selectedAttendee.rating = self.editedAttendee.rating;
    self.selectedAttendee.notes = self.editedAttendee.notes;
    
    self.selectedAttendee.needsSynced = YES;
    
    self.editedAttendee = [self.selectedAttendee copy];
    
    UIAlertController *alert =   [UIAlertController
                                  alertControllerWithTitle:@""
                                  message:@"Saved Changes"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *downloadAction = [UIAlertAction
                                     actionWithTitle:@"Ok"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action){
                                     }];
    
    [alert addAction:downloadAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    [self updateButtons];
    [self.tableView reloadData];
    
    [realm commitWriteTransaction];

    //Sync
    [[DGListingsManager sharedInstance] sync:^(BOOL success){}];
}

- (void)textViewDidChange:(UITextView *)textView{
    self.editedAttendee.notes = textView.text;
    [self updateButtons];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.promoteView.alpha > 0){
        [self hideView:self.overlayView];
        [self hideView:self.promoteView];
        [self hideView:self.confirmView];
        
    }else if (self.fullScreenCardImageView.alpha > 0){
        [self hideView:self.overlayView];
        [self hideView:self.fullScreenCardImageView];
        [self showView:self.cardImageView];
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