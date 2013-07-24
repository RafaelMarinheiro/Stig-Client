//
//  STPlacesViewController.h
//  PJPrototype
//
//  Created by Lucas Tenório on 22/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STOverlord.h"
#import "STMapOverlayView.h"
@interface STPlacesViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet STMapOverlayView *mapOverlayView;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UITableView*tableView;
@property (nonatomic, strong) NSArray *places;
@property (nonatomic,readonly) BOOL showingMap;
- (IBAction)switchViews:(UIBarButtonItem *)sender;

@end
