//
//  DGGalleryViewController.m
//  DG Open House
//
//  Created by Chase Acton on 5/8/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import "DGGalleryViewController.h"
#import "SlideNavigationController.h"
#import "UIButton+Extensions.h"
#import "AFNetworkReachabilityManager.h"
#import "CAUpdateChecker.h"
#import "DGConstants.h"
#import "DGAddListingCollectionViewCell.h"
#import "DGListingCollectionViewCell.h"
#import "DGAPI.h"
#import "DGEvent.h"
#import "UIButton+BackgroundColor.h"
#import "DGAlert.h"
#import "RealmString.h"
#import "UIImage+DGImage.h"
#import "DGFileManager.h"
#import "NSUserDefaults+Convenience.h"

//Cells
static NSString * const DGAddListingCellIdentifier      = @"DGAddListingCell";
static NSString * const DGListingCellIdentifier         = @"DGListingCell";

@interface DGGalleryViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak) IBOutlet UIButton *menuButton;
@property (weak) IBOutlet UIButton *safeAgentButton;
@property (weak) IBOutlet UIButton *exitButton;
@property (weak) IBOutlet UICollectionView *collectionView;

@end

@implementation DGGalleryViewController

#pragma mark - View lifecycle

- (IBAction)openMenu{
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.menuButton setHitTestEdgeInsets:UIEdgeInsetsMake(-30, -30, -30, -30)];
    
    if (![[AFNetworkReachabilityManager sharedManager] isReachable] || ![NSUserDefaults shouldEnableSafeAgent]){
        self.safeAgentButton.hidden = YES;
    }
    
    [self.exitButton makeDGButtonWithIcon];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (IBAction)openSafeAgent{
    [self performSegueWithIdentifier:ShowSafeAgentSegue sender:self];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkReachableNotification:) name:DGNetworkReachableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkUnreachableNotification:) name:DGNetworkUnreachableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSafeAgentCheckNotification:) name:DGSafeAgentCheckNotification object:nil];
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

- (IBAction)back{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger count = 0;
    
    if (self.listing){
        count = [self.listing.images count];
        
    }else if (self.event){
        count = [self.event.images count];
    }
    
    return count + 1; // +1 for add new photo
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0){
        //Add listing
        DGAddListingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DGAddListingCellIdentifier forIndexPath:indexPath];
        
        cell.layer.borderWidth = 1.0;
        cell.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        
        return cell;
        
    }else{
        //Standard listing cell
        DGListingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DGListingCellIdentifier forIndexPath:indexPath];
        
        cell.mlsNumberLabel.backgroundColor = [UIColor whiteColor];
        
        if (self.listing){
            RealmString *string = self.listing.images[indexPath.row - 1];
            UIImage *image = [UIImage imageWithFilename:string.stringValue];
            cell.imageView.image = image;
            
        }else if (self.event){
            RealmString *string = self.event.images[indexPath.row - 1];
            UIImage *image = [UIImage imageWithFilename:string.stringValue];
            cell.imageView.image = image;
            
        }else{
            cell.imageView.image = nil;
        }
        
        cell.layer.borderWidth = 1.0;
        cell.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0){
        [self addPhoto];
    }
}

- (void)addPhoto{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    
    
    UIAlertController * alert =   [UIAlertController
                                   alertControllerWithTitle:nil
                                   message:nil
                                   preferredStyle:UIAlertControllerStyleActionSheet];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        UIAlertAction *camera = [UIAlertAction
                                 actionWithTitle:@"Take Photo"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action){
                                     imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                     [self presentViewController:imagePicker animated:YES completion:NULL];
                                 }];
        [alert addAction:camera];
        
    }
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        
        
        UIAlertAction *library = [UIAlertAction
                                 actionWithTitle:@"Choose Photo"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action){
                                     imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                     [self presentViewController:imagePicker animated:YES completion:NULL];
                                 }];
        
        [alert addAction:library];
    }
    
    [alert setModalPresentationStyle:UIModalPresentationPopover];
    [alert.popoverPresentationController setPermittedArrowDirections:0];

    UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
    popPresenter.sourceView = self.collectionView;
    popPresenter.sourceRect = self.collectionView.bounds;
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - ImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    NSString *uuid = [[[NSUUID UUID] UUIDString] lowercaseString];
    [DGFileManager saveImage:image withFilename:uuid];
    
    RLMRealm *realm = [RLMRealm defaultRealm];

    if (self.listing){
        RealmString *string = [[RealmString alloc] init];
        string.stringValue = uuid;
        
        //Update images
        [realm beginWriteTransaction];
        [self.listing.images addObject:string];
        [realm commitWriteTransaction];
        
    }else if (self.event){
        RealmString *string = [[RealmString alloc] init];
        string.stringValue = uuid;
        
        //Update images
        [realm beginWriteTransaction];
        [self.event.images addObject:string];
        [realm commitWriteTransaction];
    }
    
    [self.collectionView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end