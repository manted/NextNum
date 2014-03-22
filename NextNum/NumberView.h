//
//  NumberView.h
//  NextNumber
//
//  Created by Manted on 16/03/2014.
//  Copyright (c) 2014 Ye Hua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@class ViewController;

@interface NumberView : UIView

@property (nonatomic,strong) ViewController *vc;
@property (nonatomic) BOOL isWrongNumber;

-(void)setNumber:(int)number;
-(int)getNumber;
-(void)clearNumber;

-(BOOL)isTouching;
-(BOOL)isEmpty;

-(void)showRedCross;
-(void)hideRedCross;

-(void)showCorrect;
-(void)hideCorrect;

-(void)rotate;
-(void)rotateBack;

-(void)changeSize;
-(void)resetSize;
@end
