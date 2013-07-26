//
//  STPlacesViewController.h
//  PJPrototype
//
//  Created by Lucas Tenório on 22/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STOverlord.h"
@interface STPlacesViewController : UIViewController <MKMapViewDelegate>
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UITableView*tableView;
@property (nonatomic, strong) NSArray *places;
@property (nonatomic,readonly) BOOL showingMap;
- (IBAction)switchViews:(UIBarButtonItem *)sender;





@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dropperConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dropperLabel;
@property (nonatomic, readonly) BOOL showingDropper;
@end
