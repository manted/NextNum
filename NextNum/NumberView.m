//
//  NumberView.m
//  NextNumber
//
//  Created by Manted on 16/03/2014.
//  Copyright (c) 2014 Ye Hua. All rights reserved.
//

#import "NumberView.h"

#define IPHONE_6_0 (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_6_0)

#ifdef IPHONE_6_0
# define ALIGN_CENTER NSTextAlignmentCenter
#else
# define ALIGN_CENTER UITextAlignmentCenter
#endif

@interface NumberView()

@property (nonatomic) int number;
@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) UIImageView *imgV;
@property (nonatomic, strong) UIImage *imgDark;
@property (nonatomic, strong) UIImage *imgLight;


@property (nonatomic) BOOL isTouching;

@end

@implementation NumberView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_6_0) {
            [self.numLabel setTextAlignment:ALIGN_CENTER];
        }else{
            [self.numLabel setTextAlignment:ALIGN_CENTER];
        }
        [self.numLabel setTextAlignment:NSTextAlignmentCenter];
        
        [self.imgV setImage:self.imgDark];
        [self addSubview:self.imgV];
        [self addSubview:self.numLabel];
        self.isTouching = NO;
    }
    return self;
}

-(UILabel*)numLabel
{
    if (!_numLabel) {
        _numLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        [_numLabel setAdjustsFontSizeToFitWidth:YES];
        [_numLabel setBackgroundColor:[UIColor clearColor]];
        [_numLabel setTextColor:[UIColor redColor]];
        [_numLabel setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:60]];

    }
    return _numLabel;
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
    _number = number;
    if (number == EMPTY_NUMBER) {
        [self.numLabel setText:@""];
        [self.imgV setImage:self.imgDark];
    }else{
        [self.numLabel setText:[NSString stringWithFormat:@"%d",number]];
        [self.imgV setImage:self.imgLight];
    }

}

-(int)getNumber
{
    return self.number;
}

-(void)clearNumber
{
    self.number = EMPTY_NUMBER;
    [self.imgV setImage:self.imgDark];
}

-(BOOL)isTouching
{
    return self.isTouching;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"began number = %d", self.number);
    self.isTouching = YES;
    [self.vc beginTouchingNumber:self];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"end number = %d", self.number);
    self.isTouching = NO;
    [self.vc endTouchingNumber:self];
}

-(BOOL)isEmpty
{
    return self.number == EMPTY_NUMBER;
}

@end
