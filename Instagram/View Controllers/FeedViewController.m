//
//  FeedViewController.m
//  Instagram
//
//  Created by Xurxo Riesco on 7/5/20.
//  Copyright © 2020 Xurxo Riesco. All rights reserved.
//

#import "FeedViewController.h"
#import <Parse/Parse.h>
#import "PostCell.h"
#import "Post.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "HeaderView.h"
#import "CommentsViewController.h"
#import "UserViewController.h"
@interface FeedViewController () < UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, PostCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, strong) Post *post;
@property (nonatomic, strong) User *user;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor],
       NSFontAttributeName:[UIFont fontWithName:@"Billabong" size:32]}];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self fecthPost];
    [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(onTimer) userInfo:nil repeats:NO];
    [self.tableView registerNib:[UINib nibWithNibName:@"HeaderView" bundle:nil]  forHeaderFooterViewReuseIdentifier:@"HeaderView"];
    //[self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:HeaderViewIdentifier];
    // Do any additional setup after loading the view.
}
- (void)onTimer {
    [self.tableView reloadData];
}
- (void)fecthPost {
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    postQuery.limit = 20;
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            NSLog(@"%@", posts);
            self.posts = [posts mutableCopy];
            self.dataSkip = 20;
            [self.tableView reloadData];
        }
        else {
            // handle error
        }
    }];
}
- (void)fecthMorePost {
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    [postQuery setSkip:self.dataSkip];
    postQuery.limit = 20;
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            if (posts.count > 0) {
                int prevNumPosts = self.posts.count;
                self.posts = [self.posts arrayByAddingObjectsFromArray:posts];
                NSMutableArray *newIndexPaths = [NSMutableArray array];
                for (int i = prevNumPosts; i < self.posts.count; i++) {
                    [newIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                self.dataSkip += 20;
            }
            self.isMoreDataLoading = false;
            [self.tableView reloadData];
        }
        else {
            // handle error
        }
    }];
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    Post *post = self.posts[indexPath.section];
    PostCell *postCell = [ tableView dequeueReusableCellWithIdentifier:@"PostCell" ];
    //NSLog(@"%@", post);
    postCell.delegate = self;
    [postCell loadPost:post];
    return postCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.posts.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"HeaderView"];
    Post *post = self.posts[section] ;
    NSLog(@"%@", self.posts[section]);
    User *user = post[@"author"];
    NSLog (@"%@", user.username);
    header.titleLabel.text = user.username;
    header.profileView.file = user[@"profilePic"];
    [header.profileView loadInBackground];
    header.profileView.layer.cornerRadius = 15;
    header.profileView.layer.masksToBounds = YES;
    
    return header;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self fecthPost];
    [refreshControl endRefreshing];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!self.isMoreDataLoading){
        // Calculate the position of one screen length before the bottom of the results
        int scrollViewContentHeight = self.tableView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.tableView.bounds.size.height;
        
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging) {
            self.isMoreDataLoading = true;
            NSLog(@"More data");
            NSLog(@"%d",self.dataSkip);
            [self fecthMorePost];
            
        }
    }
}
- (IBAction)onLogOut:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
    }];
}

- (void)postCell:(PostCell *)postCell didTap:(Post *)post{
    self.post = post;
    [self performSegueWithIdentifier:@"commentsSegue" sender:nil];
    
}
- (void)postCell:(PostCell *)postCell User:(Post *)post{
    self.user = post[@"author"];
    [self performSegueWithIdentifier:@"userSegue" sender:nil];
    
}
- (void)postCell:(PostCell *)postCell didLike:(Post *)post{
    self.post = post;
    NSLog(@"%@", postCell);
    PFRelation *relation = [self.post relationForKey:@"Liked_By"];
    PFQuery *query = [relation query];
    [query includeKey:@"author"];
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:^(NSArray* _Nullable likedBy, NSError * _Nullable error) {
        if (!error) {
            if(likedBy.count >0){
                for(NSDictionary *like in likedBy)
                {
                    if([like[@"username"] isEqual:[PFUser currentUser].username]){
                        User *user = [PFUser currentUser];
                        PFRelation *relation = [self.post relationForKey:@"Liked_By"];
                        NSNumber *likes = [NSNumber numberWithInt:([self.post[@"likeCount"] intValue] - 1)];
                        NSLog(@"likes: %@", likes);
                        self.post[@"likeCount"] = likes;
                        [relation removeObject:user];
                        [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            if(succeeded)
                            {
                                NSLog(@"Post unliked");
                                postCell.likeButton.selected = NO;
                                 //postCell.likeView.alpha = 0;
                                
                                [postCell refresh];
                            }
                        }];
                    }else{
                        NSLog(@"ELSE INSIDE IF");
                        User *user = [PFUser currentUser];
                        PFRelation *relation = [self.post relationForKey:@"Liked_By"];
                        NSNumber *likes = [NSNumber numberWithInt:([self.post[@"likeCount"] intValue] + 1)];
                        NSLog(@"likes: %@", likes);
                        self.post[@"likeCount"] = likes;
                        [relation addObject:user];
                        [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            if(succeeded)
                            {
                                NSLog(@"Post liked");
                                postCell.likeButton.selected = YES;
                                //postCell.likeView.alpha = 0;
                                [postCell refresh];
                            }
                        }];
                    }
                }
            }else{
                User *user = [PFUser currentUser];
                PFRelation *relation = [self.post relationForKey:@"Liked_By"];
                NSNumber *likes = [NSNumber numberWithInt:([self.post[@"likeCount"] intValue] + 1)];
                NSLog(@"likes: %@", likes);
                self.post[@"likeCount"] = likes;
                [relation addObject:user];
                [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(succeeded)
                    {
                        NSLog(@"Post liked");
                        postCell.likeButton.selected = YES;
                        //postCell.likeView.alpha = 0;
                        [postCell refresh];
                    }
                }];
            }
            
        }
        else {
        }
    }];
    
    
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"userSegue"])
    {
        UserViewController *userViewController = [segue destinationViewController];
        userViewController.user = self.user;
    }else{
        CommentsViewController *commentsViewController = [segue destinationViewController];
        commentsViewController.post = self.post;
    }
}

@end