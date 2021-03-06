//
//  EditViewController.m
//  Instagram
//
//  Created by Xurxo Riesco on 7/5/20.
//  Copyright © 2020 Xurxo Riesco. All rights reserved.
//

#import "EditViewController.h"
#import "FinalComposeViewController.h"

@interface EditViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *grayImage;
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UIImageView *originalImage;
@property (weak, nonatomic) IBOutlet UIImageView *sepiaImage;
@property (weak, nonatomic) IBOutlet UILabel *sepiaLabel;
@property (weak, nonatomic) IBOutlet UILabel *normalLabel;
@property (weak, nonatomic) IBOutlet UILabel *grayLabel;
@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *image = [UIImage imageNamed:@"edit.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    self.mainImage.image = self.image;
    UITapGestureRecognizer *grayGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapGray:)];
    grayGestureRecognizer.numberOfTapsRequired = 1;
    [self.grayImage setUserInteractionEnabled:YES];
    [self.grayImage addGestureRecognizer:grayGestureRecognizer];
    UITapGestureRecognizer *originalGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOriginal:)];
    originalGestureRecognizer.numberOfTapsRequired = 1;
    [self.originalImage setUserInteractionEnabled:YES];
    [self.originalImage addGestureRecognizer:originalGestureRecognizer];
    self.normalLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    self.originalImage.image = self.image;
    UIImage *grayImage = [self grayscaleImage:self.mainImage.image];
    self.grayImage.image = grayImage;
    UITapGestureRecognizer *sepiaGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapSepia:)];
    sepiaGestureRecognizer.numberOfTapsRequired = 1;
    [self.sepiaImage setUserInteractionEnabled:YES];
    [self.sepiaImage addGestureRecognizer:sepiaGestureRecognizer];
    UIImage *sepiaImage = [self makeSepiaScale:self.mainImage.image];
    self.sepiaImage.image = sepiaImage;
}

#pragma mark - Editing
- (UIImage *)grayscaleImage:(UIImage *)image {
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIImage *grayscale = [ciImage imageByApplyingFilter:@"CIColorControls"
                                    withInputParameters: @{kCIInputSaturationKey : @0.0}];
    return [UIImage imageWithCIImage:grayscale];
}
-(UIImage*)makeSepiaScale:(UIImage*)image
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIImage *sepia = [ciImage imageByApplyingFilter:@"CISepiaTone"];
    return [UIImage imageWithCIImage:sepia];
}

- (IBAction)didTapGray:(UISwipeGestureRecognizer *)sender {
    self.grayLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    self.sepiaLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    self.normalLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    self.mainImage.image = self.grayImage.image;
    self.image = self.grayImage.image;
}

- (IBAction)didTapOriginal:(UISwipeGestureRecognizer *)sender {
    self.normalLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    self.grayLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    self.sepiaLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    self.mainImage.image = self.originalImage.image;
    self.image = self.originalImage.image;
}
- (IBAction)didTapSepia:(UISwipeGestureRecognizer *)sender {
    self.normalLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    self.grayLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    self.sepiaLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    self.mainImage.image = self.sepiaImage.image;
    self.image = self.sepiaImage.image;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    FinalComposeViewController *finalComposeViewController = [segue destinationViewController];
    finalComposeViewController.image = self.image;
}

@end
