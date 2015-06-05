//
//  TestCollectionViewController.m
//  PageMenuDemoStoryboard
//
//  Created by Jin Sasaki on 2015/06/05.
//  Copyright (c) 2015年 Jin Sasaki. All rights reserved.
//

#import "TestCollectionViewController.h"

@interface TestCollectionViewController ()
@property (nonatomic) NSArray *moodArray;
@property (nonatomic) NSArray *backgroundPhotoNameArray;
@property (nonatomic) NSArray *photoNameArray;
@end

@implementation TestCollectionViewController

static NSString * const reuseIdentifier = @"MoodCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.moodArray = @[@"Relaxed", @"Playful", @"Happy", @"Adventurous", @"Wealthy", @"Hungry", @"Loved", @"Active"];
    self.backgroundPhotoNameArray = @[@"mood1.jpg", @"mood2.jpg", @"mood3.jpg", @"mood4.jpg", @"mood5.jpg", @"mood6.jpg", @"mood7.jpg", @"mood8.jpg"];
    self.photoNameArray = @[@"relax.png", @"playful.png", @"happy.png", @"adventurous.png", @"wealthy.png", @"hungry.png", @"loved.png", @"active.png"];
    
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"MoodCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MoodCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    // Configure the cell
    cell.moodTitleLabel.text = self.moodArray[indexPath.row];
    cell.backgroundImageView.image = [UIImage imageNamed: self.backgroundPhotoNameArray[indexPath.row]];
    cell.moodIconImageView.image = [UIImage imageNamed: self.photoNameArray[indexPath.row]];
    
    
    return cell;
}
@end
