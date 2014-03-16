//
//  ViewController.h
//  NextNumber
//
//  Created by Manted on 16/03/2014.
//  Copyright (c) 2014 Ye Hua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NumberView.h"
#import "UIViewController+CWPopup.h"

#define INITIAL_NUMBER 1
#define EMPTY_NUMBER 0

@class NumberView;

@interface ViewController : UIViewController

-(void)beginTouchingNumber:(NumberView*)view;
-(void)endTouchingNumber:(NumberView*)view;

-(void)tryAgain;

//+ (UIImage *) imageWithView:(UIView *)view;

@end
