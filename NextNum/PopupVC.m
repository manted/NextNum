//
//  PopupVC.m
//  NextNum
//
//  Created by Manted on 16/03/2014.
//  Copyright (c) 2014 Ye Hua. All rights reserved.
//

#import "PopupVC.h"
#import <FacebookSDK/FacebookSDK.h>

@interface PopupVC ()
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (nonatomic) int score;
@property (weak, nonatomic) IBOutlet UIImageView *imgV;

@end

@implementation PopupVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.scoreLabel setText:[NSString stringWithFormat:@"%d",self.score]];
    self.imgV.image = self.img;
}

//-(void)setImg:(UIImage *)img
//{
//    self.img = img;
//    self.imgV.image = self.img;
//}

-(void)setFinalScore:(int)score
{
    self.score = score;
    [self.scoreLabel setText:[NSString stringWithFormat:@"%d",score]];
}

- (IBAction)tryAgain:(id)sender {
    [self.vc tryAgain];
}

- (IBAction)shareToFacebook:(id)sender {
    if ([FBDialogs canPresentShareDialogWithPhotos]) {
        NSLog(@"canPresentShareDialogWithPhotos");
        FBShareDialogPhotoParams *params = [[FBShareDialogPhotoParams alloc] init];
        
        // Note that params.photos can be an array of images.  In this example
        // we only use a single image, wrapped in an array.
        params.photos = @[self.img];
        
        [FBDialogs presentShareDialogWithPhotoParams:params
                                         clientState:nil
                                             handler:^(FBAppCall *call,
                                                       NSDictionary *results,
                                                       NSError *error) {
                                                 if (error) {
                                                     NSLog(@"Error: %@",
                                                           error.description);
                                                 } else {
                                                     NSLog(@"Success!");
                                                 }
                                             }];
    } else {
        // The user doesn't have the Facebook for iOS app installed.  You
        // may be able to use a fallback.
        NSLog(@"upload using request");
        
        FBRequest *request = [FBRequest requestForUploadPhoto:self.img];
        FBRequestConnection *connection = [[FBRequestConnection alloc]initWithTimeout:100];
        [connection addRequest:request completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSLog(@"success");
            }else{
                NSLog(@"Error: %@",error.description);
            }
        }];
        [connection start];
    }
}
@end
