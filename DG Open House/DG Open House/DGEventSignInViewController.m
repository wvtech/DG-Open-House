//
//  DGEventSignInViewController.m
//  DG Open House
//
//  Created by Chase Acton on 5/5/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGEventSignInViewController.h"
#import "DGConstants.h"
#import "AFNetworkReachabilityManager.h"

#import <UIImageView+AFNetworking.h>

#import "DGOpenHouseViewController.h"
#import "DGAPI.h"
#import "DGListing.h"
#import "DGUserManager.h"
#import "DGConstants.h"
#import "UITextField+Utilities.h"
#import "DGValidator.h"
#import "NSString+Utilities.h"
#import "UIButton+BackgroundColor.h"
#import "SGFormatter.h"
#import "DGQuestionTableViewCell.h"
#import "DGAttendeeTableViewCell.h"
#import "IQKeyboardManager.h"
#import "NSUserDefaults+Convenience.h"
#import "DGLeadsViewController.h"
#import "AFNetworkReachabilityManager.h"
#import "DGListingsManager.h"
#import "DGAlert.h"
#import "DGServer.h"
#import "DGEvent.h"
#import "UIImage+DGImage.h"
#import "DGSyncService.h"
#import "RLMEvent.h"

@interface DGEventSignInViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) RLMAttendee *currentAttendee;
@property (nonatomic) RLMAttendee *selectedAttendee;

//General views
@property (weak) IBOutlet UIView *overlayView;
@property (weak) IBOutlet UIImageView *agentImageView;
@property (weak) IBOutlet UILabel *agentNameLabel;
@property (weak) IBOutlet UIButton *startButton;

//Background image
@property (nonatomic) NSInteger currentImageIndex;
@property (weak) IBOutlet UIImageView *listingImageView;

//Menu
@property (weak) IBOutlet UIView *menuView;
@property (weak) IBOutlet UIButton *menuButton;
@property (weak) IBOutlet UIButton *safeAgentButton;
@property (weak) IBOutlet UIButton *endButton;
@property (weak) IBOutlet UIButton *notesButton;

//Agent questions
@property (weak) IBOutlet UIView *agentInfoView;
@property (weak) IBOutlet UITextField *agentFirstName;
@property (weak) IBOutlet UITextField *agentLastName;
@property (weak) IBOutlet UITextField *agentPhone;
@property (weak) IBOutlet UITextField *agentEmail;
@property (weak) IBOutlet UILabel *agentErrorLabel;

//End
@property (weak) IBOutlet UIView *thankYouView;
@property (weak) IBOutlet UILabel *thankYouAddressLabel;
@property (weak) IBOutlet UILabel *thankYouAgentNameLabel;
@property (weak) IBOutlet UILabel *thankYouAgentTitleLabel;
@property (weak) IBOutlet UILabel *thankYouAgentCellPhoneLabel;
@property (weak) IBOutlet UILabel *thankYouAgentEmailLabel;
@property (weak) IBOutlet UIImageView *thankYouAgentImageView;
@property (weak) IBOutlet UIImageView *thankYouLogoView;
@property (nonatomic) BOOL shouldReset;

//Notes
@property (weak) IBOutlet UIView *notesView;
@property (weak) IBOutlet UITableView *notesTableView;
@property (weak) IBOutlet UILabel *notesAddressLabel;

//Attendee
@property (weak) IBOutlet UIView *attendeeView;
@property (weak) IBOutlet UILabel *attendeeNameLabel;
@property (weak) IBOutlet UITextView *attendeeNotesTextView;
@property (weak) IBOutlet UIButton *attendeeSaveButton;
@property (weak) IBOutlet UIButton *attendeeCancelButton;
@property (nonatomic, weak) IBOutlet UIButton *star1Button;
@property (nonatomic, weak) IBOutlet UIButton *star2Button;
@property (nonatomic, weak) IBOutlet UIButton *star3Button;
@property (nonatomic, weak) IBOutlet UIButton *star4Button;
@property (nonatomic, weak) IBOutlet UIButton *star5Button;

//Card scanning
@property (weak) IBOutlet UIView *cardScanView;
@property (weak) IBOutlet UIButton *cardScanContinueButton;
@property (weak) IBOutlet UIButton *businessCardButton;
@property (weak) IBOutlet UIImageView *cardImageView;
@property (nonatomic) UIImage *selectedCardImage;

@end

@implementation DGEventSignInViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startSlideshow];
    
    [self setupButtons];
    
    [self reset];
    
    self.currentAttendee = [[RLMAttendee alloc] init];
    
    [self setupAgentInfo];
    [self setupTextFields];
    
    self.notesTableView.layer.borderWidth = 1;
    self.notesTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.notesTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.attendeeNotesTextView.layer.borderWidth = 1;
    self.attendeeNotesTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.cardImageView.layer.borderWidth = 1;
    self.cardImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkReachableNotification:) name:DGNetworkReachableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkUnreachableNotification:) name:DGNetworkUnreachableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSafeAgentCheckNotification:) name:DGSafeAgentCheckNotification object:nil];
}

- (void)didReceiveSafeAgentCheckNotification:(NSNotification *)notification{
    if ([[AFNetworkReachabilityManager sharedManager] isReachable] && [NSUserDefaults shouldEnableSafeAgent]){
        self.safeAgentButton.hidden = NO;
    }
}

- (void)didReceiveNetworkReachableNotification:(NSNotification *)notification{
    if ([NSUserDefaults shouldEnableSafeAgent]){
        self.safeAgentButton.hidden = NO;
    }
}

- (void)didReceiveNetworkUnreachableNotification:(NSNotification *)notification{
    self.safeAgentButton.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (![[AFNetworkReachabilityManager sharedManager] isReachable]){
        self.safeAgentButton.hidden = YES;
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)openSafeAgent{
    [self performSegueWithIdentifier:ShowSafeAgentSegue sender:self];
}

#pragma mark - View Configuration

- (void)setupButtons{
    [self.endButton makeDGButton];
    [self.notesButton makeDGButton];
    [self.attendeeSaveButton makeDGButton];
    [self.attendeeCancelButton makeDGButton];
    
    [self.businessCardButton makeDGButtonWithIcon];
    self.businessCardButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
}

- (void)setupAgentInfo{
    //Thank you view
    self.thankYouLogoView.image = [self.thankYouLogoView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.thankYouLogoView setTintColor:[UIColor colorWithRed:0.0 green:0.1373 blue:0.2863 alpha:1.0]];
    self.thankYouAddressLabel.text = self.currentEvent.name;
    
    //Notes
    self.notesAddressLabel.text = self.currentEvent.name;
    
    //Agent info
    RLMAgent *agent = [DGUserManager sharedInstance].currentAgent;
    
    //Bottom left
    self.agentNameLabel.text = agent.fullName;
    self.agentImageView.layer.cornerRadius = 32;
    self.agentImageView.image = [UIImage agentImage];
    
    //Thank you view
    self.thankYouAgentNameLabel.text = agent.fullName;
    self.thankYouAgentTitleLabel.text = agent.title;
    self.thankYouAgentCellPhoneLabel.text = [SGFormatter formatPhoneNumber:agent.phone deleteLastChar:NO];
    self.thankYouAgentEmailLabel.text = agent.email;
    self.thankYouAddressLabel.text = self.currentEvent.name;
    self.thankYouAgentImageView.image = [UIImage agentImage];
}

- (void)setupTextFields{
    [self styleTextField:self.agentFirstName];
    [self styleTextField:self.agentLastName];
    [self styleTextField:self.agentPhone];
    [self styleTextField:self.agentEmail];
}

- (void)styleTextField:(UITextField *)textField{
    [textField addLeftPadding];
    [textField setBorderColor:[UIColor lightGrayColor]];
}

#pragma mark - Event Flow
#pragma mark - General

- (void)resetAfterOpenHouse{
    if (self.shouldReset){
        [self reset];
    }
}

- (IBAction)startOpenHouse{
    self.shouldReset = NO;
    
    self.agentFirstName.placeholder = @"First Name";
    self.agentLastName.placeholder = @"Last Name";
    self.agentEmail.placeholder = @"Email";
    self.agentPhone.placeholder = @"Phone Number";;
    
    if (debug){
       /* self.agentFirstName.text = @"Chase";
        self.agentLastName.text = @"Acton";
        self.agentEmail.text = @"chaseacton@gmail.com";
        self.agentPhone.text = @"(123) 456-1234"; */
    }
    
    [self showViews:@[self.overlayView]];
    [self hideViews:@[self.menuButton, self.startButton, self.safeAgentButton]];
    
    [self startAgentFlow];
}

- (IBAction)endOpenHouse{
    self.currentAttendee = [[RLMAttendee alloc] init];
    [self reset];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)reset{
    [self hideViews:@[self.menuView, self.overlayView, self.thankYouView, self.notesView, self.attendeeView, self.agentInfoView]];
    [self showViews:@[self.menuButton, self.startButton, self.safeAgentButton]];
    
    [self clearFields];
    
    [self.view endEditing:YES];
}

- (void)clearFields{
    self.agentFirstName.text = nil;
    self.agentLastName.text = nil;
    self.agentPhone.text = nil;
    self.agentEmail.text = nil;
    
    self.agentErrorLabel.text = nil;
    
    [self setupTextFields];
}

- (IBAction)showMenu{
    [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:145];
    
    self.shouldReset = NO;
    
    if (self.menuView.alpha > 0){
        [self reset];
        
    }else{
        [self hideView:self.safeAgentButton];
        [self showViews:@[self.overlayView, self.menuView]];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.overlayView.alpha == 0){
        [self startOpenHouse];
        
    }else{
        UITouch *touch = [touches anyObject];
        self.shouldReset = NO;
        
        if (self.menuView.alpha > 0){
            if ([touch view] != self.menuView){
                [self reset];
            }
        }
        
        if (self.thankYouView.alpha > 0){
            if ([touch view] != self.thankYouView){
                [self reset];
            }
        }
    }
}

#pragma mark - Navigation

- (IBAction)backFromInfo{
    [self reset];
}

- (IBAction)backFromAttendeeNotes{
    if (self.attendeeView.alpha > 0){
        [self showView:self.notesView];
        [self hideView:self.attendeeView];
        
    }else if (self.notesView.alpha > 0){
        [self reset];
        [self hideView:self.notesView];
    }
}

#pragma mark - Attendee Notes

- (IBAction)openNotesView{
    [self.notesTableView reloadData];
    
    [self hideView:self.menuView];
    [self showView:self.notesView];
}

- (void)openAttendeeView{
    self.attendeeNameLabel.text = [NSString stringWithFormat:@"Attendee: %@", self.selectedAttendee.fullName];
    
    if (self.selectedAttendee.notes.length > 0){
        self.attendeeNotesTextView.text = self.selectedAttendee.notes;
    }
    
    [self displayRating];
    
    [self hideView:self.notesView];
    [self showView:self.attendeeView];
}

- (IBAction)saveAttendeeNotes{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    self.selectedAttendee.notes = [self.attendeeNotesTextView.text trimWhitespace];
    [self reset];
    
    //Sync
    self.selectedAttendee.needsSynced = YES;
    [realm commitWriteTransaction];
    
    [[DGListingsManager sharedInstance] sync:^(BOOL success){}];
}

- (IBAction)setRating:(id)sender{
    UIButton *button = (UIButton *)sender;
    NSInteger rating = button.tag;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    self.selectedAttendee.rating = rating;
    [realm commitWriteTransaction];
    
    [self displayRating];
}

- (void)displayRating{
    switch (self.selectedAttendee.rating){
        case 0:
            [self.star1Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
            [self.star2Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
            [self.star3Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
            [self.star4Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
            [self.star5Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
            break;
            
        case 1:
            [self.star1Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
            [self.star2Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
            [self.star3Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
            [self.star4Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
            [self.star5Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
            break;
            
        case 2:
            [self.star1Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
            [self.star2Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
            [self.star3Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
            [self.star4Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
            [self.star5Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
            break;
            
        case 3:
            [self.star1Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
            [self.star2Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
            [self.star3Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
            [self.star4Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
            [self.star5Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
            break;
            
        case 4:
            [self.star1Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
            [self.star2Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
            [self.star3Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
            [self.star4Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
            [self.star5Button setImage:[UIImage imageNamed:@"Star_White"] forState:UIControlStateNormal];
            break;
            
        case 5:
            [self.star1Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
            [self.star2Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
            [self.star3Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
            [self.star4Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
            [self.star5Button setImage:[UIImage imageNamed:@"Star_Blue"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

#pragma mark - Agent

- (IBAction)startAgentFlow{
    self.currentAttendee = [[RLMAttendee alloc] init];
    self.currentAttendee.date = [NSDate date];
    self.currentAttendee.isBuyer = NO;
    self.currentAttendee.eventID = self.currentEvent.eventID;
    
    NSString *uuid = [[[NSUUID UUID] UUIDString] lowercaseString];
    self.currentAttendee.attendeeID = uuid;
    
    [self showView:self.agentInfoView];
}

- (BOOL)validAgentDetails{
    BOOL valid = YES;
    
    NSString *phone = [[self.agentPhone.text componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    if (phone.length != 10){
        valid = NO;
        self.agentErrorLabel.text = @"Invalid phone number.";
        [self.agentPhone showError];
    }
    
    NSString *email = [self.agentEmail.text trimWhitespace];
    if (![DGValidator validateEmail:email]){
        valid = NO;
        self.agentErrorLabel.text = @"Invalid email address.";
        [self.agentEmail showError];
    }
    
    NSString *lastName = [self.agentLastName.text trimWhitespace];
    if (lastName.length < 2){
        valid = NO;
        self.agentErrorLabel.text = @"Last name must have at least 2 characters.";
        [self.agentLastName showError];
    }
    
    NSString *firstName = [self.agentFirstName.text trimWhitespace];
    if (firstName.length < 2){
        valid = NO;
        self.agentErrorLabel.text = @"First name must have at least 2 characters.";
        [self.agentFirstName showError];
    }
    
    return valid;
}

- (IBAction)saveAgentDetails{
    [self.view endEditing:YES];
    self.agentErrorLabel.text = nil;
    
    if (![self validAgentDetails]){
        return;
    }
    
    NSString *firstName     = [self.agentFirstName.text trimWhitespace];
    NSString *lastName      = [self.agentLastName.text trimWhitespace];
    NSString *email         = [self.agentEmail.text trimWhitespace];
    NSString *phone         = [[self.agentPhone.text componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    
    self.currentAttendee.firstName = firstName;
    self.currentAttendee.lastName = lastName;
    self.currentAttendee.email = email;
    self.currentAttendee.phone = phone;
    
    [self setupTextFields];
    
    [self hideView:self.agentInfoView];
    [self showView:self.thankYouView];
}

#pragma mark - Business Card

- (IBAction)openCamera{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        [self presentViewController:imagePicker animated:YES completion:NULL];
        
    }else{
        [DGAlert errorWithMessage:@"This device can't take photos" sender:self];
    }
}

- (IBAction)deleteImage{
    self.selectedCardImage = nil;
    self.cardImageView.image = nil;
    
    [self hideView:self.cardScanView];
    [self showView:self.agentInfoView];
}

- (IBAction)promptDeleteImage{
    UIAlertController *alert =   [UIAlertController
                                  alertControllerWithTitle:@"Remove the business card?"
                                  message:nil
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *no = [UIAlertAction
                         actionWithTitle:@"Cancel"
                         style:UIAlertActionStyleDefault
                         handler:nil];
    
    UIAlertAction *yes = [UIAlertAction
                          actionWithTitle:@"OK"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action){
                              [self deleteImage];
                          }];
    
    [alert addAction:no];
    [alert addAction:yes];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)businessCardContinue{
    [self hideView:self.cardScanView];
    [self showView:self.thankYouView];
}

#pragma mark - ImagePickerController Delegate -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.selectedCardImage = image;
    self.cardImageView.image = self.selectedCardImage;
    
    [self hideView:self.agentInfoView];
    [self showView:self.cardScanView];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (self.agentInfoView.alpha > 0){
        if (textField == self.agentFirstName){
            [self.agentLastName becomeFirstResponder];
            
        }else if (textField == self.agentLastName){
            [self.agentEmail becomeFirstResponder];
            
        }else if (textField == self.agentEmail){
            [self.agentPhone becomeFirstResponder];
            
        }else if (textField == self.agentPhone){
            [self saveAgentDetails];
        }
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSInteger fieldHeight = 48;
    
    if (self.agentInfoView.alpha > 0){
        
        NSInteger topSpace = 226;
        
        if (textField == self.agentFirstName){
            [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:topSpace];
            
        }else if (textField == self.agentLastName){
            [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:topSpace];
            
        }else if (textField == self.agentEmail){
            [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:topSpace - (fieldHeight * 1)];
            
        }else if (textField == self.agentPhone){
            [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:topSpace - (fieldHeight * 2)];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField == self.agentPhone) {
        NSString *totalString = [NSString stringWithFormat:@"%@%@",textField.text,string];
        
        if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound){
            return NO;
        }
        
        // if it's the phone number textfield format it.
        if (range.length == 1) {
            // Delete button was hit.. so tell the method to delete the last char.
            textField.text = [SGFormatter formatPhoneNumber:totalString deleteLastChar:YES];
        } else {
            textField.text = [SGFormatter formatPhoneNumber:totalString deleteLastChar:NO ];
        }
        return NO;
        
    }
    
    return YES;
}

#pragma mark - Animation Helpers

- (void)showViews:(NSArray *)views{
    for (UIView *view in views){
        [self showView:view];
    }
}

- (void)hideViews:(NSArray *)views{
    for (UIView *view in views){
        [self hideView:view];
    }
}

- (void)showView:(id)view{
    if (view == self.safeAgentButton){
        //Manual override because we want this button to be transparent
        [self setView:view toAlpha:0.55];
    }else{
        [self setView:view toAlpha:1];
    }
    
    if (view == self.thankYouView){
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        self.currentAttendee.needsSynced = YES;
        
        //Business card
        NSString *cardUuid = [[[NSUUID UUID] UUIDString] lowercaseString];
        if (self.selectedCardImage){
            self.currentAttendee.cardFileID = cardUuid;
        }
        
        [self.currentEvent.attendees addObject:self.currentAttendee];
        
        if (self.selectedCardImage){
            //Create file
            RLMFile *file = [[RLMFile alloc] init];
            file.filename = [NSString stringWithFormat:@"%@.jpg",cardUuid];
            file.fileID = cardUuid;
            file.agentID = [DGUserManager sharedInstance].currentAgent.agentID;
            file.type = DGFileTypeEvent;
            file.date = [NSDate date];
            
            //Save image
            NSArray *paths = NSSearchPathForDirectoriesInDomains(useCacheDirectory ? NSCachesDirectory : NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:file.filename];
            [UIImageJPEGRepresentation(self.selectedCardImage, 1.0) writeToFile:filePath atomically:YES];
            
            NSError *error = nil;
            BOOL success = [[NSURL fileURLWithPath:filePath] setResourceValue:[NSNumber numberWithBool: YES]
                                                                       forKey: NSURLIsExcludedFromBackupKey error: &error];
            if(!success){
                NSLog(@"Error excluding %@ from backup %@", [[NSURL URLWithString:filePath] lastPathComponent], error);
            }
            
            self.currentAttendee.file = file;
            
            [realm commitWriteTransaction];
            
            [DGServer uploadFile:file callback:^(BOOL success, NSError *error) {
                NSLog(@"Upload file success: %@", success ? @"Yes" : @"No");
                if (success){
                    [[DGListingsManager sharedInstance] sync:^(BOOL success){
                        if (success){
                            [DGServer uploadImage:self.selectedCardImage uuid:cardUuid completion:^(BOOL success, NSError *error) {
                                NSLog(@"Upload image success: %@", success ? @"Yes" : @"No");
                                if (success){
//                                    [DGSyncService downloadAllDataWithHUD:NO callback:^(BOOL success, NSError *error) {}];
                                }
                            }];
                        }
                    }];
                }
            }];
            
            self.shouldReset = YES;
            [self performSelector:@selector(resetAfterOpenHouse) withObject:nil afterDelay:4];
            
        }else{
            [realm commitWriteTransaction];
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                
                [[DGListingsManager sharedInstance] sync:^(BOOL success){
                    if (success){
//                        [DGSyncService downloadAllDataWithHUD:NO callback:^(BOOL success, NSError *error) {}];
                    }
                }];
            });
            self.shouldReset = YES;
            [self performSelector:@selector(resetAfterOpenHouse) withObject:nil afterDelay:4];
        }
    }
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

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.currentEvent.attendees count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DGAttendeeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttendeeCell"];
    
    RLMAttendee *attendee = self.currentEvent.attendees[indexPath.row];
    
    //Attendee name
    cell.nameLabel.text = attendee.fullName;
    
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedAttendee = self.currentEvent.attendees[indexPath.row];
    [self openAttendeeView];
}

#pragma mark - Slideshow

- (void)startSlideshow{
    if ([self.currentEvent.images count] > 0){
        [UIView transitionWithView:self.listingImageView
                          duration:0.75
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            
                            RealmString *string = self.currentEvent.images[self.currentImageIndex];
                            UIImage *image = [UIImage imageWithFilename:string.stringValue];
                            if (image){
                                self.listingImageView.image = image;
                            }
                            
                        } completion:^(BOOL finished){
                            //Increment or reset index
                            if (self.currentImageIndex < [self.currentEvent.images count] - 1){
                                self.currentImageIndex++;
                            }else{
                                self.currentImageIndex = 0;
                            }
                            
                            //Start the next animation
                            [self performSelector:@selector(startSlideshow) withObject:nil afterDelay:5];
                        }
         ];
    }else{
        self.listingImageView.image = [UIImage imageNamed:@"DefaultEventImage"];
    }
}

@end