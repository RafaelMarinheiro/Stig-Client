//
//  BoardsViewController.m
//  PJPrototype
//
//  Created by Lucas Tenório on 16/06/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "BoardsViewController.h"
#import "MGBase.h"
#import "MGScrollView.h"
#import "MGTableBoxStyled.h"
#import "MGLineStyled.h"
@implementation BoardsViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
//	MGScrollView *scroller = [MGScrollView scrollerWithSize:self.view.bounds.size];
//    [self.view addSubview:scroller];
//
//    MGTableBoxStyled *ukBoard = MGTableBoxStyled.box;
//    [scroller.boxes addObject:ukBoard];
//    UIImage *ukImage = [UIImage imageNamed:@"uk-board.jpg"];
//    UIImageView *ukImageView = [[UIImageView alloc] initWithImage:ukImage];
//    ukImageView.size = (CGSize){80.0,80.0};
//
//    MGLineStyled *row = [MGLineStyled lineWithLeft:ukImageView right:@"**The UK Pub**|mush" size:(CGSize){270.0,100.0}];
//    row.backgroundColor = [UIColor greenColor];
//    [ukBoard.topLines addObject:row];
//
//    [scroller layoutWithSpeed:0.3 completion:nil];
//
//
//    row.onSwipe = ^{NSLog(@"lol");};
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
