//
//  STBoardViewController.m
//  PJPrototype
//
//  Created by Lucas Tenório on 18/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STBoardViewController.h"


@interface STBoardViewController ()
 
@end

@implementation STBoardViewController{
    NSMutableDictionary *_heightsDictionary;
    STOverlord *_overlord;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userNameFont = [UIFont fontWithName:@"Futura" size:15.0];
    self.commentFont =  [UIFont fontWithName:@"Helvetica" size:13.0];
    _heightsDictionary = [[NSMutableDictionary alloc] initWithCapacity:30];
    _loadedPlace = NO;
    _loadedComments = NO;
    _overlord = [STOverlord sharedInstance];
    
    [self requestData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) requestDataForIndexPath:(NSIndexPath *)indexPath {
    STBoardComment *comment = self.comments[indexPath];
    if (comment) {
        [_overlord resolveUserById:comment.userId completion:^(STUser *user) {
            [_commentsUsers setObject:user forKey:indexPath];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        }error:^(NSError *error){
            
        }];
    }
}
- (void) requestData{
    NSLog(@"request data %@", self.place);
        self.title = self.place.placeName;
        [_overlord getCommentsFromPlace:self.place withStickers:@[@3,@1,@2] pageNumber:0 completion:^(NSArray *comments, NSUInteger pageNumber){
            _comments = [[NSMutableDictionary alloc] initWithCapacity:[comments count]];
            _commentsUsers = [[NSMutableDictionary alloc] initWithCapacity:[comments count]];
            for (int i =0; i < [comments count]; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i+1 inSection:0];
                
                STBoardComment *comment = comments[i];
                [_comments setObject:comment forKey:indexPath];
                [self setHeightForComment:comment AtIndexPath:indexPath];
            }
            [self.tableView reloadData];
            _loadedComments = YES;
        }error:^(NSError *error){
            NSLog(@"erro 2 %@",error);
        }];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.comments) {
        return [self.comments count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row]==0) {
        static NSString *CellIdentifier = @"STBoardHeaderIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 100.0f)];
        [imageView setImageWithURL:[NSURL URLWithString:self.place.imageURL] placeholderImage:[UIImage imageNamed:@"uk-board.jpg"]];

        [cell.contentView addSubview:imageView];
        return cell;
    }
    static NSString *CellIdentifier = @"STBoardCommentIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    STBoardComment *comment = self.comments[indexPath];
    STUser *user = self.commentsUsers[indexPath];
    
    if (user&&comment) {
        STBoardCommentView *commentView =(STBoardCommentView *) [cell.contentView viewWithTag:100];
        commentView.commentFont = self.commentFont;
        commentView.userNameFont = self.userNameFont;
        [commentView populateCommentWithText:comment.commentText userName:user.userName userImageURL:user.userImageURL andTimestamp:comment.commentTimestamp];
    } else {
        [self requestDataForIndexPath:indexPath];
        
        NSLog(@"User: %@, COmment %@", user, comment);
    }
    return cell;
}
- (void) setHeightForComment:(STBoardComment *) comment AtIndexPath:(NSIndexPath *)indexPath{
    NSString *text = [NSString stringWithFormat:@"hehehe%@",comment.commentText];
    
    CGSize stringSize = [text sizeWithFont:self.commentFont constrainedToSize:CGSizeMake(230.0, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    stringSize.height = MAX(stringSize.height, 40.0);
    [_heightsDictionary setObject:@(stringSize.height+20.0) forKey:indexPath];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate
- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *height = [_heightsDictionary objectForKey:indexPath];

    NSLog(@"height %@ %@",height,_heightsDictionary);
    if (height) {
        return [height floatValue];
    }
    return 100.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
