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

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic) int currentNumber;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIManagedDocument *managedDocument;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) Record *persenalRecord;
//@property (nonatomic) int persenalRecord;
@property (nonatomic) int worldRecord;

@property (nonatomic, strong) UILabel *persenalLabel;
@property (nonatomic, strong) UILabel *worldLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.persenalLabel];
    [self.view addSubview:self.worldLabel];
    [self.view addSubview:self.containerView];
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
    
    [self.persenalLabel setText:[NSString stringWithFormat:@"Best: 0"]];
    [self.worldLabel setText:[NSString stringWithFormat:@"WR: 0"]];
    
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
            [self.persenalLabel setText:[NSString stringWithFormat:@"Best: %d",[self.persenalRecord.persenalRecord intValue]]];
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

//-(void)setPersenalRecord:(Record*)persenalRecord
//{
//    self.persenalRecord = persenalRecord;
//    self.persenalLabel.text = [NSString stringWithFormat:@"Best: %d",[self.persenalRecord.persenalRecord intValue]];
//}

-(void)setWorldRecord:(int)worldRecord
{
    self.worldRecord = worldRecord;
//    self.worldLabel.text = [NSString stringWithFormat:@"WR: %d",self.worldRecord];
}

-(UILabel*)persenalLabel
{
    if (!_persenalLabel) {
        _persenalLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, 100, 20)];
    }
    return _persenalLabel;
}

-(UILabel*)worldLabel
{
    if (!_worldLabel) {
        _worldLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, 40, 100, 20)];
    }
    return _worldLabel;
}

-(UIView*)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 60, 320, 320)];
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

//-(int)numberOfTouching
//{
//    int count = 0;
//    for (NumberView *view in self.array) {
//        if (view.isTouching) {
//            count++;
//        }
//    }
//    return count;
//}

-(void)beginTouchingNumber:(NumberView*)view
{
    if ([view getNumber] == self.currentNumber) {
        self.currentNumber++;
        [self setNumber];
    }else{
        [self gameOver];
    }
}

-(void)endTouchingNumber:(NumberView*)view
{
//    NSLog(@"end touching number = %d, current number = %d", [view getNumber],self.currentNumber);
    
    if ([view getNumber] + 2 != self.currentNumber) {
        [self gameOver];
    }else{
        
    }
    [view clearNumber];
}

-(void)gameOver
{
    NSLog(@"game over");
    int score = self.currentNumber - 1;

    if (score > [self.persenalRecord.persenalRecord intValue]) {
        self.persenalRecord.persenalRecord = [NSNumber numberWithInt:score];
        [self.persenalLabel setText:[NSString stringWithFormat:@"Best: %d",[self.persenalRecord.persenalRecord intValue]]];
    }
    
    PopupVC *popup = [[PopupVC alloc] initWithNibName:@"PopupVC" bundle:nil];
    popup.vc = self;
    [popup setFinalScore:score];
    UIImage *img = [self imageWithView:self.containerView];
    popup.img = img;
    [self presentPopupViewController:popup animated:YES completion:nil];
}

-(void)tryAgain
{
    if (self.popupViewController != nil) {
        [self dismissPopupViewControllerAnimated:YES completion:nil];
    }
    [self reset];
}

-(void)reset
{
    self.currentNumber = INITIAL_NUMBER;
    for (NumberView *view in self.array) {
        [view setNumber:0];
    }
    [self setNumber];
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
