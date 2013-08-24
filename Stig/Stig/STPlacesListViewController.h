//
//  STPlacesListViewController.h
//  Stig
//
//  Created by Lucas Tenório on 30/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPlace.h"
#import "STOverlord.h"
@interface STPlacesListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UISearchDisplayDelegate>
@property (nonatomic) STOverlordToken overlordToken;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplay;
@property (nonatomic, strong) NSArray *places;
@end
