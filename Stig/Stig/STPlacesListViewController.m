//
//  STPlacesListViewController.m
//  Stig
//
//  Created by Lucas Tenório on 30/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STPlacesListViewController.h"
#import "STBoardViewController.h"
@interface STPlacesListViewController ()

@end

@implementation STPlacesListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) setPlaces:(NSArray *)places {
    _places = places;
    [self.tableView reloadData];
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


#pragma mark - Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.places) {
        return [self.places count];
    }
    return 0;
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    STPlace *place = self.places[path.row];
    STBoardViewController *vc = segue.destinationViewController;
    vc.place = place;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
//    }
    STPlace *place = self.places[indexPath.row];
    [cell.contentView setBackgroundColor:[self colorForRanking:place.ranking]];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    [cell.textLabel setFont:[UIFont fontWithName:@"Futura" size:20.0]];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    [cell.textLabel setText:place.placeName];
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    //[cell.detailTextLabel setText:place.placeDescription];
    return cell;
}
- (UIColor *) colorForRanking:(STRanking *) ranking {
    float max = [((STPlace *) self.places[0]).ranking.overall floatValue];

    // UIColor *baseColor = [UIColor colorWithRed:26.0/255.0 green:188.0/255.0 blue:156.0/255.0 alpha:1.0];
    UIColor *baseColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
    CGFloat alpha = [ranking.overall floatValue]/max + 0.05;
    return [baseColor colorWithAlphaComponent:alpha];
}
- (void) sortPlaces {
    NSArray *sorted  = [self.places sortedArrayUsingComparator:^NSComparisonResult(id a, id b){
        if ([a isKindOfClass:[STPlace class]] && [b isKindOfClass:[STPlace class]]){

            STPlace *first = a;
            STPlace *second = b;
            float left = [first.ranking.overall floatValue];
            float right = [second.ranking.overall floatValue];
            if (left < right) {
                return NSOrderedDescending;
            }else if (left == right){
                return NSOrderedSame;
            } else {
                return NSOrderedAscending;
            }
        } else {

        }
        return NSOrderedSame;
    }];
    self.places = sorted;
}
#pragma mark - Table View Delegate Methods
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
