//
//  GuideVC.h
//  NextNum
//
//  Created by Manted on 23/03/2014.
//  Copyright (c) 2014 Ye Hua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@class ViewController;

@interface GuideVC : UIViewController <UIPageViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) ViewController *vc;

@end
