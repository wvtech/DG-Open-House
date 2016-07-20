//
//  DGSafeAgentProfileViewController.m
//  DG Open House
//
//  Created by Chase Acton on 4/28/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGSafeAgentProfileViewController.h"
#import "UITextField+Utilities.h"
#import "SGConstants.h"
#import "SGFormatter.h"
#import "SlideNavigationController.h"
#import "DGListingsViewController.h"
#import "UIButton+Extensions.h"
#import "NSUserDefaults+Convenience.h"
#import "DGUserManager.h"
#import "DGConstants.h"
#import "AFNetworkReachabilityManager.h"

@interface DGSafeAgentProfileViewController ()

@property (weak) IBOutlet UILabel *titleLabel;

@property (weak) IBOutlet UIView *fieldsView;

@property (weak) IBOutlet UITextField *firstNameField;
@property (weak) IBOutlet UITextField *lastNameField;
@property (weak) IBOutlet UITextField *phoneField;
@property (weak) IBOutlet UITextField *pinField;

@property (weak) IBOutlet UIButton *menuButton;
@property (weak) IBOutlet UIButton *safeAgentButton;

@end

@implementation DGSafeAgentProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.menuButton setHitTestEdgeInsets:UIEdgeInsetsMake(-30, -30, -30, -30)];

    self.titleLabel.text = @"Please verify information and choose a 4 digit PIN to Activate DG Safe Agent.\nChoose a 4 digit PIN that is easy for you to rememebr.";
    
    self.fieldsView.layer.borderWidth = 1;
    self.fieldsView.layer.borderColor = [UIColor colorWithRed:0.0 green:0.1373 blue:0.2863 alpha:1.0].CGColor;
    
    [self setupTextFields];
    [self setFields];
    
    if (![NSUserDefaults pinForAgent:[DGUserManager sharedInstance].currentAgent.agentID] || ![NSUserDefaults shouldEnableSafeAgent]){
        self.menuButton.hidden = YES;
        self.safeAgentButton.hidden = YES;
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

- (IBAction)openSafeAgent{
    [self performSegueWithIdentifier:ShowSafeAgentSegue sender:self];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupTextFields{
    [self styleTextField:self.firstNameField];
    [self styleTextField:self.lastNameField];
    [self styleTextField:self.phoneField];
    [self styleTextField:self.pinField];
}

- (void)styleTextField:(UITextField *)textField{
    [textField addLeftPadding];
    [textField setBorderColor:[UIColor colorWithRed:0.0 green:0.1373 blue:0.2863 alpha:1.0]];
}

- (void)setFields{
    NSString *agentID = [DGUserManager sharedInstance].currentAgent.agentID;

    self.firstNameField.text = [NSUserDefaults firstNameForAgent:agentID];
    self.lastNameField.text = [NSUserDefaults lastNameForAgent:agentID];
    self.phoneField.text = [SGFormatter formatPhoneNumber:[NSUserDefaults phoneForAgent:agentID] deleteLastChar:NO];
    self.pinField.text = [NSUserDefaults pinForAgent:[DGUserManager sharedInstance].currentAgent.agentID];
}

- (IBAction)openMenu{
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (IBAction)save{
    [self setupTextFields];
    
    NSString *first = [self.firstNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *last = [self.lastNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *phone = [[self.phoneField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    NSString *pin = [[self.pinField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    
    BOOL valid = YES;
    
    if (first.length < 1){
        [self.firstNameField showError];
        valid = NO;
    }
    
    if (last.length < 1){
        [self.lastNameField showError];
        valid = NO;
    }
    
    if (phone.length != 10){
        [self.phoneField showError];
        valid = NO;
    }
    
    if (pin.length != 4){
        [self.pinField showError];
        valid = NO;
    }
    
    if (valid){
        [self.view endEditing:YES];
        
        //Reset text fields
        [self setupTextFields];
        
        NSString *agentID = [DGUserManager sharedInstance].currentAgent.agentID;

        [NSUserDefaults setFirstName:first forAgent:agentID];
        [NSUserDefaults setLastName:last forAgent:agentID];
        [NSUserDefaults setPhone:phone forAgent:agentID];
        
        [NSUserDefaults setPin:pin forAgent:[DGUserManager sharedInstance].currentAgent.agentID];
        
        [self close];
    }
}

- (void)close{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    DGListingsViewController *home = [mainStoryboard instantiateViewControllerWithIdentifier:@"DGListingsViewController"];
    home.showActiveListings = YES;
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:home
                                                             withSlideOutAnimation:NO
                                                                     andCompletion:nil];
}

#pragma mark - TextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField == self.phoneField) {
        NSString* totalString = [NSString stringWithFormat:@"%@%@",textField.text,string];
        
        if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound){
            // BasicAlert(@"", @"This field accepts only numeric entries.");
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
        
    }else if (textField == self.pinField){
        // allow backspace
        if (!string.length){
            return YES;
        }
        
        // Prevent invalid character input, if keyboard is numberpad
        if (textField.keyboardType == UIKeyboardTypeNumberPad){
            if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound){
                return NO;
            }
        }
        
        // verify max length has not been exceeded
        NSString *updatedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (updatedText.length > 4){ //4 digit PIN
            //            if (string.length > 1){
            //                // BasicAlert(@"", @"This field accepts a maximum of 4 characters.");
            //            }
            
            return NO;
        }
        
    }else{
        NSRange lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
        if (lowercaseCharRange.location != NSNotFound) {
            textField.text = [textField.text stringByReplacingCharactersInRange:range withString:[string uppercaseString]];
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.firstNameField) {
        [self.lastNameField becomeFirstResponder];
        
    } else if (textField == self.lastNameField) {
        [self.phoneField becomeFirstResponder];
        
    } else if (textField == self.phoneField) {
        [self.pinField becomeFirstResponder];
        
    } else if (textField == self.pinField) {
        [self.view endEditing:YES];
    }
    
    return NO;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(paste:))
        return NO;
    if (action == @selector(select:))
        return NO;
    if (action == @selector(selectAll:))
        return NO;
    return [super canPerformAction:action withSender:sender];
}

@end