//
//  ViewController.m
//  NextNumber
//
//  Created by Manted on 16/03/2014.
//  Copyright (c) 2014 Ye Hua. All rights reserved.
//

#import "ViewController.h"
#import "PopupVC.h"

#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic) int currentNumber;
@property (nonatomic, strong) UIView *containerView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.containerView];
    [self addNumberViews];
    self.currentNumber = INITIAL_NUMBER;
    [self setNumber];
}

-(NSArray*)array
{
    if (!_array) {
        _array = [[NSMutableArray alloc]init];
    }
    return _array;
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
    PopupVC *popup = [[PopupVC alloc] initWithNibName:@"PopupVC" bundle:nil];
    popup.vc = self;
    [popup setFinalScore:self.currentNumber - 1];
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
