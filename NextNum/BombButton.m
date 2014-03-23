//
//  BombButton.m
//  NextNum
//
//  Created by Manted on 23/03/2014.
//  Copyright (c) 2014 Ye Hua. All rights reserved.
//

#import "BombButton.h"

@implementation BombButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setImage:[UIImage imageNamed:@"bomb"] forState:UIControlStateNormal];
    }
    return self;
}

-(void)use
{
    [self setAlpha:0.3f];
    [self setUserInteractionEnabled:NO];
}

-(void)refill
{
    [self setAlpha:1.0f];
    [self setUserInteractionEnabled:YES];
}

@end
