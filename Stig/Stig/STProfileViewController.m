//
//  STProfileViewController.m
//  Stig
//
//  Created by Lucas Tenório on 21/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STProfileViewController.h"
#import "STOverlord.h"
#import "STBoardViewController.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@interface STProfileViewController ()

@end

@implementation STProfileViewController {
    STOverlordToken _currentToken;
    NSUInteger _numberOfChekins;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.userImage.layer setCornerRadius:5.0];
    [self.userImage.layer setMasksToBounds:YES];


    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Futura" size:20.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Profile";
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    self.customNavigationItem.titleView = label;
    STUser *user = [STHiveCluster spawnOverlord].user;
    self.userLabel.text = user.userName;
    self.pointsLabel.text = [NSString stringWithFormat:@"%@ points", user.points];
    [self.pointsLabel sizeToFit];
    [self.userImage setImageWithURL:[NSURL URLWithString:user.userImageURL]];

    id <STOverlord> overlord = [STHiveCluster spawnOverlord];
    STOverlordToken token = [overlord requestTokenForCheckInHistoryOfUser:user];
    [overlord getNumberOfCheckinsForToken:token completion:^(NSUInteger numberOfCheckins) {
        _currentToken = token;
        _numberOfChekins = numberOfCheckins;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    // Do any additional setup after loading the view.
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    STBoardViewController *vc =  (STBoardViewController *)segue.destinationViewController;
    vc.place = sender;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_currentToken != 0) {
        return _numberOfChekins;
    }
    return 0;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckinCellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CheckinCellIdentifier"];
    }
    [[STHiveCluster spawnOverlord] getCheckInHistoryPlaceForToken:_currentToken andPosition:_numberOfChekins - indexPath.row - 1  completion:^(STPlace *place) {
        UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
        [currentCell.textLabel setText:place.placeName];
        [currentCell setNeedsLayout];
        [currentCell layoutIfNeeded];
        currentCell.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0];
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[STHiveCluster spawnOverlord] getCheckInHistoryPlaceForToken:_currentToken andPosition:_numberOfChekins - indexPath.row - 1  completion:^(STPlace *place) {
        [self performSegueWithIdentifier:@"HistoryToBoardSegue" sender:place];
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
