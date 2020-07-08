//
//  UserViewController.m
//  Instagram
//
//  Created by Xurxo Riesco on 7/7/20.
//  Copyright © 2020 Xurxo Riesco. All rights reserved.
//

#import "UserViewController.h"
#import "User.h"
#import "ProfileCell.h"
#import "CommentsViewController.h"
@import Parse;


@interface UserViewController () <UICollectionViewDelegate, UICollectionViewDataSource, ProfileCellDelegate>
@property (weak, nonatomic) IBOutlet PFImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property int followerCount;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    CGFloat postersPerLine = 3;
    CGFloat itemWidth = self.collectionView.frame.size.width / postersPerLine;
    CGFloat itemHeight = itemWidth * 0.9;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    self.navigationItem.title = self.user[@"username"];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor],
       NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:17]}];
    self.usernameLabel.text = self.user[@"username"];
    self.photoImageView.file = self.user[@"profilePic"];
    self.photoImageView.layer.cornerRadius = 48;
    self.photoImageView.layer.masksToBounds = YES;
    PFQuery *queryUsers = [PFUser query];
    queryUsers.limit = 20;
    [queryUsers findObjectsInBackgroundWithBlock:^(NSArray* users, NSError * _Nullable error) {
        NSLog(@"HereWeAre");
        NSLog(@"%@", users);
        for(PFUser *user in users)
        {
            NSLog(@"HereWeAreAGAAAIN");
            NSLog(@"%@", user);
            PFRelation *relation = [user relationForKey:@"Following"];
            PFQuery *query = [relation query];
            query.limit = 20;
            BOOL isItMe = NO;
            if([user.username isEqual:([PFUser currentUser].username)]){
                isItMe = YES;
            }
            [query findObjectsInBackgroundWithBlock:^(NSArray<User*>* _Nullable following, NSError * _Nullable error) {
                for(PFUser *user in following){
                           if([user.username isEqual:(self.user.username)]){
                               if(isItMe){
                                   self.followButton.titleLabel.text = @"Unfollow";
                               }
                               NSLog(@"yessir");
                               self.followerCount += 1;
                           }
                    }
                self.followersLabel.text = [NSString stringWithFormat:@"%d", self.followerCount];
               }];
        }
        NSLog(@"%d", self.followerCount);

    }];
    PFRelation *relation = [self.user relationForKey:@"Following"];
    PFQuery *query = [relation query];
    [query includeKey:@"author"];
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:^(NSArray<User*>* _Nullable following, NSError * _Nullable error) {
            self.followingLabel.text = [NSString stringWithFormat:@"%ld", following.count];
    }];
    [self.photoImageView loadInBackground];
    [self fecthPost];
    // Do any additional setup after loading the view.
}
- (void)profileCell:(ProfileCell *)profileCell didTap:(Post *)post{
    self.post = post;
    NSLog(@"Hello");
    [self performSegueWithIdentifier:@"detailsSegue" sender:nil];
}

- (void)fecthPost {
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery whereKey:@"author" equalTo:self.user];
    [postQuery includeKey:@"author"];
    postQuery.limit = 20;
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            NSLog(@"%@", posts);
            self.posts = [posts mutableCopy];
            self.postLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.posts.count];
            [self.collectionView reloadData];
        }
        else {
        }
    }];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.posts.count;
}
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    ProfileCell *profileCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileCell" forIndexPath: indexPath];
    Post *post = self.posts[indexPath.item];
    [profileCell loadPost:post];
    profileCell.delegate = self;
    return profileCell;
}
- (IBAction)onFollow:(id)sender{
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"Following"];
    PFQuery *query = [relation query];
    [query includeKey:@"author"];
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:^(NSArray<User*>* _Nullable following, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"%@", following);
            if(following.count >0){
                for(PFUser *user in following)
                {
                    NSLog(@"%@", user);
                    if([user[@"username"] isEqual:self.user.username]){
                        User *currenUser = [PFUser currentUser];
                        PFRelation *relation = [currenUser relationForKey:@"Following"];
                        [relation removeObject:self.user];
                        [currenUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            if(succeeded){
                                NSLog(@"Unfollowing %@", self.user.username);
                                 self.followersLabel.text = [NSString stringWithFormat:@"%d", self.followerCount-1];
                                self.followerCount -=1;
                                self.followButton.titleLabel.text = @"Follow";
                                //[self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
                            }else{
                            }
                        }];
                    }else{
                        User *currenUser = [PFUser currentUser];
                        PFRelation *relation = [currenUser relationForKey:@"Following"];
                        [relation addObject:self.user];
                        [currenUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            if(succeeded){
                                NSLog(@"Following %@", self.user.username);
                                self.followersLabel.text = [NSString stringWithFormat:@"%d", self.followerCount+1];
                                self.followerCount +=1;
                                self.followButton.titleLabel.text = @"Unfollow";
                                //[self.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
                            }else{
                                
                            }
                        }];
                    }
                }
            }else{
                
                User *currenUser = [PFUser currentUser];
                PFRelation *relation = [currenUser relationForKey:@"Following"];
                [relation addObject:self.user];
                [currenUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(succeeded){
                        NSLog(@"Following %@", self.user.username);
                        self.followersLabel.text = [NSString stringWithFormat:@"%d", self.followerCount+1];
                        self.followerCount +=1;
                        self.followButton.titleLabel.text = @"Unfollow";
                        //[self.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
                    }else{
                        
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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    CommentsViewController *commentsViewController = [segue destinationViewController];
    commentsViewController.post = self.post;
}


@end
