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

@property (nonatomic) int decisecond;
@property (nonatomic) int second;

@property (nonatomic) BOOL isOver;

//time 2
@property (nonatomic) NSTimer *timer2;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.persenalLabel];
    [self.view addSubview:self.worldLabel];
    [self.view addSubview:self.containerView];
    [self.view addSubview:self.timeLabel];
    [self addNumberViews];
    self.currentNumber = INITIAL_NUMBER;
    [self setNumber];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.managedDocument) {  // for demo purposes, we'll create a default database if none is set
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Database"];
        // url is now "<Documents Directory>/Database"
        self.managedDocument = [[UIManagedDocument alloc] initWithFileURL:url]; // setter will create this for us on disk
    }
    
    [self.persenalLabel setText:[NSString stringWithFormat:@"Best: "]];
    [self.worldLabel setText:[NSString stringWithFormat:@"WR: ?"]];
    
    [self.view addSubview:self.indicator];
    
    // get world record from Parse
    PFQuery *query = [PFQuery queryWithClassName:@"WR"];
    [self.indicator startAnimating];
    [query getObjectInBackgroundWithId:@"f2V7qDto9G" block:^(PFObject *worldRecord, NSError *error) {
        int wr = [[worldRecord objectForKey:@"record"] intValue];
//        NSLog(@"%d", wr);
        self.wrObject = worldRecord;
        [self updateWorldRecord:wr];
        [self.indicator stopAnimating];
    }];
    
    if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_6_0) {
        [self.persenalLabel setTextAlignment:ALIGN_CENTER];
        [self.worldLabel setTextAlignment:ALIGN_CENTER];
        [self.timeLabel setTextAlignment:ALIGN_CENTER];
    }else{
        [self.persenalLabel setTextAlignment:ALIGN_CENTER];
        [self.worldLabel setTextAlignment:ALIGN_CENTER];
        [self.timeLabel setTextAlignment:ALIGN_CENTER];
    }
    
    self.isOver = NO;
}

#pragma mark - Core Data
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

#pragma mark - UI elements
-(UIActivityIndicatorView*)indicator
{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(280, 51, 22, 22)];
        [_indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _indicator;
}

-(UILabel*)persenalLabel
{
    if (!_persenalLabel) {
        _persenalLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, 160, 20)];
        [_persenalLabel setAdjustsFontSizeToFitWidth:YES];
        [_persenalLabel setBackgroundColor:[UIColor clearColor]];
        [_persenalLabel setTextColor:[UIColor whiteColor]];
        [_persenalLabel setFont:[UIFont fontWithName:@"Chalkduster" size:20]];
    }
    return _persenalLabel;
}

-(UILabel*)worldLabel
{
    if (!_worldLabel) {
        _worldLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 50, 160, 20)];
        [_worldLabel setAdjustsFontSizeToFitWidth:YES];
        [_worldLabel setBackgroundColor:[UIColor clearColor]];
        [_worldLabel setTextColor:[UIColor whiteColor]];
        [_worldLabel setFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:20]];
    }
    return _worldLabel;
}

-(UILabel*)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 70, 160, 30)];
        [_timeLabel setAdjustsFontSizeToFitWidth:YES];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [_timeLabel setTextColor:[UIColor redColor]];
        [_timeLabel setFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:20]];
        [_timeLabel setText:@"Time Remaining"];
    }
    return _timeLabel;
}

-(void)updateTimeLabelText
{
    [self.timeLabel setText:[NSString stringWithFormat:@"%d:%d",self.second,self.decisecond]];
}

-(void)updateWorldRecord:(int)record
{
    self.worldRecord = record;
    [self.worldLabel setText:[NSString stringWithFormat:@"WR: %d",self.worldRecord]];
}

-(void)updatePersenalRecordLabel:(int)record
{
    [self.persenalLabel setText:[NSString stringWithFormat:@"Best: %d",record]];
}

-(UIView*)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 100, 320, 320)];
        _containerView.backgroundColor = [UIColor colorWithRed:187.0f/255.0f green:173.0f/255.0f blue:158.0f/255.0f alpha:1];
    }
    return _containerView;
}

-(void)addNumberViews
{
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            NumberView *numView = [[NumberView alloc]initWithFrame:CGRectMake(i * 80, j * 80, 80, 80)];
//            [numView setNumber:i * 4 + j];
            numView.vc = self;
            [self.containerView addSubview:numView];
            [self.array addObject:numView];
        }
    }
}

#pragma mark - handle touch events
-(void)beginTouchingNumber:(NumberView*)view
{
    // time 2
    if (self.isOver == YES && self.currentNumber == 1){
        [self begin];
    }
    
    if (self.isOver == NO) {
        if([self numberOfTouching] > 2){ // use more than 2 fingers
            [view showRedCross];
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
    
    self.isOver = YES;
    
    [self.timer2 invalidate];
    self.timer2 = nil;
    
    int score = self.currentNumber - 1;

    if (score > [self.persenalRecord.persenalRecord intValue]) {
        self.persenalRecord.persenalRecord = [NSNumber numberWithInt:score];
        [self updatePersenalRecordLabel:score];
    }
    
    if (score > self.worldRecord) {
        [self.wrObject setValue:[NSNumber numberWithInt:score] forKey:@"record"];
        [self.wrObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"******%@",error.description);
            }
            if (succeeded) {
                NSLog(@"######");
                [self updateWorldRecord:score];
            }else{
                [self.indicator startAnimating];
                [self.wrObject refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    int latestWR = [[object objectForKey:@"record"] intValue];
                    self.wrObject = object;
                    [self updateWorldRecord:latestWR];
                    [self.indicator stopAnimating];
                }];
            }
        }];
    }
    
    PopupVC *popup = [[PopupVC alloc] initWithNibName:@"PopupVC" bundle:nil];
    popup.vc = self;
    [popup setFinalScore:score];
    UIImage *img = [self imageWithView:self.containerView];
    popup.img = img;
    [self presentPopupViewController:popup animated:YES completion:nil];
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
}

-(void)reset
{
    self.currentNumber = INITIAL_NUMBER;
    for (NumberView *view in self.array) {
//        [view rotateBack];
        [view clearNumber];
        [view hideRedCross];
        
    }
    [self setNumber];
    [self.timeLabel setText:@"Time Remaining"];
//    self.isOver = NO;
}

-(void)setNumber
{
    int current10 = (int)self.currentNumber / 10.0f;
    if (current10 > 15) {
        current10 = 15;
    }
    [self setNumberToViewsOf:current10 + 1];
}

-(void)setNumberToViewsOf:(int)num
{
    while (num > 0) {
        int x = arc4random() % 16;
        while ([(NumberView*)[self.array objectAtIndex:x]isEmpty] == NO) {
            x = arc4random() % 16;
        }
        if (num == 1) {
            if (self.currentNumber > 50) {
                [(NumberView*)[self.array objectAtIndex:x] rotate];
                [(NumberView*)[self.array objectAtIndex:x] setNumber:self.currentNumber];
            }else{
                [(NumberView*)[self.array objectAtIndex:x] setNumber:self.currentNumber];
            }
            
        }else{
            int wrongNum = arc4random() % 21 - 10;
            while (wrongNum == 0) {
                wrongNum = arc4random() % 21 - 10;
            }
            if (self.currentNumber > 50) {
                [(NumberView*)[self.array objectAtIndex:x] rotate];
                [(NumberView*)[self.array objectAtIndex:x] setNumber:self.currentNumber + wrongNum];
                [(NumberView*)[self.array objectAtIndex:x] setIsWrongNumber:YES];

            }else{
                [(NumberView*)[self.array objectAtIndex:x] setNumber:self.currentNumber + wrongNum];
                [(NumberView*)[self.array objectAtIndex:x] setIsWrongNumber:YES];

            }
        }
        
        num = num - 1;
    }
}

-(void)clearWrongNumbers
{
    for (NumberView *view in self.array) {
        if (view.isWrongNumber) {
            [view clearNumber];
            [view setIsWrongNumber:NO];
        }
    }
}
#pragma mark - time 2
-(void)begin
{
    self.isOver = NO;
    [self setTime2];
    self.timer2 = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(tick)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer2 forMode:NSRunLoopCommonModes];
}

-(void)setTime2
{
    self.second = 10;
    self.decisecond = 0;
}

-(void)addTime
{
    if (self.currentNumber < 40) {
        self.second = self.second + 1;
        self.decisecond = self.decisecond + 5;
    }else if (self.currentNumber < 80) {
        self.second = self.second + 1;
        self.decisecond = self.decisecond + 2;
    }else{
//        self.second = self.second + 1;
        self.decisecond = self.decisecond + 9;
    }
}

#pragma mark - time
-(void)setTime
{
    float timeLimit = [self getTimeLimit];
    self.second = (int)timeLimit;
    self.decisecond = [self getDecimalPartOfFloat:timeLimit - self.second];
//    NSLog(@"%f, %d, %d",timeLimit,self.second,self.decisecond);

    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                              target:self
                                            selector:@selector(tick)
                                            userInfo:nil
                                             repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

-(void)tick
{
//    NSLog(@"start timing");
    if (self.decisecond == 0) {
        if (self.second > 0) {
            self.decisecond = 9;
            self.second = self.second - 1;
        }else{
            [self gameOver];
        }
    }else{
        self.decisecond = self.decisecond - 1;
    }
    [self updateTimeLabelText];
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

@end
