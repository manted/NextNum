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

#define IPHONE_6_0 (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_6_0)

#ifdef IPHONE_6_0
# define ALIGN_CENTER NSTextAlignmentCenter
#else
# define ALIGN_CENTER UITextAlignmentCenter
#endif

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

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic) int decisecond;
@property (nonatomic) int second;

@property (nonatomic) BOOL isOver;

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
    
    // get world record from Parse
    PFQuery *query = [PFQuery queryWithClassName:@"WR"];
    [query getObjectInBackgroundWithId:@"f2V7qDto9G" block:^(PFObject *worldRecord, NSError *error) {
        int wr = [[worldRecord objectForKey:@"record"] intValue];
//        NSLog(@"%d", wr);
        self.wrObject = worldRecord;
        [self updateWorldRecord:wr];
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

-(NSArray*)array
{
    if (!_array) {
        _array = [[NSMutableArray alloc]init];
    }
    return _array;
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

-(void)setNumber
{
    int x = arc4random() % 16;
    while ([(NumberView*)[self.array objectAtIndex:x]isEmpty] == NO) {
        x = arc4random() % 16;
    }
    [(NumberView*)[self.array objectAtIndex:x] setNumber:self.currentNumber];
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

-(void)beginTouchingNumber:(NumberView*)view
{
    if (self.isOver == NO) {
        if ([view getNumber] == self.currentNumber) {
            //update persenal record immidiately
            if (self.currentNumber > [self.persenalRecord.persenalRecord intValue]) {
                self.persenalRecord.persenalRecord = [NSNumber numberWithInt:self.currentNumber];
                [self updatePersenalRecordLabel:self.currentNumber];
            }
            self.currentNumber++;
            [self setNumber];
            [self setTime];
        }else{
            [view showRedCross];
            [self gameOver];
        }
    }
}

-(void)endTouchingNumber:(NumberView*)view
{
//    NSLog(@"end touching number = %d, current number = %d", [view getNumber],self.currentNumber);
    if (self.isOver == NO) {
        if ([view getNumber] + 2 != self.currentNumber) {
            [view showRedCross];
            [self gameOver];
            
        }else{
            [view clearNumber];
        }
    }
}

-(void)gameOver
{
//    NSLog(@"game over");
    [self disableViews];
    
    self.isOver = YES;
    
    [self.timer invalidate];
    self.timer = nil;
    
    int score = self.currentNumber - 1;

    if (score > [self.persenalRecord.persenalRecord intValue]) {
        self.persenalRecord.persenalRecord = [NSNumber numberWithInt:score];
        [self updatePersenalRecordLabel:score];
    }
    
    if (score > self.worldRecord) {
//        self.wrObject[@"record"] = @score;
        [self.wrObject setValue:[NSNumber numberWithInt:score] forKey:@"record"];
        [self.wrObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"******%@",error.description);
            }
            if (succeeded) {
                NSLog(@"######");
                [self updateWorldRecord:score];
            }else{
                [self.wrObject refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    int latestWR = [[object objectForKey:@"record"] intValue];
                    self.wrObject = object;
                    [self updateWorldRecord:latestWR];
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

-(BOOL)isOver
{
    return _isOver;
}

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
        [view setNumber:0];
        [view hideRedCross];
    }
    [self setNumber];
    [self.timeLabel setText:@"Time Remaining"];
    self.isOver = NO;
}

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

//    [self.timer fire];
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
    float time = 5.0f * log2f(100.0f / self.currentNumber) / log2f(10.0f);
    float minTime = 1.0f;
    if (time < minTime) {
        time = minTime;
    }
    return time;
}

-(void)updateTimeLabelText
{
    [self.timeLabel setText:[NSString stringWithFormat:@"%d:%d",self.second,self.decisecond]];
}

-(int)getDecimalPartOfFloat:(float)num
{
    return (int)(num * 10.0f);
}

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

@end
