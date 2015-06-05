//
//  MoodCollectionViewCell.h
//  PageMenuDemoStoryboard
//
//  Created by 佐々木 尽 on 2015/06/05.
//  Copyright (c) 2015年 Jin Sasaki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoodCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIImageView *moodIconImageView;
@property (nonatomic, weak) IBOutlet UILabel *moodTitleLabel;

@end
