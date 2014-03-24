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
#import <iAd/iAd.h>

#define INITIAL_NUMBER 1
#define EMPTY_NUMBER 0

@class NumberView;

@interface ViewController : UIViewController <ADBannerViewDelegate>

// guide
@property (nonatomic) BOOL isGuideShown;

-(void)beginTouchingNumber:(NumberView*)view;
-(void)endTouchingNumber:(NumberView*)view;

-(void)tryAgain;
-(int)numberOfTouching;
-(void)gameOver;
-(BOOL)isOver;

-(void)showGuide;
-(void)dismissGuide;

@end
