//
//  ViewController.m
//  NextNumber
//
//  Created by Manted on 16/03/2014.
//  Copyright (c) 2014 Ye Hua. All rights reserved.
//

#import "ViewController.h"
#import "PopupVC.h"
#import "Record+CoreData.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "LDProgressView.h"
#import "BombButton.h"
#import "GuideVC.h"

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE7 (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic) int currentNumber;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIManagedDocument *managedDocument;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) Record *persenalRecord;
//@property (nonatomic) int persenalRecord;
@property (nonatomic, strong) PFObject *wrObject;
@property (nonatomic) int worldRecord;

@property (nonatomic, strong) UILabel *persenalLabel;
@property (nonatomic, strong) UILabel *worldLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) LDProgressView *progressView;
@property (nonatomic) float timeLimit;
@property (nonatomic) float currentTime;

//@property (nonatomic) int decisecond;
//@property (nonatomic) int second;

@property (nonatomic) BOOL isOver;

// time 2
@property (nonatomic) NSTimer *timer2;
// iAd
@property (weak, nonatomic) IBOutlet ADBannerView *adView;
// tip
@property (nonatomic, strong) UILabel *tipLabel;
// bomb
@property (nonatomic, strong) BombButton *bomb1;
@property (nonatomic, strong) BombButton *bomb2;
@property (nonatomic, strong) BombButton *bomb3;
@property (nonatomic, strong) BombButton *bomb4;
@property (nonatomic, strong) BombButton *bomb5;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.persenalLabel];
    [self.containerView addSubview:self.worldLabel];
//    [self.view addSubview:self.timeLabel];
    [self.containerView addSubview:self.progressView];
    [self.containerView addSubview:self.indicator];
    [self.view addSubview:self.tipLabel];

    [self addNumberViews];
    self.currentNumber = INITIAL_NUMBER;
    [self setNumber];
    [self setTime2];
    
    self.adView.delegate = self;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.persenalLabel setText:[NSString stringWithFormat:@"Best: "]];
    [self.worldLabel setText:[NSString stringWithFormat:@"WR: ?"]];
    
//    [self.containerView addSubview:self.indicator];
//    [self.view addSubview:self.tipLabel];
    NSLog(@"addbombs");
    [self addBombs];

    self.isOver = YES;
    
    [self.adView setHidden:YES];
    
    if (self.isGuideShown == NO) {
        NSLog(@"hide bombs");
        [self hideBombs];
        [self hideTip];
        [self showGuide];
    }
    
    [self readPersenalRecord];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //read persenal and world record
//    [self readPersenalRecord];
    self.worldRecord = 0;
    [self readWorldRecord];
}

#pragma mark - Parse
-(void)readWorldRecord
{
    PFQuery *query = [PFQuery queryWithClassName:@"WR"];
    [self.indicator startAnimating];
    [query getObjectInBackgroundWithId:@"f2V7qDto9G" block:^(PFObject *worldRecord, NSError *error) {
        int wr = [[worldRecord objectForKey:@"record"] intValue];
        NSLog(@"wr: %d", wr);
        self.wrObject = worldRecord;
        [self updateWorldRecord:wr];
        [self.indicator stopAnimating];
        
        if (self.persenalRecord.persenalRecord != nil) {
            // current wr is less than best
            if ([self.persenalRecord.persenalRecord intValue] > wr) {
                NSLog(@"best > wr");
                [self.indicator startAnimating];
                [self saveWorldRecord:[self.persenalRecord.persenalRecord intValue]];
            }
        }
        
        if (error) {
//            NSLog(@"%@",error.description);
            [self.worldLabel setText:[NSString stringWithFormat:@"WR: ?"]];
            [self.indicator stopAnimating];
        }
    }];
}

-(void)saveWorldRecord:(int)score
{
    NSLog(@"save wr");
    [self.wrObject setValue:[NSNumber numberWithInt:score] forKey:@"record"];
    [self.wrObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"******\n%@",error.description);
        }
        if (succeeded) {
            NSLog(@"######");
            [self updateWorldRecord:score];
            [self.indicator stopAnimating];
        }else{
            //            [self.indicator startAnimating];
            //                [self.wrObject refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            //                    int latestWR = [[object objectForKey:@"record"] intValue];
            //                    NSLog(@"latestWR: %d",latestWR);
            //                    self.wrObject = object;
            //                    [self updateWorldRecord:latestWR];
            //                    [self.indicator stopAnimating];
            //                }];
            //                [self.wrObject refresh];
            [self readWorldRecord];
        }
    }];
    
}

#pragma mark - Core Data
-(void)readPersenalRecord
{
    if (!self.managedDocument) {  // for demo purposes, we'll create a default database if none is set
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Database"];
        // url is now "<Documents Directory>/Database"
        self.managedDocument = [[UIManagedDocument alloc] initWithFileURL:url]; // setter will create this for us on disk
    }else{
        [self useDocument];
    }
}

-(void)setManagedDocument:(UIManagedDocument *)managedDocument
{
    if (!_managedDocument) {
        _managedDocument = managedDocument;
        [self useDocument];
    }
}

- (void)useDocument
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.managedDocument.fileURL path]]) {
        [_managedDocument openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self documentIsReady];
            }else{
                NSLog(@"1 couldn't open document at %@",self.managedDocument.fileURL);
            }
        }];
    }else{
        [_managedDocument saveToURL:self.managedDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                [self documentIsReady];
            }else{
                NSLog(@"2 couldn't open document at %@",self.managedDocument.fileURL);
            }
        }];
    }
}

-(void)documentIsReady
{
    if (self.managedDocument.documentState == UIDocumentStateNormal) {
        NSLog(@"uidocumentstatenormal");
        self.managedObjectContext = self.managedDocument.managedObjectContext;

        self.persenalRecord = [Record getRecordInManagedObjectContext:self.managedObjectContext];
//        NSLog(@"%d",[self.persenalRecord.persenalRecord intValue]);
        if (self.persenalRecord) {
            NSLog(@"read record from db");
            [self updatePersenalRecordLabel:[self.persenalRecord.persenalRecord intValue]];
        }

    }else if (self.managedDocument.documentState == UIDocumentStateClosed) {
        NSLog(@"uidocumentstate closed");
        self.managedObjectContext = self.managedDocument.managedObjectContext;
    }else{
        NSLog(@"uidocumentstate other");
    }
}

#pragma mark - views array
-(NSArray*)array
{
    if (!_array) {
        _array = [[NSMutableArray alloc]init];
    }
    return _array;
}

-(void)setCurrentTime:(float)currentTime
{
    _currentTime = currentTime;
    [self updateProgressView];
}

-(void)setTimeLimit:(float)timeLimit
{
    _timeLimit = timeLimit;
    [self updateProgressView];
}

#pragma mark - UI elements
-(UIActivityIndicatorView*)indicator
{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(280, 5, 22, 22)];
        [_indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _indicator;
}

-(UILabel*)tipLabel
{
    if (!_tipLabel) {
        if (IS_WIDESCREEN) {
            _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 456, 300, 98)];
        }else{
            _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 418, 300, 58)];
        }
        if (IS_IPHONE7) {
            // here you go with iOS 7
            [_tipLabel setFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:20]];
        }else{
            [_tipLabel setFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:15]];
        }
        
        [_tipLabel setAdjustsFontSizeToFitWidth:YES];
        [_tipLabel setBackgroundColor:[UIColor clearColor]];
        [_tipLabel setTextColor:[UIColor colorWithRed:238.0/255.0f green:228.0/255.0f blue:217.0/255.0f alpha:1]];
        [_tipLabel setText:@"Press N+1 before releasing N. BTW, be quick!"];
        [_tipLabel setNumberOfLines:2];
        [_tipLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _tipLabel;
}

-(void)showTip
{
    [self.tipLabel setHidden:NO];
}

-(void)hideTip
{
    [self.tipLabel setHidden:YES];
}

-(UILabel*)persenalLabel
{
    if (!_persenalLabel) {
        _persenalLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 4, 160, 20)];
        [_persenalLabel setAdjustsFontSizeToFitWidth:YES];
        [_persenalLabel setBackgroundColor:[UIColor clearColor]];
        [_persenalLabel setTextColor:[UIColor colorWithRed:238.0/255.0f green:228.0/255.0f blue:217.0/255.0f alpha:1]];
        [_persenalLabel setFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:20]];
        [_persenalLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _persenalLabel;
}

-(UILabel*)worldLabel
{
    if (!_worldLabel) {
        _worldLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 4, 160, 20)];
        [_worldLabel setAdjustsFontSizeToFitWidth:YES];
        [_worldLabel setBackgroundColor:[UIColor clearColor]];
        [_worldLabel setTextColor:[UIColor colorWithRed:238.0/255.0f green:228.0/255.0f blue:217.0/255.0f alpha:1]];
        [_worldLabel setFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:20]];
        [_worldLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _worldLabel;
}

-(LDProgressView*)progressView
{
    if (!_progressView) {
        _progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(10, 28, self.view.frame.size.width-20, 22)];
        _progressView.color = [UIColor colorWithRed:238.0/255.0f green:228.0/255.0f blue:217.0/255.0f alpha:1];
        _progressView.flat = @YES;
        _progressView.showText = @NO;
        _progressView.progress = 0.0;
        _progressView.animate = @YES;
        _progressView.borderRadius = @12;
        _progressView.showStroke = @NO;
        _progressView.progressInset = @5;
        [_progressView setOuterStrokeWidth:@2];
        [_progressView setShowBackground:@NO];
        _progressView.type = LDProgressSolid;
    }
    return _progressView;
}

//-(UILabel*)timeLabel
//{
//    if (!_timeLabel) {
//        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 70, 160, 30)];
//        [_timeLabel setAdjustsFontSizeToFitWidth:YES];
//        [_timeLabel setBackgroundColor:[UIColor clearColor]];
//        [_timeLabel setTextColor:[UIColor redColor]];
//        [_timeLabel setFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:20]];
////        [_timeLabel setText:@"Time Remaining"];
//        [_tipLabel setTextAlignment:NSTextAlignmentCenter];
//    }
//    return _timeLabel;
//}

-(void)updateWorldRecord:(int)record
{
    self.worldRecord = record;
    [self.worldLabel setText:[NSString stringWithFormat:@"WR: %d",self.worldRecord]];
}

-(void)updatePersenalRecordLabel:(int)record
{
    [self.persenalLabel setText:[NSString stringWithFormat:@"Best: %d",record]];
}

-(void)updateProgressView
{
    self.progressView.progress = self.currentTime / self.timeLimit;
}

-(UIView*)containerView
{
    if (!_containerView) {
        if (IS_WIDESCREEN) {
            _containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 76, 320, 376)];
        }else{
            _containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, 320, 376)];
        }
        _containerView.backgroundColor = [UIColor colorWithRed:187.0f/255.0f green:173.0f/255.0f blue:158.0f/255.0f alpha:1];
    }
    return _containerView;
}

-(void)addNumberViews
{
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            NumberView *numView = [[NumberView alloc]initWithFrame:CGRectMake(i * 80, 54 + j * 80, 80, 80)];
            numView.vc = self;
            [self.containerView addSubview:numView];
            [self.array addObject:numView];
        }
    }
}

-(void)addBombs
{
    self.bomb1 = [[BombButton alloc]initWithFrame:CGRectMake(5, 0, 50, 50)];
    [self.bomb1 addTarget:self action:@selector(useBomb:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bomb1];
    
    self.bomb2 = [[BombButton alloc]initWithFrame:CGRectMake(5 + 1 * (50 + 15), 0, 50, 50)];
    [self.bomb2 addTarget:self action:@selector(useBomb:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bomb2];
    
    self.bomb3 = [[BombButton alloc]initWithFrame:CGRectMake(5 + 2 * (50 + 15), 0, 50, 50)];
    [self.bomb3 addTarget:self action:@selector(useBomb:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bomb3];
    
    self.bomb4 = [[BombButton alloc]initWithFrame:CGRectMake(5 + 3 * (50 + 15), 0, 50, 50)];
    [self.bomb4 addTarget:self action:@selector(useBomb:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bomb4];
    
    self.bomb5 = [[BombButton alloc]initWithFrame:CGRectMake(5 + 4 * (50 + 15), 0, 50, 50)];
    [self.bomb5 addTarget:self action:@selector(useBomb:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bomb5];
}

-(void)useBomb:(BombButton*)sender
{
    [self clearWrongNumbers];
    [sender use];
}

-(void)showBombs
{
    [self.bomb1 setHidden:NO];
    [self.bomb2 setHidden:NO];
    [self.bomb3 setHidden:NO];
    [self.bomb4 setHidden:NO];
    [self.bomb5 setHidden:NO];
}

-(void)hideBombs
{
    [self.bomb1 setHidden:YES];
    [self.bomb2 setHidden:YES];
    [self.bomb3 setHidden:YES];
    [self.bomb4 setHidden:YES];
    [self.bomb5 setHidden:YES];
}

#pragma mark - handle touch events
-(void)beginTouchingNumber:(NumberView*)view
{
    NSLog(@"num of touching1: %d",[self numberOfTouching]);
    // time 2
    if (self.isOver == YES && self.currentNumber == 1){
        [self begin];
    }
    NSLog(@"num of touching2: %d",[self numberOfTouching]);
    if (self.isOver == NO) {
        if([self numberOfTouching] > 2){ // use more than 2 fingers
            [view showRedCross];
            [self showCorrectView];
            NSLog(@"over 1");
            [self gameOver];
        }else{
            if ([view getNumber] == self.currentNumber) {
                [self addTime];
                
                [self clearWrongNumbers];
                //update persenal record immidiately
                if (self.currentNumber > [self.persenalRecord.persenalRecord intValue]) {
                    self.persenalRecord.persenalRecord = [NSNumber numberWithInt:self.currentNumber];
                    [self updatePersenalRecordLabel:self.currentNumber];
                }
                self.currentNumber++;
                [self setNumber];
//                [self setTime];
            }else{ // press wrong number
                [view showRedCross];
                [self showCorrectView];
                NSLog(@"over 2");
                [self gameOver];
            }
        }
    }
}

-(void)endTouchingNumber:(NumberView*)view
{
//    NSLog(@"end touching number = %d, current number = %d", [view getNumber],self.currentNumber);
    if (self.isOver == NO) {
        if ([view getNumber] + 2 != self.currentNumber) { // release wrong number
            [view showRedCross];
            [self showCorrectView];
            NSLog(@"over 3");
            [self gameOver];
        }else{
            [view clearNumber];
        }
    }
}

#pragma mark - game over
-(void)gameOver
{
//    NSLog(@"game over");
    
    [self disableViews];
    // 1 and 2 bug will show without this line!!!!!!!!!!!!!!!!
    [self cancelAllTouching];
    
    self.isOver = YES;
    
    [self.timer2 invalidate];
    self.timer2 = nil;
    
    int score = self.currentNumber - 1;

    if (score > [self.persenalRecord.persenalRecord intValue]) {
        self.persenalRecord.persenalRecord = [NSNumber numberWithInt:score];
        [self updatePersenalRecordLabel:score];
    }
    
    if (score > self.worldRecord) {
        [self saveWorldRecord:score];
//        [self.wrObject setValue:[NSNumber numberWithInt:score] forKey:@"record"];
//        [self.wrObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (error) {
//                NSLog(@"******\n%@",error.description);
//            }
//            if (succeeded) {
//                NSLog(@"######");
//                [self updateWorldRecord:score];
//            }else{
//                [self.indicator startAnimating];
////                [self.wrObject refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
////                    int latestWR = [[object objectForKey:@"record"] intValue];
////                    NSLog(@"latestWR: %d",latestWR);
////                    self.wrObject = object;
////                    [self updateWorldRecord:latestWR];
////                    [self.indicator stopAnimating];
////                }];
////                [self.wrObject refresh];
//                [self readWorldRecord];
//            }
//        }];
    }
    
    PopupVC *popup = [[PopupVC alloc] initWithNibName:@"PopupVC" bundle:nil];
    popup.vc = self;
    [popup setFinalScore:score];
    UIImage *img = [self imageWithView:self.containerView];
    popup.img = img;
    [self presentPopupViewController:popup animated:YES completion:nil];
    
    [self stopSpin];
}

-(void)showCorrectView
{
    for (NumberView *view in self.array) {
        if ([view getNumber] == self.currentNumber) {
            [view showCorrect];
        }
    }
}

-(void)stopSpin
{
    for (NumberView *view in self.array) {
        [view endSpin];
    }
}

#pragma mark - helper methods
-(void)disableViews
{
    for (NumberView *view in self.array) {
        [view setUserInteractionEnabled:NO];
    }
}

-(void)enableViews
{
    for (NumberView *view in self.array) {
        [view setUserInteractionEnabled:YES];
    }
}

-(int)numberOfTouching
{
    int count = 0;
    for (NumberView *view in self.array) {
        if ([view isTouching]) {
            count++;
        }
    }
    return count;
}

-(void)cancelAllTouching
{
    for (NumberView *view in self.array) {
        if ([view isTouching]) {
            [view cancelTouching];
        }
    }
}

-(BOOL)isOver
{
    return _isOver;
}

#pragma mark - try again
-(void)tryAgain
{
    if (self.popupViewController != nil) {
        [self dismissPopupViewControllerAnimated:YES completion:^(){
            [self enableViews];
        }];
    }
    [self reset];
    
    if ([self.adView isBannerLoaded] == YES) {
        [self.adView setHidden:NO];
        [self hideBombs];
    }
}

-(void)reset
{
    self.currentNumber = INITIAL_NUMBER;
    for (NumberView *view in self.array) {
        [view clearNumber];
        [view hideRedCross];
        [view hideCorrect];
    }
    [self setNumber];
    [self setTime2];
//    self.isOver = NO;
    
    //refill bombs
    [self.bomb1 refill];
    [self.bomb2 refill];
    [self.bomb3 refill];
    [self.bomb4 refill];
    [self.bomb5 refill];
}

-(void)setNumber
{
    int current10 = (int)(self.currentNumber / 10.0f);
    if (current10 > 13) {
        current10 = 13;
    }
    [self setNumberToViewsOf:current10 + 1];
//    if (self.currentNumber > 3) {
//        [self setNumberToViewsOf:14];
//    }else{
//        [self setNumberToViewsOf:1];
//    }
}

-(void)setNumberToViewsOf:(int)num
{
    
    while (num > 0) {
        int x = arc4random() % 16;
        NumberView *numV = (NumberView*)[self.array objectAtIndex:x];
        while ([numV isEmpty] == NO) {
            x = arc4random() % 16;
            numV = (NumberView*)[self.array objectAtIndex:x];
        }
        if (num == 1) { //correct number
            
            [numV setNumber:self.currentNumber];
            
        }else{ //wrong number
            int wrongNum = arc4random() % 21 - 10;
            while (wrongNum == 0) {
                wrongNum = arc4random() % 21 - 10;
            }
            
            [numV setNumber:self.currentNumber + wrongNum];
            [numV setIsWrongNumber:YES];
        }
        
        if (self.currentNumber > 35) { // change size
            [numV changeSize];
        }
        
        if (self.currentNumber > 60) { // begin rotate
            [numV rotate];
        }
        
//        if (self.currentNumber > 5) { // change alpha
//            [numV changeAlpha];
//        }
        
        if (self.currentNumber > 150) { // begin spinning
            [numV beginSpin];
        }
        
        num = num - 1;
    }
}

-(void)clearWrongNumbers
{
    for (NumberView *view in self.array) {
        if (view.isWrongNumber) {
            [view clearNumber];
//            [view setIsWrongNumber:NO];
        }
    }
}
#pragma mark - time 2
-(void)begin
{
    self.isOver = NO;
//    [self setTime2];
    self.timer2 = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(tick)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer2 forMode:NSRunLoopCommonModes];
}

-(void)setTime2
{
    self.timeLimit = 10.0f;
    self.currentTime = 10.0f;
//    [self updateProgressView];
}

-(void)addTime
{
    if (self.currentNumber < 35) {
        self.currentTime = self.currentTime + 1.2f;
    }else if (self.currentNumber < 60) {
        self.currentTime = self.currentTime + 1.6f;
    }else if (self.currentNumber < 100) {
        self.currentTime = self.currentTime + 2.0f;
    }else if (self.currentNumber < 130) {
        self.currentTime = self.currentTime + 2.4f;
    }else if (self.currentNumber < 160) {
        self.currentTime = self.currentTime + 2.8f;
    }else{
        self.currentTime = self.currentTime + 3.2f;
    }
    
    if (self.currentTime > self.timeLimit) {
        self.timeLimit = self.currentTime;
    }
}

#pragma mark - time

-(void)tick
{
//    NSLog(@"start timing");
    if (self.currentTime < 0.0) {
        [self showCorrectView];
        NSLog(@"over 4");
        [self gameOver];
    }else{
        self.currentTime = self.currentTime - 0.1f;
    }
//    [self updateProgressView];
}

-(float)getTimeLimit
{
    float time = 4.0f * log2f(300.0f / self.currentNumber) / log2f(10.0f);
    float minTime = 1.0f;
    if (time < minTime) {
        time = minTime;
    }
    return time;
}

-(int)getDecimalPartOfFloat:(float)num
{
    return (int)(num * 10.0f);
}

#pragma mark - create image from uiview
- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

#pragma mark - iAd
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    if (self.isOver == YES) {
        return YES;
    }else{
        return NO;
    }
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
//    NSLog(@"ad did loadad");
    if (self.isOver == YES) {
        [self.adView setHidden:NO];
        [self hideBombs];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
//    NSLog(@"ad did fail to receive ad with error: %@",error.description);
    [self.adView setHidden:YES];
    if (self.popupViewController == nil) {
            [self showBombs];
    }
}

-(void)bannerViewActionDidFinish:(ADBannerView *)banner
{
//    NSLog(@"ad action did finish");
    [self.adView setHidden:YES];
    if (self.popupViewController == nil) {
        [self showBombs];
    }
//    [self readPersenalRecord];
}

#pragma mark - guide
-(void)showGuide
{
    self.isGuideShown = YES;
    
    GuideVC *guide = [[GuideVC alloc] initWithNibName:@"GuideVC" bundle:nil];
    guide.vc = self;
    [self presentPopupViewController:guide animated:YES completion:nil];
}

-(void)dismissGuide
{
    if (self.popupViewController != nil) {
        [self dismissPopupViewControllerAnimated:YES completion:^(){
            [self enableViews];
        }];
    }
    [self showTip];
    if (self.adView.isHidden == YES) {
        [self showBombs];
    }
}

@end
