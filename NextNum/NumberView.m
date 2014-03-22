//
//  NumberView.m
//  NextNumber
//
//  Created by Manted on 16/03/2014.
//  Copyright (c) 2014 Ye Hua. All rights reserved.
//

#import "NumberView.h"

@interface NumberView()

@property (nonatomic) int number;
@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) UIImageView *imgV;
@property (nonatomic, strong) UIImage *imgDark;
@property (nonatomic, strong) UIImage *imgLight;
@property (nonatomic, strong) UIImageView *redCrossView;
@property (nonatomic, strong) UIImage *crossImg;

@property (nonatomic) BOOL isTouching;

//@property (nonatomic, strong) UITapGestureRecognizer *recognizer;

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *frontView;

@property (nonatomic, strong) UIImageView *backImgV;
@property (nonatomic, strong) UIImage *backImg;

@end

@implementation NumberView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.frontView];
        [self addSubview:self.backView];
        
        [self.imgV setImage:self.imgDark];

        self.isWrongNumber = NO;
        
        self.numLabel.transform = CGAffineTransformMakeRotation(0); // init transform
        
    }
    return self;
}

-(UILabel*)numLabel
{
    if (!_numLabel) {
        _numLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        [_numLabel setAdjustsFontSizeToFitWidth:YES];
        [_numLabel setBackgroundColor:[UIColor clearColor]];
        [_numLabel setTextColor:[self getColor]];
        [_numLabel setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:60]];
        [_numLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _numLabel;
}

-(void)changeSize
{
    int x = arc4random() % 5;
    switch (x) {
        case 0:
            [self.numLabel setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:60]];
            break;
        case 1:
            [self.numLabel setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:55]];
            break;
        case 2:
            [self.numLabel setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:40]];
            break;
        case 3:
            [self.numLabel setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:35]];
            break;
        case 4:
            [self.numLabel setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:30]];
            break;
        default:
            break;
    }
}

-(void)resetSize
{
    [self.numLabel setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:60]];
}

-(void)rotate
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.0];
    
    int x = arc4random() % 7;
    switch (x) {
        case 0:
            self.numLabel.transform = CGAffineTransformMakeRotation(M_PI_4); // 45
            break;
        case 1:
            self.numLabel.transform = CGAffineTransformMakeRotation(M_PI_2); // 90
            break;
        case 2:
            self.numLabel.transform = CGAffineTransformMakeRotation(M_PI_4+M_PI_2); // 135
            break;
        case 3:
            self.numLabel.transform = CGAffineTransformMakeRotation(M_PI); // 180
            break;
        case 4:
            self.numLabel.transform = CGAffineTransformMakeRotation(-M_PI_4); // -45
            break;
        case 5:
            self.numLabel.transform = CGAffineTransformMakeRotation(-M_PI_2); // -90
            break;
        case 6:
            self.numLabel.transform = CGAffineTransformMakeRotation(-(M_PI_4+M_PI_2)); // -135
            break;
        default:
            break;
    }
    
    [UIView commitAnimations];
}

-(void)rotateBack
{
    CGFloat angle = [(NSNumber *)[self.numLabel valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
//    NSLog(@"%f", angle);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.0];
    self.numLabel.transform = CGAffineTransformRotate(self.numLabel.transform, -angle);
    [UIView commitAnimations];
}

-(UIColor*)getColor
{
    int x = arc4random() % 5;
    UIColor *color = nil;
    switch (x) {
        case 0:
            color = [UIColor colorWithRed:151.0/255.0f green:112.0/255.0f blue:138.0/255.0f alpha:1];
            break;
        case 1:
            color = [UIColor colorWithRed:88.0/255.0f green:58.0/255.0f blue:82.0/255.0f alpha:1];
            break;
        case 2:
            color = [UIColor colorWithRed:171.0/255.0f green:99.0/255.0f blue:97.0/255.0f alpha:1];
            break;
        case 3:
            color = [UIColor colorWithRed:175.0/255.0f green:143.0/255.0f blue:143.0/255.0f alpha:1];
            break;
        case 4:
            color = [UIColor colorWithRed:226.0/255.0f green:171.0/255.0f blue:121.0/255.0f alpha:1];
            break;
        default:
            break;
    }
    return color;
}

-(UIView*)frontView
{
    if (!_frontView) {
        _frontView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        [_frontView addSubview:self.imgV];
        [_frontView addSubview:self.numLabel];
    }
    return _frontView;
}

-(UIView*)backView
{
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        [_backView addSubview:self.backImgV];
    }
    return _backView;
}

-(UIImageView*)backImgV
{
    if (!_backImgV) {
        _backImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        [_backImgV setImage:self.backImg];
    }
    return _backImgV;
}

-(UIImage*)backImg
{
    if (!_backImg) {
        _backImg = [UIImage imageNamed:@"numViewDark"];
    }
    return _backImg;
}

-(UIImageView*)redCrossView
{
    if (!_redCrossView) {
        _redCrossView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        [_redCrossView setImage:self.crossImg];
        [_redCrossView setAlpha:0.5f];
    }
    return _redCrossView;
}

-(UIImage*)crossImg
{
    if (!_crossImg) {
        _crossImg = [UIImage imageNamed:@"redcross"];
    }
    return _crossImg;
}

-(UIImageView*)imgV
{
    if (!_imgV) {
        _imgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    }
    return _imgV;
}

-(UIImage*)imgDark
{
    if (!_imgDark) {
        _imgDark = [UIImage imageNamed:@"numViewDark"];
    }
    return _imgDark;
}

-(UIImage*)imgLight
{
    if (!_imgLight) {
        _imgLight = [UIImage imageNamed:@"numViewLight"];
    }
    return _imgLight;
}

-(void)setNumber:(int)number
{
    int temp = _number;
    _number = number;
    if (number == EMPTY_NUMBER) {
        [self.numLabel setText:@""];
        [self.imgV setImage:self.imgDark];
    }else{
        [self.numLabel setText:[NSString stringWithFormat:@"%d",number]];
        [self.imgV setImage:self.imgLight];
        [self.numLabel setTextColor:[self getColor]];
    }
    if (temp != self.number) {
        [self flip];
    }

}

-(int)getNumber
{
    return self.number;
}

-(void)clearNumber
{
    [self rotateBack];
    [self resetSize];
    self.number = EMPTY_NUMBER;
}

-(BOOL)isTouching
{
    return _isTouching;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"began number = %d", self.number);
    self.isTouching = YES;
    [self.vc beginTouchingNumber:self];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"end number = %d", self.number);
    self.isTouching = NO;
    [self.vc endTouchingNumber:self];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches cancelled");
    [self.vc gameOver];
//    if ([self.vc isOver] == NO) {
//        NSLog(@"touches cancelled numbeb of touching: %d",[self.vc numberOfTouching]);
//        if ([self.vc numberOfTouching] >= 2) {
//            NSLog(@"touches cancelled 2");
//            [self.vc gameOver];
//        }
//    }
    self.isTouching = NO;
}

-(BOOL)isEmpty
{
    return self.number == EMPTY_NUMBER;
}

-(void)hideRedCross
{
    [self.redCrossView removeFromSuperview];
}

-(void)showRedCross
{
    [self addSubview:self.redCrossView];
}

- (void)flip
{
    if (self.number == EMPTY_NUMBER) {
        [self setUserInteractionEnabled:NO];
        [UIView transitionFromView:self.frontView toView:self.backView
                          duration:0.2
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        completion:^(BOOL success){
                            [self setUserInteractionEnabled:YES];
                        }];
    }
    else {
        [self setUserInteractionEnabled:NO];
        [UIView transitionFromView:self.backView toView:self.frontView
                          duration:0.2
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        completion:^(BOOL success){
                            [self setUserInteractionEnabled:YES];
                        }];
    }
}

@end
