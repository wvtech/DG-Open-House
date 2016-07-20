//
//  DGSafeAgentPoliceViewController.m
//  DG Open House
//
//  Created by Chase Acton on 4/29/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGSafeAgentPoliceViewController.h"
#import "SGAlert.h"
#import "UITextField+Utilities.h"
#import "SGConstants.h"
#import "DGAlert.h"
#import "SVProgressHUD.h"
#import "SGServer.h"
#import "PROPLocationManager.h"
#import "NSUserDefaults+Convenience.h"
#import "DGUserManager.h"

@interface DGSafeAgentPoliceViewController ()

@property (weak) IBOutlet UILabel *titleLabel;
@property (weak) IBOutlet UILabel *countdownLabel;

@property (weak) IBOutlet UITextField *pinField;

@property (nonatomic) SGAlert *currentAlert;

@property (nonatomic) NSInteger timeRemaining;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) BOOL dismissing;

@end

@implementation DGSafeAgentPoliceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTextFields];
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.pinField];
    

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.timeRemaining = 10;
    self.dismissing = NO;
    
    if ([self hasLocation]){
        self.timer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
    }else{
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"Location Unavailable"
                                    message:@"Couldn't get your current location. Please allow location permission for DG Open House in settings."
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action){
                                 [self close];
                             }];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (BOOL)hasLocation{
    CLLocation *location = [[PROPLocationManager sharedManager] lastKnownLocation];
    
    if (!location){
        return NO;
    }else{
        if (location.coordinate.latitude == 0 || location.coordinate.longitude == 0){
            return NO;
        }
        return YES;
    }
}

- (void)textFieldDidChange:(NSNotification *)notification {
    [self checkPin];
}

- (void)checkPin{
    if (self.pinField.text.length == 4){
        [self cancelAlert];
    }
}

- (void)updateCountdown{
    if (self.timeRemaining > 1){
        self.timeRemaining--;
        self.countdownLabel.text = [NSString stringWithFormat:@"%@ %@ left",
                                    @(self.timeRemaining),
                                    self.timeRemaining == 1 ? @"second" : @"seconds"];
    }else{
        [self.timer invalidate];
        self.timer = nil;
        
        self.countdownLabel.text = @"Police are on the way";
        self.titleLabel.text = @"Enter PIN to cancel";
        [self sendPolice];
    }
}

- (void)setupTextFields{
    [self.pinField addLeftPadding];
    [self.pinField setBorderColor:[UIColor lightGrayColor]];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    BOOL okToEdit = YES;
    
    if (range.location > 3){
        okToEdit = NO;
    }
    
    return okToEdit;
}

- (IBAction)clear{
    self.pinField.text = nil;
}

- (IBAction)pressedNumber:(UIButton *)sender{
    if (self.pinField.text.length < 4){
        self.pinField.text = [self.pinField.text stringByAppendingString:sender.titleLabel.text];
    }
    [self checkPin];
}

- (IBAction)dial911{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Dial 911?"
                                message:nil
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:nil];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"Dial 911"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action){
                             [self actuallyDial911];
                         }];
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)actuallyDial911{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel:%@", SGEmergencyNumber]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]){
        [[UIApplication sharedApplication] openURL:phoneUrl];
        
    } else {
        [DGAlert errorWithMessage:@"This device can't make phone calls" sender:self];
    }
}

- (void)sendPolice{
    NSString *agentID = [DGUserManager sharedInstance].currentAgent.agentID;
    
    NSString *name = [NSString stringWithFormat:@"%@ %@", [NSUserDefaults firstNameForAgent:agentID], [NSUserDefaults lastNameForAgent:agentID]];
    NSString *phone = [NSUserDefaults phoneForAgent:agentID];
    NSString *pin = [NSUserDefaults pinForAgent:[DGUserManager sharedInstance].currentAgent.agentID];
    
    CLLocation *location = [[PROPLocationManager sharedManager] lastKnownLocation];
    
    NSDictionary *params = @{
                             SGAPIParamName:    name,
                             SGAPIParamPhone:   phone,
                             SGAPIParamPin:     pin,
                             SGAPIParamLocation: @{
                                     SGAPIParamLat:         @(location.coordinate.latitude),
                                     SGAPIParamLon:         @(location.coordinate.longitude),
                                     SGAPIParamAccuracy:    @(location.horizontalAccuracy)
                                     }
                             };
    
    [SVProgressHUD show];
    [[SGServer sharedInstance] createAlert:params callback:^(NSError *error, SGAlert *alert) {
        [SVProgressHUD dismiss];
        
        if (!error){
            self.currentAlert = alert;
        }
    }];
}

- (void)showWrongPIN{
    [self.pinField showError];
    self.pinField.textColor = [UIColor redColor];
    [self performSelector:@selector(resetPinField) withObject:nil afterDelay:0.75];
}

- (void)resetPinField{
    [self.pinField setBorderColor:[UIColor lightGrayColor]];
    self.pinField.textColor = [UIColor colorWithRed:0.0/255.0 green:35.0/255.0 blue:73.0/255.0 alpha:1.0];
}

- (void)cancelAlert{
    NSString *pin = [NSUserDefaults pinForAgent:[DGUserManager sharedInstance].currentAgent.agentID];
    
    if (![self.pinField.text isEqualToString:pin]){
        [self showWrongPIN];
        [self.pinField shake];
        return;
    }
    
    [self.view endEditing:YES];
    
    self.titleLabel.text = @"Alert Cancelled";
    
    [self.timer invalidate];
    self.timer = nil;
    
    if (self.currentAlert){
        [SVProgressHUD show];
        
        [[SGServer sharedInstance] cancelAlert:self.currentAlert.alertID callback:^(NSError *error, NSString *message) {
            [SVProgressHUD dismiss];
            [self performSelector:@selector(close) withObject:nil afterDelay:1];
        }];
        
    }else{
        [self performSelector:@selector(close) withObject:nil afterDelay:1];
    }
}

- (void)close{
    if (self.dismissing){
        return;
    }
    self.dismissing = YES;
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        self.dismissing = NO;
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end