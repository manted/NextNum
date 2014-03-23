//
//  GuideVC.m
//  NextNum
//
//  Created by Manted on 23/03/2014.
//  Copyright (c) 2014 Ye Hua. All rights reserved.
//

#import "GuideVC.h"

@interface GuideVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imgV;

@property (nonatomic, strong) UIImage *img1;
@property (nonatomic, strong) UIImage *img2;
@property (nonatomic, strong) UIImage *img3;
@property (nonatomic, strong) UIImage *img4;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation GuideVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.imgV.image = self.img1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)changePage:(UIPageControl *)sender {
    switch (self.pageControl.currentPage) {
        case 0:
            self.imgV.image = self.img1;
            break;
        case 1:
            self.imgV.image = self.img2;
            break;
        case 2:
            self.imgV.image = self.img3;
            break;
        case 3:
            self.imgV.image = self.img4;
            break;
        default:
            break;
    }
}

-(UIImage*)img1
{
    if (!_img1) {
        _img1 = [UIImage imageNamed:@"bomb"];
    }
    return _img1;
}

-(UIImage*)img2
{
    if (!_img2) {
        _img2 = [UIImage imageNamed:@"correct"];
    }
    return _img2;
}

-(UIImage*)img3
{
    if (!_img3) {
        _img3 = [UIImage imageNamed:@"redcross"];
    }
    return _img3;
}

-(UIImage*)img4
{
    if (!_img4) {
        _img4 = [UIImage imageNamed:@"tryagain"];
    }
    return _img4;
}

- (IBAction)ready:(id)sender {
    [self.vc tryAgain];
}
@end
