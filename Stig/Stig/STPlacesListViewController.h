//
//  STPlacesListViewController.h
//  Stig
//
//  Created by Lucas Tenório on 30/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPlace.h"
@interface STPlacesListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *places;
@end
