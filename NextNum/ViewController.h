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
#import <CoreData/CoreData.h>

#define INITIAL_NUMBER 1
#define EMPTY_NUMBER 0

#define IPHONE_6_0 (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_6_0)

#ifdef IPHONE_6_0
# define ALIGN_CENTER NSTextAlignmentCenter
#else
# define ALIGN_CENTER UITextAlignmentCenter
#endif

@class NumberView;

@interface ViewController : UIViewController

-(void)beginTouchingNumber:(NumberView*)view;
-(void)endTouchingNumber:(NumberView*)view;

-(void)tryAgain;
-(int)numberOfTouching;
-(void)gameOver;
-(BOOL)isOver;

//+ (UIImage *) imageWithView:(UIView *)view;

@end
