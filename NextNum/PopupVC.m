//
//  PopupVC.m
//  NextNum
//
//  Created by Manted on 16/03/2014.
//  Copyright (c) 2014 Ye Hua. All rights reserved.
//

#import "PopupVC.h"
#import <FacebookSDK/FacebookSDK.h>
#import "WXApi.h"

@interface PopupVC ()
@property (strong, nonatomic) UILabel *scoreLabel;
@property (nonatomic) int score;
//@property (weak, nonatomic) IBOutlet UIImageView *imgV;
@property (weak, nonatomic) IBOutlet UIButton *wechatButton;

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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view addSubview:self.scoreLabel];
    [self.scoreLabel setText:[NSString stringWithFormat:@"%d",self.score]];
    if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_6_0) {
        [self.scoreLabel setTextAlignment:ALIGN_CENTER];
    }else{
        [self.scoreLabel setTextAlignment:ALIGN_CENTER];
    }
    
    [self.view setBackgroundColor:[UIColor colorWithRed:238.0/255.0f green:228.0/255.0f blue:217.0/255.0f alpha:1]];
}

//-(void)setImg:(UIImage *)img
//{
//    self.img = img;
//    self.imgV.image = self.img;
//}

-(UILabel*)scoreLabel
{
    if (!_scoreLabel) {
        _scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 120, 40)];
        [_scoreLabel setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:40]];
        [_scoreLabel setAdjustsFontSizeToFitWidth:YES];
        [_scoreLabel setBackgroundColor:[UIColor clearColor]];
        [_scoreLabel setTextColor:[UIColor colorWithRed:88.0/255.0f green:58.0/255.0f blue:82.0/255.0f alpha:1]];
    }
    return _scoreLabel;
}

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
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"You may need to install the latest version of Facebook" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)shareToWeChat:(id)sender {
    if ([WXApi isWXAppInstalled]) {
        if ([WXApi isWXAppSupportApi]) {
            [self sendImageContent];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"YYou may need to install the latest version of WeChat" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"You need to install WeChat first" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } 
}

- (void) sendImageContent
{
    WXMediaMessage *message = [WXMediaMessage message];
    
    WXImageObject *ext = [WXImageObject object];

    ext.imageData = UIImagePNGRepresentation(self.img);
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    
    [WXApi sendReq:req];
}

@end
