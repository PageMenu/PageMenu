//
//  CAPSPageMenu.h
//  
//
//  Created by Jin Sasaki on 2015/05/30.
//
//

#import <UIKit/UIKit.h>

@class CAPSPageMenu;

#pragma mark - Delegate functions
@protocol CAPSPageMenuDelegate <NSObject>

@optional
- (void)willMoveToPage:(UIViewController *)controller index:(NSInteger)index;
- (void)didMoveToPage:(UIViewController *)controller index:(NSInteger)index;
@end

@interface MenuItemView : UIView

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIView *menuItemSeparator;

- (void)setUpMenuItemView:(CGFloat)menuItemWidth menuScrollViewHeight:(CGFloat)menuScrollViewHeight indicatorHeight:(CGFloat)indicatorHeight separatorPercentageHeight:(CGFloat)separatorPercentageHeight separatorWidth:(CGFloat)separatorWidth separatorRoundEdges:(BOOL)separatorRoundEdges menuItemSeparatorColor:(UIColor *)menuItemSeparatorColor;

- (void)setTitleText:(NSString *)text;
@end

typedef NS_ENUM(NSUInteger, CAPSPageMenuScrollDirection) {
    CAPSPageMenuScrollDirectionLeft,
    CAPSPageMenuScrollDirectionRight,
    CAPSPageMenuScrollDirectionOther
};

@interface CAPSPageMenu : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *menuScrollView;
@property (nonatomic, strong) UIScrollView *controllerScrollView;
@property (nonatomic) NSArray *controllerArray;
@property (nonatomic) NSArray *menuItems;
@property (nonatomic) NSArray *menuItemWidths;

@property (nonatomic) CGFloat menuHeight;
@property (nonatomic) CGFloat menuMargin;
@property (nonatomic) CGFloat menuItemWidth;
@property (nonatomic) CGFloat selectionIndicatorHeight;
@property (nonatomic) CGFloat totalMenuItemWidthIfDifferentWidths;
@property (nonatomic) NSInteger scrollAnimationDurationOnMenuItemTap;
@property (nonatomic) CGFloat startingMenuMargin;

@property (nonatomic) UIView *selectionIndicatorView;
@property (nonatomic) NSInteger currentPageIndex;
@property (nonatomic) NSInteger lastPageIndex;

@property (nonatomic) UIColor *selectionIndicatorColor;
@property (nonatomic) UIColor *selectedMenuItemLabelColor;
@property (nonatomic) UIColor *unselectedMenuItemLabelColor;
@property (nonatomic) UIColor *scrollMenuBackgroundColor;
@property (nonatomic) UIColor *viewBackgroundColor;
@property (nonatomic) UIColor *bottomMenuHairlineColor;
@property (nonatomic) UIColor *menuItemSeparatorColor;

@property (nonatomic) UIFont *menuItemFont;
@property (nonatomic) CGFloat menuItemSeparatorPercentageHeight;
@property (nonatomic) CGFloat menuItemSeparatorWidth;
@property (nonatomic) BOOL menuItemSeparatorRoundEdges;

@property (nonatomic) BOOL addBottomMenuHairline;
@property (nonatomic) BOOL menuItemWidthBasedOnTitleTextWidth;
@property (nonatomic) BOOL useMenuLikeSegmentedControl;
@property (nonatomic) BOOL centerMenuItems;
@property (nonatomic) BOOL enableHorizontalBounce;
@property (nonatomic) BOOL hideTopMenuBar;

@property (nonatomic) BOOL currentOrientationIsPortrait;
@property (nonatomic) NSInteger pageIndexForOrientationChange;
@property (nonatomic) BOOL didLayoutSubviewsAfterRotation;
@property (nonatomic) BOOL didScrollAlready;

@property (nonatomic) CGFloat lastControllerScrollViewContentOffset;
@property (nonatomic) CAPSPageMenuScrollDirection lastScrollDirection;
@property (nonatomic) NSInteger startingPageForScroll;
@property (nonatomic) BOOL didTapMenuItemToScroll;
@property (nonatomic) NSDictionary *pagesAddedDictionary;

@property (nonatomic, weak) id <CAPSPageMenuDelegate> delegate;
@property (nonatomic) NSTimer *tapTimer;
- (void)addPageAtIndex:(NSInteger)index;
- (void)moveToPage:(NSInteger)index;
- (instancetype)initWithViewControllers:(NSArray *)viewControllers frame:(CGRect)frame options:(NSDictionary *)options;
@end
