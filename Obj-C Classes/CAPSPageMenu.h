//
//  CAPSPageMenu.h
//  
//
//  Created by Jin Sasaki on 2015/05/30.
//
//

#import <UIKit/UIKit.h>

/*
 整体结构介绍:
 上部分: menuScrollView (整个菜单栏)
 
 . 菜单项: MenuItemView (菜单里的单元项)
 . 标题: titleLabel (菜单项的标题)
 
 . 指示器: selectionIndicator (选中菜单项后,在该菜单项下面的一条线,表示选中了该项)
 . 发际线: MenuHairline (类似navigationBar下面的一条线,用于区别菜单栏和下面的)
 . 分离器: menuItemSeparator (菜单项之间,有点像胶布连接2个菜单项,只有在分段控制模式下才显示)
 
 下部分: controllerScrollView(以滚动方式呈现子视图的视图)
 
 */



@class CAPSPageMenu;

#pragma mark - Delegate functions
@protocol CAPSPageMenuDelegate <NSObject>

@optional
- (void)willMoveToPage:(UIViewController *)controller index:(NSInteger)index; // 将要移动到某个控制器中
- (void)didMoveToPage:(UIViewController *)controller index:(NSInteger)index;  // 已经移动到某个控制器中
@end

// 菜单项
@interface MenuItemView : UIView

@property (nonatomic) UILabel *titleLabel;       // 标题
@property (nonatomic) UIView *menuItemSeparator; // 菜单项分离器


/**
 创建菜单项视图
 
 @param menuItemWidth 菜单项宽度
 @param menuScrollViewHeight 菜单栏滚动视图高度
 @param indicatorHeight 指示器高度
 @param separatorPercentageHeight 分离器占菜单栏高度的百分比(0.0 ~ 1.0)
 @param separatorWidth 分离器宽度
 @param separatorRoundEdges 是否切分离器圆角(默认切宽度的一半)
 @param menuItemSeparatorColor 分离器颜色
 */
- (void)setUpMenuItemView:(CGFloat)menuItemWidth
     menuScrollViewHeight:(CGFloat)menuScrollViewHeight
          indicatorHeight:(CGFloat)indicatorHeight
separatorPercentageHeight:(CGFloat)separatorPercentageHeight
           separatorWidth:(CGFloat)separatorWidth
      separatorRoundEdges:(BOOL)separatorRoundEdges
   menuItemSeparatorColor:(UIColor *)menuItemSeparatorColor;


/**
 设置菜单项标题
 
 @param text 标题文字
 */
- (void)setTitleText:(NSString *)text;

@end



@interface CAPSPageMenu : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>

// 主视图
@property (nonatomic, strong) UIScrollView *menuScrollView;       // 菜单栏滚动视图
@property (nonatomic, strong) UIScrollView *controllerScrollView; // 存放子视图滚的动视图

@property (nonatomic, readonly) NSArray *controllerArray; //子视图数组
@property (nonatomic, readonly) NSArray *menuItems;       // 菜单项数组
@property (nonatomic, readonly) NSArray *menuItemWidths;  // 菜单项宽度数组

@property (nonatomic) NSInteger currentPageIndex; // 当前页下标
@property (nonatomic) NSInteger lastPageIndex;    // 旧的页下标(即上一个当前页下标)

@property (nonatomic) CGFloat menuHeight;                             // 菜单栏高度
@property (nonatomic) CGFloat menuMargin;                             // 第一个左边距,最后一个右边距,每个菜单项间的间距
@property (nonatomic) CGFloat menuItemWidth;                          // 菜单项宽度
@property (nonatomic) CGFloat selectionIndicatorHeight;               // 指示器高度
@property (nonatomic) NSInteger scrollAnimationDurationOnMenuItemTap; // 点击菜单项时滚动动画持续时间

@property (nonatomic) UIColor *selectionIndicatorColor;      // 指示器颜色
@property (nonatomic) UIColor *selectedMenuItemLabelColor;   // 选中菜单项颜色
@property (nonatomic) UIColor *unselectedMenuItemLabelColor; // 未选中菜单项颜色
@property (nonatomic) UIColor *scrollMenuBackgroundColor;    // 菜单栏背景颜色
@property (nonatomic) UIColor *viewBackgroundColor;          // 装载子视图的滚动视图背景颜色
@property (nonatomic) UIColor *bottomMenuHairlineColor;      // 发际线颜色
@property (nonatomic) UIColor *menuItemSeparatorColor;       // 分离器颜色

@property (nonatomic) UIFont *menuItemFont;                      // 菜单项标题字体
@property (nonatomic) CGFloat menuItemSeparatorPercentageHeight; // 分离器占菜单栏高度百分比
@property (nonatomic) CGFloat menuItemSeparatorWidth;            // 分离器宽度
@property (nonatomic) BOOL menuItemSeparatorRoundEdges;          // 是否切分离器圆角

@property (nonatomic) BOOL addBottomMenuHairline;              // 是否添加发际线
@property (nonatomic) BOOL menuItemWidthBasedOnTitleTextWidth; // 是否菜单项宽度基于标题宽
@property (nonatomic) BOOL useMenuLikeSegmentedControl;        // 是否菜单栏想分段控制器一样设置
@property (nonatomic) BOOL centerMenuItems;                    // 是否居中,如果菜单项总的不超过屏宽,且没有基于标题宽度来设置
@property (nonatomic) BOOL enableHorizontalBounce;             // 是否水平方向能超过父视图
@property (nonatomic) BOOL hideTopMenuBar;                     // 是否隐藏顶部菜单栏

@property (nonatomic, weak) id <CAPSPageMenuDelegate> delegate;


/**
 在该下标下添加页面
 
 @param index 对应的下标
 */
- (void)addPageAtIndex:(NSInteger)index;

/**
 移动到该下标下
 
 @param index 对应的下标
 */
- (void)moveToPage:(NSInteger)index;


/**
 初始化控制器
 
 @param viewControllers 子视图控制器数组
 @param frame 控制器位置
 @param options 选项设置(既颜色, 高宽等细节的设置)
 @return 创建好的控制器
 */
- (instancetype)initWithViewControllers:(NSArray *)viewControllers frame:(CGRect)frame options:(NSDictionary *)options;


/*
 设置选项
 
 补充: extern 全局变量设置的关键字
 const  该关键字后的变量无法修改,保证了选项名的一致
 */
extern NSString * const CAPSPageMenuOptionSelectionIndicatorHeight;             // 指示器高度
extern NSString * const CAPSPageMenuOptionMenuItemSeparatorWidth;               // 分离器宽度
extern NSString * const CAPSPageMenuOptionScrollMenuBackgroundColor;            // 菜单栏颜色
extern NSString * const CAPSPageMenuOptionViewBackgroundColor;                  // 装载子视图的滚动视图背景颜色
extern NSString * const CAPSPageMenuOptionBottomMenuHairlineColor;              // 发际线颜色
extern NSString * const CAPSPageMenuOptionSelectionIndicatorColor;              // 指示器颜色
extern NSString * const CAPSPageMenuOptionMenuItemSeparatorColor;               // 分离器颜色
extern NSString * const CAPSPageMenuOptionMenuMargin;                           // 第一个左边距,最后一个右边距,每个菜单项间的间距
extern NSString * const CAPSPageMenuOptionMenuHeight;                           // 菜单栏高度
extern NSString * const CAPSPageMenuOptionSelectedMenuItemLabelColor;           // 选中菜单项颜色
extern NSString * const CAPSPageMenuOptionUnselectedMenuItemLabelColor;         // 未选中菜单项颜色
extern NSString * const CAPSPageMenuOptionUseMenuLikeSegmentedControl;          // 是否菜单栏想分段控制器一样设置
extern NSString * const CAPSPageMenuOptionMenuItemSeparatorRoundEdges;          // 是否切分离器圆角
extern NSString * const CAPSPageMenuOptionMenuItemFont;                         // 菜单项标题字体
extern NSString * const CAPSPageMenuOptionMenuItemSeparatorPercentageHeight;    // 分离器占菜单栏高度百分比
extern NSString * const CAPSPageMenuOptionMenuItemWidth;                        // 菜单项的宽度
extern NSString * const CAPSPageMenuOptionEnableHorizontalBounce;               // 是否水平方向能超过父视图
extern NSString * const CAPSPageMenuOptionAddBottomMenuHairline;                // 是否添加发际线
extern NSString * const CAPSPageMenuOptionMenuItemWidthBasedOnTitleTextWidth;   // 是否菜单项宽度基于标题宽
extern NSString * const CAPSPageMenuOptionScrollAnimationDurationOnMenuItemTap; // 点击菜单项时滚动动画持续时间
extern NSString * const CAPSPageMenuOptionCenterMenuItems;                      // 是否居中,如果菜单项总的不超过屏宽,且没有基于标题宽度来设置
extern NSString * const CAPSPageMenuOptionHideTopMenuBar;                       // 是否隐藏顶部菜单栏

@end
