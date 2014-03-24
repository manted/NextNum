//
//  GuideVC.m
//  NextNum
//
//  Created by Manted on 23/03/2014.
//  Copyright (c) 2014 Ye Hua. All rights reserved.
//

#import "GuideVC.h"

@interface GuideVC ()

@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIButton *readyButton;

@end

@implementation GuideVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        self.imgV.image = self.img1;
        
//        [self setUp];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUp];
//    self.scrollView.contentSize = CGSizeMake(4 * 320, self.scrollView.frame.size.height);
//    [self.scrollView setContentOffset:CGPointMake(0, 0)];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.scrollView.contentSize = CGSizeMake(4 * 320, self.scrollView.frame.size.height);
}

-(UIScrollView*)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
//        _scrollView.contentSize = CGSizeMake(4 * 320, self.scrollView.frame.size.height);
        
        _scrollView.showsVerticalScrollIndicator = NO;
        
        _scrollView.showsHorizontalScrollIndicator = NO;
        
        _scrollView.delegate = self;
        
        _scrollView.scrollEnabled = YES;
        
        _scrollView.pagingEnabled = YES;
        
        _scrollView.bounces = NO;

    }
    return _scrollView;
}

-(UIButton*)readyButton
{
    if (!_readyButton) {
        _readyButton = [[UIButton alloc]initWithFrame:CGRectMake(80 + 3 * 320, 380, 160, 30)];
        [_readyButton setTitle:@"I'm ready" forState:UIControlStateNormal];
        [_readyButton setBackgroundColor:[UIColor clearColor]];
        [_readyButton.titleLabel setFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:30]];
        [_readyButton.titleLabel setTextColor:[UIColor colorWithRed:238.0/255.0f green:228.0/255.0f blue:217.0/255.0f alpha:1]];
        [_readyButton addTarget:self action:@selector(ready:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _readyButton;
}

-(UIPageControl*)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(130, 440, 60, 20)];
        _pageControl.numberOfPages = 4;
        _pageControl.currentPage = 0;
        [_pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    }
    return _pageControl;
}

-(void)setUp
{
    //add guide image
    UIImage *guideImg = [UIImage imageNamed:@"guide"];
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 4 * 320, self.scrollView.frame.size.height)];
    imgV.image = guideImg;
    [self.scrollView addSubview:imgV];
    //add ready button
    [self.scrollView addSubview:self.readyButton];
    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.pageControl];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    int page = self.scrollView.contentOffset.x / 320;
    
    self.pageControl.currentPage = page;
    
}

- (IBAction)changePage:(UIPageControl *)sender {
    int page = self.pageControl.currentPage;
    
    [self.scrollView setContentOffset:CGPointMake(320 * page, 0)];
}

- (void)ready:(id)sender {
    [self.vc dismissGuide];
}
@end
