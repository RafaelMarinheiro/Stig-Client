//
//  STDrawerViewController.m
//  Stig
//
//  Created by Lucas Tenório on 22/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STDrawerViewController.h"
#import "MMDrawerVisualState.h"
@interface STDrawerViewController ()

@end

@implementation STDrawerViewController

- (id) initWithCoder:(NSCoder *)aDecoder {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];

    UINavigationController *center = [storyboard instantiateViewControllerWithIdentifier:@"STCenterNavigationController"];

    UIViewController *left = [storyboard instantiateViewControllerWithIdentifier:@"STPlacesListViewController"];
    if (self = [super initWithCenterViewController:center leftDrawerViewController:left rightDrawerViewController:nil]) {
        [self setMaximumLeftDrawerWidth:270.0];
        [self setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
        [self setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];

        [self setDrawerVisualStateBlock:[MMDrawerVisualState slideAndScaleVisualStateBlock]];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
