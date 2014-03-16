//
//  ViewController.h
//  NextNumber
//
//  Created by Manted on 16/03/2014.
//  Copyright (c) 2014 Ye Hua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NumberView.h"

@class NumberView;

@interface ViewController : UIViewController

-(void)beginTouchingNumber:(NumberView*)view;
-(void)endTouchingNumber:(NumberView*)view;

@end
