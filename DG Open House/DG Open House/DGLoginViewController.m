//
//  DGLoginViewController.m
//  DG Open House
//
//  Created by Chase Acton on 2/1/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGLoginViewController.h"
#import "DGServer.h"
#import "SVProgressHUD.h"
#import "DGAlert.h"
#import "DGUserManager.h"
#import "DGValidator.h"
#import "DGListingsViewController.h"
#import "DGListingsManager.h"
#import "DGKeychain+StoredData.h"
#import "AFNetworkReachabilityManager.h"
#import "NSUserDefaults+Convenience.h"
#import "DGEventsManager.h"
#import "DGConstants.h"
#import "DGSyncService.h"
#import "NSString+Utilities.h"
//#import "DGAgent.h"

static NSString * const DGShowListingsSegue = @"ShowListingsSegue";

@interface DGLoginViewController () <UITextFieldDelegate>

@property (weak) IBOutlet UITextField *emailField;
@property (weak) IBOutlet UITextField *passwordField;
@property (weak) IBOutlet UILabel *versionLabel;

@end

@implementation DGLoginViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTextFields];
    
    if ([NSUserDefaults hasSignedInBefore]){
        [self performSelector:@selector(attemptAutoSignIn) withObject:nil afterDelay:1];
        
    }
//    else if (debug){
//        [self performSelector:@selector(attemptAutoSignIn) withObject:nil afterDelay:1];
//    }
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *appBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *versionString = [NSString stringWithFormat:NSLocalizedString(@"Version %@ (%@)", nil), appVersion,appBuild];
    
    self.versionLabel.text = versionString;
}

- (void)viewWillAppear:(BOOL)animated{
    KAppDelegate.intPhaseNo = 1;
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - Main methods

- (void)setupTextFields{
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.emailField setLeftViewMode:UITextFieldViewModeAlways];
    [self.emailField setLeftView:spacerView];
    
    UIView *spacerView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.passwordField setLeftViewMode:UITextFieldViewModeAlways];
    [self.passwordField setLeftView:spacerView2];
}

- (void)attemptAutoSignIn{
//    if (debug){
//        //        self.emailField.text = @"cathydeignan@danielgale.com";
//        //        self.passwordField.text = @"georgePassword1";
//        
//        //        self.emailField.text = @"nataliedeur@danielgale.com";
//        //        self.passwordField.text = @"Bursa123";
//        
//        [self signIn];
//        
//        return;
//    }
    
    NSString *email = [DGKeychain userEmail];
    NSString *password = [DGKeychain userPassword];
    
    if (email && password){
        self.emailField.text = email;
        self.passwordField.text = password;
        KAppDelegate.flagIsLoginFirstTime = NO;
        [self signIn];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:DGShowListingsSegue]){
        DGListingsViewController *vc = segue.destinationViewController;
        vc.showActiveListings = YES;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
        
    } else if (textField == self.passwordField) {
        [self signIn];
    }
    
    return NO;
}

#pragma mark - IBActions

- (IBAction)signIn{
    KAppDelegate.flagIsLoginFirstTime = YES;
    
    if ([[AFNetworkReachabilityManager sharedManager] isReachable]){
        
        NSString *email = self.emailField.text;
        email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString *password = self.passwordField.text;
        password = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (![DGValidator validateEmail:email]){
            [DGAlert errorWithMessage:@"Invalid email address" sender:self];
            return;
        }
        
        [self.view endEditing:YES];
        
        NSLog(@"needToSignin: %@", [self needToSignin] ? @"y" : @"n");
        if ([self needToSignin]){
            [SVProgressHUD showWithStatus:@"Signing In…"];
            [NSUserDefaults setHasSignedInBefore:YES];
            [SVProgressHUD showWithStatus:@"Downloading Listings…"];
            [[DGUserManager sharedInstance] signInWithEmail:email password:password completion:^(BOOL success, NSError *error) {
                if (success){
                    
                    [DGSyncService downloadAllDataWithHUD:YES callback:^(BOOL success, NSError *error) {
                         [self performSegueWithIdentifier:DGShowListingsSegue sender:self];
                        [NSUserDefaults setHasDownloadedAllData:YES];
                        [NSUserDefaults setHasSignedInBefore:YES];
                        KAppDelegate.flagIsLoginFirstTime = YES;
                       
                    }];
                    
                }else{
                    NSLog(@"Login Error = %@", error.userInfo);
                    NSDictionary * dict = error.userInfo;
                    [SVProgressHUD dismiss];
                    if([dict[@"NSLocalizedDescription"] isEqualToString:@"Request failed: unauthorized (401)"]) {
                        [DGAlert errorWithMessage:@"Invalid username or password" sender:self];
                        
                    } else {
                       [self showAlertViewWithCancelOptionandMessage:@"Please wait while synchronization is in process"];
                    }

                    
                }
            }];
            
        }else{
            if ([NSUserDefaults hasDownloadedAllData]){
                [self performSegueWithIdentifier:DGShowListingsSegue sender:self];
            }else{
                if([DGListingsManager sharedInstance].listingsToAdd.count!=0)
                {
                    [self performSegueWithIdentifier:DGShowListingsSegue sender:self];
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
                    dispatch_async(queue, ^{
                        // Perform async operation
                        [DGSyncService downloadAllDataInBackGroundWithHUD:YES callback:^(BOOL success, NSError *error) {
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SVProgressHUD dismiss];
                                [NSUserDefaults setHasDownloadedAllData:YES];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"Loaddata" object:nil];
                                [self performSegueWithIdentifier:DGShowListingsSegue sender:self];
                            });
                            //  [SVProgressHUD dismiss];
                            // Call your method/function here
                            // Example:
                            // NSString *result = [anObject calculateSomething];
                            
                        }]; 
                    });

                }else  {
                    [SVProgressHUD showWithStatus:@"Signing In…"];
                    [SVProgressHUD showWithStatus:@"Downloading listings…"];
                    [[DGUserManager sharedInstance] signInWithEmail:email password:password completion:^(BOOL success, NSError *error) {
                        if (success){
                            
                            [DGSyncService downloadAllDataWithHUD:YES callback:^(BOOL success, NSError *error) {
                                [NSUserDefaults setHasDownloadedAllData:YES];
                                [self performSegueWithIdentifier:DGShowListingsSegue sender:self];
                            }];
                            
                        }else{
                            
                            NSDictionary * dict = error.userInfo;
                            [SVProgressHUD dismiss];
                            if([dict[@"NSLocalizedDescription"] isEqualToString:@"Request failed: unauthorized (401)"]) {
                                
                                [DGAlert errorWithMessage:@"Invalid username or password" sender:self];
                            } else {
                              //  [DGAlert alertWithTitle:@"" message:@"Please wait while synchronization is in process" sender:self];
                                [self showAlertViewWithCancelOptionandMessage:@"Please wait while synchronization is in process"];
                            }
                        }
                    }];

                }
            }
        }
        
    }else{
        if ([NSUserDefaults hasDownloadedAllData]){
            [self performSegueWithIdentifier:DGShowListingsSegue sender:self];
        }else{
            [DGAlert errorWithMessage:@"This app requires Internet access to verify your identity. Please connect to a WiFi access point then try again." sender:self];
        }
    }
}

- (BOOL)needToSignin{
    NSString *token = [DGKeychain token];
    RLMAgent *agent = [DGUserManager sharedInstance].currentAgent;
    
    if (token && agent){
        return NO;
    }
    return YES;
}

- (IBAction)forgotPassword{
    UIAlertController *alert =   [UIAlertController
                                  alertControllerWithTitle:@"Request Password"
                                  message:@"Enter your email address to retrieve your password."
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Daniel Gale Email Address";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        if ([self.emailField.text trimWhitespace].length > 0){
            textField.text = self.emailField.text;
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Cancel", nil)
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action){
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    UIAlertAction *save = [UIAlertAction
                           actionWithTitle:NSLocalizedString(@"Request Password", nil)
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action){
                               UITextField *textField = (UITextField *)[alert.textFields firstObject];
                               
                               NSString *email = [textField.text trimWhitespace];
                               
                               if (email.length == 0) {
                                   //If field is empty, ask for user's email address
                                   [SVProgressHUD dismiss];
                                   [SVProgressHUD showErrorWithStatus:@"Please enter your Daniel Gale email address."];
                                   
                                   [self forgotPassword];
                                   return;
                               }
                               
                               if (![DGValidator validateEmail:email]){
                                   [SVProgressHUD showErrorWithStatus:@"Invalid email address."];
                                   [self forgotPassword];
                                   return;
                               }
                               [SVProgressHUD show];
                               
                               [DGServer forgotPassword:email callback:^(BOOL success, NSError *error) {
                                   [SVProgressHUD dismiss];
                                   
                                   if (success){
                                       [SVProgressHUD showSuccessWithStatus:@"Your Open House App Password has been sent to your Daniel Gale Email Address."];
                                       self.emailField.text = email;
                                       
                                   }else{
                                       [SVProgressHUD showErrorWithStatus:@"Email address not found."];
                                   }
                               }];
                           }];
    
    [alert addAction:cancel];
    [alert addAction:save];
    
    UITextField *textField = (UITextField *)[alert.textFields firstObject];
    [textField becomeFirstResponder];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) showAlertViewWithCancelOptionandMessage:(NSString *) strMsg {
    /// it is the default method in iOS 9 replacing or way of representing the alert view or action sheet.
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:strMsg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction  actionWithTitle:NSLocalizedString(@"Ok", @"Cancel action")
                                                            style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                                                NSLog(@"Cancel action");
                                                                [SVProgressHUD showWithStatus:@"Signing In…"];
                                                                [DGSyncService downloadAllDataWithHUD:YES callback:^(BOOL success, NSError *error) {
                                                                    [NSUserDefaults setHasDownloadedAllData:YES];
                                                                    [NSUserDefaults setHasSignedInBefore:YES];
                                                                    KAppDelegate.flagIsLoginFirstTime = YES;
                                                                    [self performSegueWithIdentifier:DGShowListingsSegue sender:self];
                                                                    
                                                                }];
                                                                
                                                                
                                                            }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
