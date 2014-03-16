//
//  ViewController.m
//  NextNumber
//
//  Created by Manted on 16/03/2014.
//  Copyright (c) 2014 Ye Hua. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic) int currentNumber;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self addNumberViews];
    self.currentNumber = 1;
    [self setNumber];
}

-(NSArray*)array
{
    if (!_array) {
        _array = [[NSMutableArray alloc]init];
    }
    return _array;
}

-(void)addNumberViews
{
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            NumberView *numView = [[NumberView alloc]initWithFrame:CGRectMake(i * 80, 60 + j * 80, 80, 80)];
//            [numView setNumber:i * 4 + j];
            numView.vc = self;
            [self.view addSubview:numView];
            [self.array addObject:numView];
        }
    }
}

-(void)setNumber
{
//    if (self.currentNumber == 1) {
//        int x = arc4random() % 16;
//        [(NumberView*)[self.array objectAtIndex:x]setNumber:1];
//    }else{
        //get an empty number view
        int x = arc4random() % 16;
        while ([(NumberView*)[self.array objectAtIndex:x]isEmpty] == NO) {
            x = arc4random() % 16;
        }
        [(NumberView*)[self.array objectAtIndex:x] setNumber:self.currentNumber];
//    }
}

-(int)countEmptyView
{
    int count = 0;
    for (NumberView *view in self.array) {
        if ([view getNumber] == 0) {
            
        }
       
    }
    return count;
}

-(int)numberOfTouching
{
    int count = 0;
    for (NumberView *view in self.array) {
        if (view.isTouching) {
            count++;
        }
    }
    return count;
}

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
    NSLog(@"end touching number = %d, current number = %d", [view getNumber],self.currentNumber);
    
    if ([view getNumber] + 2 != self.currentNumber) {
        [self gameOver];
    }else{
        
    }
    [view clearNumber];
}

-(void)gameOver
{
    NSLog(@"game over");
}

@end
