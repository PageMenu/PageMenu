//
//  CAPSPageMenu.m
//
//
//  Created by Jin Sasaki on 2015/05/30.
//
//

#import "CAPSPageMenu.h"

@interface MenuItemView ()

@end

@implementation MenuItemView

- (void)setUpMenuItemView:(CGFloat)menuItemWidth
     menuScrollViewHeight:(CGFloat)menuScrollViewHeight
          indicatorHeight:(CGFloat)indicatorHeight
separatorPercentageHeight:(CGFloat)separatorPercentageHeight
           separatorWidth:(CGFloat)separatorWidth
      separatorRoundEdges:(BOOL)separatorRoundEdges
   menuItemSeparatorColor:(UIColor *)menuItemSeparatorColor
{
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, menuItemWidth, menuScrollViewHeight - indicatorHeight)];
    _menuItemSeparator = [[UIView alloc] initWithFrame:CGRectMake(menuItemWidth - (separatorWidth / 2), floor(menuScrollViewHeight * ((1.0 - separatorPercentageHeight) / 2.0)), separatorWidth, floor(menuScrollViewHeight * separatorPercentageHeight))];
    
    if (separatorRoundEdges) {
        _menuItemSeparator.layer.cornerRadius = _menuItemSeparator.frame.size.width / 2;
    }
    
    _menuItemSeparator.hidden = YES;
    [self addSubview:_menuItemSeparator];
    [self addSubview:_titleLabel];
}


/**
 设置菜单项标题
 
 @param text 标题文本
 */
- (void)setTitleText:(NSString *)text
{
    if (_titleLabel) {
        _titleLabel.text = text;
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        
        /*
         UIBaselineAdjustment: 控制文本的基线位置, 只有文本数为1有效
         
         UIBaselineAdjustmentAlignBaselines 文本变化前后都与label的顶部对齐
         UIBaselineAdjustmentAlignCenters   文本变化前后都与label的中线对齐
         UIBaselineAdjustmentNone           文本变化前后都与label的底部对齐
         */
        _titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    }
}

@end

typedef NS_ENUM(NSUInteger, CAPSPageMenuScrollDirection) {
    CAPSPageMenuScrollDirectionLeft,
    CAPSPageMenuScrollDirectionRight,
    CAPSPageMenuScrollDirectionOther
};

@interface CAPSPageMenu ()

@property (nonatomic) NSMutableArray *mutableMenuItems;            // 菜单项可变数组
@property (nonatomic) NSMutableArray *mutableMenuItemWidths;       // 菜单项宽度可变数组(菜单项宽度不一致时候,存放菜单项宽度)
@property (nonatomic) CGFloat totalMenuItemWidthIfDifferentWidths; // 如果菜单项宽度不一致,(当前下标下的)总的菜单项宽度

/*
 设置的首菜单项距离父视图左侧留白位置距离父视图还有的距离,只有在centerMenuItems = YES时候设置
 因为留白和菜单项宽度都是可以设置的,如果设置好了,但是总的宽度小于屏幕总宽度,此时就有该属性,即保护距离.
 eg: menuMargin = 10; menuItemWidth = 20; controllerArray.count = 2; 此时设置的总宽度是(10+20)*2 + 10 = 70,假设屏幕宽375
 则此时距离父视图左右还是有留白的,此时 startingMenuMargin = (375-70)/2 = 152.5
 */
@property (nonatomic) CGFloat startingMenuMargin;

@property (nonatomic) UIView *selectionIndicatorView; // 指示器

@property (nonatomic) BOOL currentOrientationIsPortrait;       // 是否当前方向是竖屏
@property (nonatomic) NSInteger pageIndexForOrientationChange; //
@property (nonatomic) BOOL didLayoutSubviewsAfterRotation;     // 是否旋转后布局子视图
@property (nonatomic) CGFloat lastControllerScrollViewContentOffset;   // 上一次滚动结束后controllerScrollView的偏移量,即旧的偏移量
@property (nonatomic) CAPSPageMenuScrollDirection lastScrollDirection; // 旧的的滑动方向

/*
 是否在滑动了
 只有在利用 controllerScrollView 滑动翻页时候才会使用这个属性
 YES:在滑动了
 NO:没有滑动
 */
@property (nonatomic) BOOL didScrollAlready;

/*
 一个滑动过程中,开始滑动时的下标页
 作用:在didScrollAlready = YES情况下,即一个滑动过程完成后
 进入下个滑动过程的时候,根据该属性来记录controllerScrollView在这个滑动过程中的其实偏移量,然后根据这个便宜量判断滑动方向
 */
@property (nonatomic) NSInteger startingPageForScroll;

/*
 是否在点击菜单项后能能发生滚动
 YES情况下是滑动controllerScrollView
 NO情况是点击菜单项进行滑动
 */
@property (nonatomic) BOOL didTapMenuItemToScroll;

/*
 记录下标页的字典
 作用:记录哪些子视图控制器被添加到了父视图上,后面滑动结束后会移除除了当前子视图控制之外的视图控制器
 */
@property (nonatomic) NSMutableSet *pagesAddedSet;

@property (nonatomic) NSTimer *tapTimer;           // 点击计时器

@end

@implementation CAPSPageMenu

NSString * const CAPSPageMenuOptionSelectionIndicatorHeight             = @"selectionIndicatorHeight";
NSString * const CAPSPageMenuOptionMenuItemSeparatorWidth               = @"menuItemSeparatorWidth";
NSString * const CAPSPageMenuOptionScrollMenuBackgroundColor            = @"scrollMenuBackgroundColor";
NSString * const CAPSPageMenuOptionViewBackgroundColor                  = @"viewBackgroundColor";
NSString * const CAPSPageMenuOptionBottomMenuHairlineColor              = @"bottomMenuHairlineColor";
NSString * const CAPSPageMenuOptionSelectionIndicatorColor              = @"selectionIndicatorColor";
NSString * const CAPSPageMenuOptionMenuItemSeparatorColor               = @"menuItemSeparatorColor";
NSString * const CAPSPageMenuOptionMenuMargin                           = @"menuMargin";
NSString * const CAPSPageMenuOptionMenuHeight                           = @"menuHeight";
NSString * const CAPSPageMenuOptionSelectedMenuItemLabelColor           = @"selectedMenuItemLabelColor";
NSString * const CAPSPageMenuOptionUnselectedMenuItemLabelColor         = @"unselectedMenuItemLabelColor";
NSString * const CAPSPageMenuOptionUseMenuLikeSegmentedControl          = @"useMenuLikeSegmentedControl";
NSString * const CAPSPageMenuOptionMenuItemSeparatorRoundEdges          = @"menuItemSeparatorRoundEdges";
NSString * const CAPSPageMenuOptionMenuItemFont                         = @"menuItemFont";
NSString * const CAPSPageMenuOptionMenuItemSeparatorPercentageHeight    = @"menuItemSeparatorPercentageHeight";
NSString * const CAPSPageMenuOptionMenuItemWidth                        = @"menuItemWidth";
NSString * const CAPSPageMenuOptionEnableHorizontalBounce               = @"enableHorizontalBounce";
NSString * const CAPSPageMenuOptionAddBottomMenuHairline                = @"addBottomMenuHairline";
NSString * const CAPSPageMenuOptionMenuItemWidthBasedOnTitleTextWidth   = @"menuItemWidthBasedOnTitleTextWidth";
NSString * const CAPSPageMenuOptionScrollAnimationDurationOnMenuItemTap = @"scrollAnimationDurationOnMenuItemTap";
NSString * const CAPSPageMenuOptionCenterMenuItems                      = @"centerMenuItems";
NSString * const CAPSPageMenuOptionHideTopMenuBar                       = @"hideTopMenuBar";

- (instancetype)initWithViewControllers:(NSArray *)viewControllers
                                  frame:(CGRect)frame
                                options:(NSDictionary *)options
{
    self = [super initWithNibName:nil bundle:nil];
    if (!self) return nil;
    
    // 初始化数值
    [self initValues];
    
    _controllerArray = viewControllers;
    
    self.view.frame = frame;
    
    if (options) {
        for (NSString *key in options) {
            if ([key isEqualToString:CAPSPageMenuOptionSelectionIndicatorHeight]) {
                _selectionIndicatorHeight = [options[key] floatValue];
            } else if ([key isEqualToString: CAPSPageMenuOptionMenuItemSeparatorWidth]) {
                _menuItemSeparatorWidth = [options[key] floatValue];
            } else if ([key isEqualToString:CAPSPageMenuOptionScrollMenuBackgroundColor]) {
                _scrollMenuBackgroundColor = (UIColor *)options[key];
            } else if ([key isEqualToString:CAPSPageMenuOptionViewBackgroundColor]) {
                _viewBackgroundColor = options[key];
            } else if ([key isEqualToString:CAPSPageMenuOptionBottomMenuHairlineColor]) {
                _bottomMenuHairlineColor = options[key];
            } else if ([key isEqualToString:CAPSPageMenuOptionSelectionIndicatorColor]) {
                _selectionIndicatorColor = options[key];
            } else if ([key isEqualToString:CAPSPageMenuOptionMenuItemSeparatorColor]) {
                _menuItemSeparatorColor = options[key];
            } else if ([key isEqualToString:CAPSPageMenuOptionMenuMargin]) {
                _menuMargin = [options[key] floatValue];
            } else if ([key isEqualToString:CAPSPageMenuOptionMenuHeight]) {
                _menuHeight = [options[key] floatValue];
            } else if ([key isEqualToString:CAPSPageMenuOptionSelectedMenuItemLabelColor]) {
                _selectedMenuItemLabelColor = options[key];
            } else if ([key isEqualToString:CAPSPageMenuOptionUnselectedMenuItemLabelColor]) {
                _unselectedMenuItemLabelColor = options[key];
            } else if ([key isEqualToString:CAPSPageMenuOptionUseMenuLikeSegmentedControl]) {
                _useMenuLikeSegmentedControl = [options[key] boolValue];
            } else if ([key isEqualToString:CAPSPageMenuOptionMenuItemSeparatorRoundEdges]) {
                _menuItemSeparatorRoundEdges = [options[key] boolValue];
            } else if ([key isEqualToString:CAPSPageMenuOptionMenuItemFont]) {
                _menuItemFont = options[key];
            } else if ([key isEqualToString:CAPSPageMenuOptionMenuItemSeparatorPercentageHeight]) {
                _menuItemSeparatorPercentageHeight = [options[key] floatValue];
            } else if ([key isEqualToString:CAPSPageMenuOptionMenuItemWidth]) {
                _menuItemWidth = [options[key] floatValue];
            } else if ([key isEqualToString:CAPSPageMenuOptionEnableHorizontalBounce]) {
                _enableHorizontalBounce = [options[key] boolValue];
            } else if ([key isEqualToString:CAPSPageMenuOptionAddBottomMenuHairline]) {
                _addBottomMenuHairline = [options[key] boolValue];
            } else if ([key isEqualToString:CAPSPageMenuOptionMenuItemWidthBasedOnTitleTextWidth]) {
                _menuItemWidthBasedOnTitleTextWidth = [options[key] boolValue];
            } else if ([key isEqualToString:CAPSPageMenuOptionScrollAnimationDurationOnMenuItemTap]) {
                _scrollAnimationDurationOnMenuItemTap = [options[key] integerValue];
            } else if ([key isEqualToString:CAPSPageMenuOptionCenterMenuItems]) {
                _centerMenuItems = [options[key] boolValue];
            } else if ([key isEqualToString:CAPSPageMenuOptionHideTopMenuBar]) {
                _hideTopMenuBar = [options[key] boolValue];
            }
        }
        
        if (_hideTopMenuBar) {
            _addBottomMenuHairline = NO;
            _menuHeight = 0.0;
        }
    }
    
    
    // 创建UI
    [self setUpUserInterface];
    if (_menuScrollView.subviews.count == 0) { // 确保没有配置过
        // 配置UI
        [self configureUserInterface];
    }
    return self;
}

/**
 初始化数值
 */
- (void)initValues
{
    _menuScrollView         = [UIScrollView new];     // 菜单栏滚动视图
    _controllerScrollView   = [UIScrollView new];     // 存放子视图的滚动视图
    _selectionIndicatorView = [UIView new];           // 指示器视图
    _mutableMenuItems       = [NSMutableArray array]; // 菜单项可变数组
    _mutableMenuItemWidths  = [NSMutableArray array]; // 菜单项宽度可变数组
    
    _menuHeight                           = 34.0;  // 菜单栏高度
    _menuMargin                           = 15.0;  // 是否标题能超过菜单项宽度,如果不支持当前菜单项宽度基于标题宽度
    _menuItemWidth                        = 111.0; // 菜单项宽度
    _selectionIndicatorHeight             = 3.0;   // 指示器高度
    _totalMenuItemWidthIfDifferentWidths  = 0.0;   // 如果菜单项宽度不一致总的菜单项宽度
    _scrollAnimationDurationOnMenuItemTap = 500;   // 点击菜单项滚动视图动画时间
    _startingMenuMargin                   = 0.0;   // 保险左右留白,具体作用看属性申明处
    
    _currentPageIndex = 0; // 当前页下标
    _lastPageIndex    = 0; // 旧的页面(前一个当前页)
    
    _selectionIndicatorColor      = [UIColor whiteColor];     // 指示器颜色
    _selectedMenuItemLabelColor   = [UIColor whiteColor];     // 选中菜单项颜色
    _unselectedMenuItemLabelColor = [UIColor lightGrayColor]; // 未选中菜单项颜色
    _scrollMenuBackgroundColor    = [UIColor blackColor];     // 菜单栏背景颜色
    _viewBackgroundColor          = [UIColor whiteColor];     // 存放子视图的滚动视图的背景颜色
    _bottomMenuHairlineColor      = [UIColor whiteColor];     // 发际线颜色
    _menuItemSeparatorColor       = [UIColor lightGrayColor]; // 分离器颜色
    
    _menuItemFont = [UIFont systemFontOfSize:15.0]; // 菜单项标题文本字体大小
    _menuItemSeparatorPercentageHeight = 0.2;  // 分离器占菜单栏高度的百分比
    _menuItemSeparatorWidth            = 0.5;  // 分离器宽
    _menuItemSeparatorRoundEdges       = NO;   // 分离器不切圆角
    
    _addBottomMenuHairline              = YES; // 给菜单栏底部添加发际线
    _menuItemWidthBasedOnTitleTextWidth = NO;  // 菜单项宽度不需要基于标题文本的宽度
    _useMenuLikeSegmentedControl        = NO;  // 菜单栏的使用不需要想分段控制器一样
    _centerMenuItems                    = NO;  // 是否居中,如果菜单项总的不超过屏宽,且没有基于标题宽度来设置
    _enableHorizontalBounce             = YES; // 水平方向能超过父视图
    _hideTopMenuBar                     = NO;  // 不隐藏顶部菜单条
    
    _currentOrientationIsPortrait   = YES; // 当前方向是竖屏
    _pageIndexForOrientationChange  = 0;   // 方向改变页面下标是0
    _didLayoutSubviewsAfterRotation = NO;  // 旋转后不需要子视图布局
    _didScrollAlready               = NO;  // 没有在滑动
    
    _lastControllerScrollViewContentOffset = 0.0; // 旧的ControllerScrollView偏移量
    _startingPageForScroll = 0;   // 每次滑动过程中,滑动起始时的下标页
    _didTapMenuItemToScroll = NO; // 点击菜单项不会发生滑动
    
    _pagesAddedSet = [NSMutableSet set]; // 滑动过程中出现过的页面的下标
}


/**搭建UI*/
- (void)setUpUserInterface
{
    // 视图字典
    NSDictionary *viewsDictionary = @{
                                      @"menuScrollView" : _menuScrollView,          // 菜单栏滚动视图
                                      @"controllerScrollView":_controllerScrollView // 存放子视图的滚动视图
                                      };
    
    // 设置 存放子视图的滚动视图 的相关设置
    _controllerScrollView.pagingEnabled                             = YES;  // 按页滑动
    _controllerScrollView.translatesAutoresizingMaskIntoConstraints = NO;   // 取消系统自己约束,采取手动添加约束
    _controllerScrollView.alwaysBounceHorizontal = _enableHorizontalBounce; // 水平方向上根据 _enableHorizontalBounce 设置是否可以超过父视图
    _controllerScrollView.bounces                = _enableHorizontalBounce; // 根据 _enableHorizontalBounce 设置是否可以超过父视图
    
    _controllerScrollView.frame = CGRectMake(0.0, _menuHeight, self.view.frame.size.width, self.view.frame.size.height);
    
    [self.view addSubview:_controllerScrollView];
    
    // 水平方向上, controllerScrollView距离父视图左右像素为0
    NSArray *controllerScrollView_constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[controllerScrollView]|"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:viewsDictionary];
    
    // 竖直方向上, controllerScrollView距离父视图顶部和底部像素为0
    NSString *controllerScrollView_constraint_V_Format = [NSString stringWithFormat:@"V:|-0-[controllerScrollView]|"];
    NSArray *controllerScrollView_constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:controllerScrollView_constraint_V_Format
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:viewsDictionary];
    
    [self.view addConstraints:controllerScrollView_constraint_H];
    [self.view addConstraints:controllerScrollView_constraint_V];
    
    // 设置菜单栏的相关设置
    _menuScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _menuScrollView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, _menuHeight);
    [self.view addSubview:_menuScrollView];
    
    // 水平方向上, menuScrollView距离父视图左右像素为0
    NSArray *menuScrollView_constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[menuScrollView]|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:viewsDictionary];
    
    // 竖直方向上, menuScrollView距离父视图顶部像素为0, 高度为 _menuHeight
    NSString *menuScrollView_constrant_V_Format = [NSString stringWithFormat:@"V:|[menuScrollView(%.f)]",_menuHeight];
    NSArray *menuScrollView_constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:menuScrollView_constrant_V_Format
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:viewsDictionary];
    
    [self.view addConstraints:menuScrollView_constraint_H];
    [self.view addConstraints:menuScrollView_constraint_V];
    
    if (_addBottomMenuHairline) {
        // 发际线设置
        UIView *menuBottomHairline = [UIView new];
        
        menuBottomHairline.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view addSubview:menuBottomHairline];
        
        // 水平方向上, menuBottomHairline距离父视图左右像素为0
        NSArray *menuBottomHairline_constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[menuBottomHairline]|"
                                                                                           options:0
                                                                                           metrics:nil
                                                                                             views:@{@"menuBottomHairline":menuBottomHairline}];
        
        // 竖直方向上, menuBottomHairline距离父视图顶部像素为_menuHeight, 高度为0.5
        NSString *menuBottomHairline_constraint_V_Format = [NSString stringWithFormat:@"V:|-%f-[menuBottomHairline(0.5)]",_menuHeight];
        NSArray *menuBottomHairline_constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:menuBottomHairline_constraint_V_Format
                                                                                           options:0
                                                                                           metrics:nil
                                                                                             views:@{@"menuBottomHairline":menuBottomHairline}];
        
        [self.view addConstraints:menuBottomHairline_constraint_H];
        [self.view addConstraints:menuBottomHairline_constraint_V];
        
        menuBottomHairline.backgroundColor = _bottomMenuHairlineColor;
    }
    
    // 设置相关滚动条, 都不显示
    _menuScrollView.showsHorizontalScrollIndicator       = NO;
    _menuScrollView.showsVerticalScrollIndicator         = NO;
    _controllerScrollView.showsHorizontalScrollIndicator = NO;
    _controllerScrollView.showsVerticalScrollIndicator   = NO;
    
    // 设置背景颜色
    self.view.backgroundColor = _viewBackgroundColor;
    _menuScrollView.backgroundColor = _scrollMenuBackgroundColor;
}


/**
 配置UI思路整理:
 基本包括: 视图位置,文本大小,文本颜色,首个子视图控制器设置
 默认当前选择下标是0,总体设计样式分为2类: 1.类似分段控制器的样式
 2.其他: (1)为根据标题长度设置菜单项宽度
 (2)菜单项等宽: a.总的小于屏宽时居中,菜单项等宽
 b.其他,菜单项等宽
 ==================================================================================================
 1.创建手势
 2.设置滚动视图contentSize.
 controllerScrollView子视图个数*屏宽
 menuScrollView设置:(1)类似分段控制器,屏幕宽
 (2)其他,空隙+所有菜单项宽
 3.for循环中详细配置.
 (1)将首个子视图控制器加载到父视图控制器中
 (2)设置菜单项的frame: 1->分段控制器样式:屏幕宽度均分,根据下标对应位置
 2->其他: (1)->菜单项宽度不一致,根据标题字体长度设置宽度,并且把宽度存放在mutableMenuItemWidths数组中
 (2)->菜单项等宽: a->总的小于屏宽时居中,菜单项等宽.先计算startingMenuMargin宽度,再根据下标设置frame
 b->其他情况,根据下标设置frame
 (3)创建菜单项视图,配置其颜色,字体等,加载到menuScrollView上,并添加到mutableMenuItems数组中
 4.如果是根据标题宽设置菜单项宽,则重新配置menuScrollView的contenSize
 5.配置选中的菜单项的标题颜色
 6.配置指示器位置,此时指示器位置是根据currentPageIndex设置,和当前菜单项宽度一致
 */
- (void)configureUserInterface
{
    //=====================
    // 创建点击菜单项的手势
    //=====================
    UITapGestureRecognizer *menuItemTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleMenuItemTap:)];
    menuItemTapGestureRecognizer.numberOfTapsRequired    = 1; // 点击次数
    menuItemTapGestureRecognizer.numberOfTouchesRequired = 1; // 需要的手指数
    menuItemTapGestureRecognizer.delegate                = self;
    [_menuScrollView addGestureRecognizer:menuItemTapGestureRecognizer];
    
    
    //=====================
    // 2个滚动视图的配置
    //=====================
    
    _controllerScrollView.delegate = self;
    
    /*
     When the user taps the status bar, the scroll view beneath the touch which is closest to the status bar will be scrolled to top,
     but only if its `scrollsToTop` property is YES, its delegate does not return NO from `shouldScrollViewScrollToTop`, and it is not already at the top.
     If more than one scroll view is found, none will be scrolled.
     Disable scrollsToTop for menu and controller scroll views so that iOS finds scroll views within our pages on status bar tap gesture.
     
     scrollsToTop 属性默认是YES,是点击状态栏,然后滚动视图会自动的滚动到顶部. 因为给菜单项添加了手势,所以需要禁止此属性,以便点击后能触发我们设置的手势
     */
    _menuScrollView.scrollsToTop       = NO;;
    _controllerScrollView.scrollsToTop = NO;;
    
    // 配置菜单栏内容大小
    if (_useMenuLikeSegmentedControl) { // 若菜单像分段控制器一样使用
        _menuScrollView.scrollEnabled = NO; // 不按页滑动
        _menuScrollView.contentSize = CGSizeMake(self.view.frame.size.width, _menuHeight); // 屏宽,菜单栏高
        _menuMargin = 0.0; // 不留空
    } else { // 若菜单不像分段控制器一样使用
        _menuScrollView.contentSize = CGSizeMake((_menuItemWidth + _menuMargin) * (CGFloat)_controllerArray.count + _menuMargin, _menuHeight); // 所有空格宽度加上菜单项宽度, 菜单栏高
    }
    // 配置 存放子视图的滚动视图 内容大小
    _controllerScrollView.contentSize = CGSizeMake(self.view.frame.size.width * (CGFloat)_controllerArray.count, 0.0); // 所有子视图宽, 高0
    
    
    CGFloat index = 0.0;
    for (UIViewController *controller in _controllerArray) {
        if (index == 0.0) {
            // Add first two controllers to scrollview and as child view controller
            // 添加第一个子视图控制器到滚动视图上,并作为其子视图控制器
            [controller viewWillAppear:YES];
            [self addPageAtIndex:0];
            [controller viewDidAppear:YES];
        }
        
        //=====================
        // 配置每个菜单项frame
        //=====================
        CGRect menuItemFrame;
        
        if (_useMenuLikeSegmentedControl) { // 菜单类似分段控制器一样
            
            CGFloat x = self.view.frame.size.width / (CGFloat)_controllerArray.count * (CGFloat)index;
            CGFloat y = 0.0;
            CGFloat width = (CGFloat)self.view.frame.size.width / (CGFloat)_controllerArray.count;
            CGFloat height = _menuHeight;
            menuItemFrame = CGRectMake(x, y, width, height);
        } else if (_menuItemWidthBasedOnTitleTextWidth) { // 菜单项宽基于标题宽度设置
            
            NSString *controllerTitle = controller.title;
            // 默认标题是 @"Menu %.0f"
            NSString *titleText = controllerTitle != nil ? controllerTitle : [NSString stringWithFormat:@"Menu %.0f", index + 1];
            // 菜单项宽度自适应标题宽度
            CGRect itemWidthRect = [titleText boundingRectWithSize:CGSizeMake(1000, 1000)
                                                           options: NSStringDrawingUsesLineFragmentOrigin
                                                        attributes: @{NSFontAttributeName:_menuItemFont}
                                                           context: nil];
            
            _menuItemWidth = itemWidthRect.size.width;
            CGFloat x = _totalMenuItemWidthIfDifferentWidths + _menuMargin + (_menuMargin * index);
            CGFloat y = 0.0;
            menuItemFrame = CGRectMake(x, y, _menuItemWidth, _menuHeight);
            
            _totalMenuItemWidthIfDifferentWidths += itemWidthRect.size.width;
            [_mutableMenuItemWidths addObject:@(itemWidthRect.size.width)];
        } else { // 其他类型
            
            if (_centerMenuItems && index == 0.0) { // 首个菜单项设置
                // 设置保护留白
                _startingMenuMargin = ((self.view.frame.size.width - (((CGFloat)_controllerArray.count * _menuItemWidth) + (CGFloat)(_controllerArray.count - 1) * _menuMargin)) / 2.0) -  _menuMargin;
                
                if (_startingMenuMargin < 0.0) {
                    _startingMenuMargin = 0.0;
                }
                menuItemFrame = CGRectMake(_startingMenuMargin + _menuMargin, 0.0, _menuItemWidth, _menuHeight);
            } else {
                menuItemFrame = CGRectMake(_menuItemWidth * index + _menuMargin * (index + 1) + _startingMenuMargin, 0.0, _menuItemWidth, _menuHeight);
            }
        }
        
        // 创建菜单项视图
        MenuItemView *menuItemView = [[MenuItemView alloc] initWithFrame:menuItemFrame];
        if (_useMenuLikeSegmentedControl) {
            [menuItemView setUpMenuItemView:(CGFloat)self.view.frame.size.width / (CGFloat)_controllerArray.count
                       menuScrollViewHeight:_menuHeight
                            indicatorHeight:_selectionIndicatorHeight
                  separatorPercentageHeight:_menuItemSeparatorPercentageHeight
                             separatorWidth:_menuItemSeparatorWidth
                        separatorRoundEdges:_menuItemSeparatorRoundEdges
                     menuItemSeparatorColor:_menuItemSeparatorColor];
            
        } else {
            [menuItemView setUpMenuItemView:_menuItemWidth
                       menuScrollViewHeight:_menuHeight
                            indicatorHeight:_selectionIndicatorHeight
                  separatorPercentageHeight:_menuItemSeparatorPercentageHeight
                             separatorWidth:_menuItemSeparatorWidth
                        separatorRoundEdges:_menuItemSeparatorRoundEdges
                     menuItemSeparatorColor:_menuItemSeparatorColor];
        }
        
        // 如果用户设置了菜单项的标题字体,则重新配置下字体相关
        menuItemView.titleLabel.font = _menuItemFont;
        menuItemView.titleLabel.textAlignment = NSTextAlignmentCenter;
        menuItemView.titleLabel.textColor = _unselectedMenuItemLabelColor;
        
        // 配置菜单项标题,默认@"Menu %.0f"
        if (controller.title != nil) {
            [menuItemView setTitleText:controller.title];
        } else {
            [menuItemView setTitleText:[NSString stringWithFormat:@"Menu %.0f",index + 1]];
        }
        
        // 当使用分段控制器模式时候,将菜单项直接的分离器显示出来
        if (_useMenuLikeSegmentedControl) {
            if ((NSInteger)index < _controllerArray.count - 1) {
                menuItemView.menuItemSeparator.hidden = NO;
            }
        }
        
        
        [_menuScrollView addSubview:menuItemView];  // 将菜单项添加到父视图中
        [_mutableMenuItems addObject:menuItemView]; // 将菜单项添加到菜单项数组中
        
        index++;
    }
    
    // 如果是根据标题宽度来设置菜单项宽度,则此处需要重新配置菜单栏的contentSize
    if (_menuItemWidthBasedOnTitleTextWidth) {
        _menuScrollView.contentSize = CGSizeMake((_totalMenuItemWidthIfDifferentWidths + _menuMargin) + (CGFloat)_controllerArray.count * _menuMargin, _menuHeight);
    }
    
    
    // 配置选中菜单项的标题颜色
    if (_mutableMenuItems.count > 0 && [_mutableMenuItems[_currentPageIndex] titleLabel] != nil) {
        [_mutableMenuItems[_currentPageIndex] titleLabel].textColor = _selectedMenuItemLabelColor;
    }
    
    //=====================
    // 配置指示器
    //=====================
    CGRect selectionIndicatorFrame;
    
    // 此处默认是第一个菜单项下面显示
    if (_useMenuLikeSegmentedControl) {
        selectionIndicatorFrame = CGRectMake(0.0, _menuHeight - _selectionIndicatorHeight, self.view.frame.size.width / (CGFloat)_controllerArray.count, _selectionIndicatorHeight);
    } else if (_menuItemWidthBasedOnTitleTextWidth) {
        selectionIndicatorFrame = CGRectMake(_menuMargin, _menuHeight - _selectionIndicatorHeight, [_mutableMenuItemWidths[0] floatValue], _selectionIndicatorHeight);
    } else {
        if (_centerMenuItems) {
            selectionIndicatorFrame = CGRectMake(_startingMenuMargin + _menuMargin, _menuHeight - _selectionIndicatorHeight, _menuItemWidth, _selectionIndicatorHeight);
        } else {
            selectionIndicatorFrame = CGRectMake(_menuMargin, _menuHeight - _selectionIndicatorHeight, _menuItemWidth, _selectionIndicatorHeight);
        }
    }
    
    _selectionIndicatorView = [[UIView alloc] initWithFrame:selectionIndicatorFrame];
    _selectionIndicatorView.backgroundColor = _selectionIndicatorColor;
    [_menuScrollView addSubview:_selectionIndicatorView];
}



#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*
     产生滑动的情况分2种:
     1.通过点击菜单项发生翻页滑动didTapMenuItemToScroll = YES
     2.通过滑动 controllerScrollView 来翻页滑动, didTapMenuItemToScroll = NO
     
     ==============================================================================================
     代码分析,此处判断较多,情况较复杂.总结大体判断情况:
     1.旋转后不需要刷新子视图
     1.1滑动视图为 controllerScrollView
     1.1.1视图的滑动没有超过父视图
     1.1.1.1屏幕方向改变和当前方向设置是否一致
     1.1.1.1.1点击菜单项不会触发滑动
     1.1.1.1.1.1已经滑动完了
     1.1.1.1.1.2滑动还没有完成
     1.1.1.1.2公共部分
     1.1.2视图的滑动超过的父视图
     
     2.旋转后要刷新子视图
     
     ==============================================================================================
     思路整理:
     一共有3个地方会将即将出现的子视图展示出来.
     1.controllerScrollView滑动翻页,开始滑动时候,会加载出马上要出现的视图
     2.controllerScrollView滑动翻页,已经开始滑动了,如果和上次滑动方向不一致,则加载新的视图
     3.公共部分,当前页面下标改变,加载当前页面下标视图;
     如果是 controllerScrollView 方式翻页,就把旧的页面加入页面,同时确保只有最多3个界面会占用内存
     总体:将即将出现的视图加载,将过去的视图移除,总体只保证出来2个视图
     */
    
#warning _didLayoutSubviewsAfterRotation初始值是NO,只有后面旋转后重新布局设置为了YES,然后在本方法中重新设置为NO,目前作用未找到
    if (!_didLayoutSubviewsAfterRotation) { // 旋转后不刷新子视图布局
        if ([scrollView isEqual:_controllerScrollView]) { // 滚动的是 controllerScrollView 视图,此框架设计是滑动菜单不会使页面跟着滑动,所以只需要考虑controllerScrollView的滑动情况
            
            //========================================================================================
            // controllerScrollView的滑动没有超过父视图
            // 原因:
            // (1)
            // didTapMenuItemToScroll = NO情况下,即controllerScrollView 滑动翻页时
            // 即将出现的 index 会是 _currentPageIndex - 1 或者_currentPageIndex + 1
            // 这种情况会越 _controllerArray 的界
            //
            // (2)
            // 超过父视图的滑动不会有视图控制器被加载出来,只需要指示器有相应的滑动就可以了
            //========================================================================================
            BOOL scrollerViewIsScrollOnSupView = scrollView.contentOffset.x >= 0.0 &&
            scrollView.contentOffset.x <= _controllerScrollView.contentSize.width;
            if (scrollerViewIsScrollOnSupView) {
                // 获取界面显示方向
                UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
                if ((_currentOrientationIsPortrait && UIInterfaceOrientationIsPortrait(orientation)) || (!_currentOrientationIsPortrait && UIInterfaceOrientationIsLandscape(orientation))){ //屏幕方向改变和当前方向设置是否一致
                    
                    //=========================================================
                    // 这个if是在只有在使用 controllerScrollView 滑动翻页时候才会调用
                    // 分为'在滑动'和'没有滑动'
                    // 这部分是为了将即将出现的页面加载出来
                    //=========================================================
                    if (!_didTapMenuItemToScroll) {
                        
                        //==============================================================================================
                        // 在滑动
                        // didScrollAlready初始值为NO,在开始滑动时会设置为YES
                        // startingPageForScroll初始值为0,此处是根据这个属性计算出本段滑动开始时候的偏移量,再根据初始偏移量判断滑动方向
                        // 因为开始滑动的时候,已经将即将出现的视图加载过了,在本段滑动中只有改变滑动方向才会再次加载新的界面
                        //==============================================================================================
                        if (_didScrollAlready) {
                            CAPSPageMenuScrollDirection newScrollDirection  = CAPSPageMenuScrollDirectionOther;
                            
                            // 判断滚动完的滑动方向
                            if ((CGFloat)_startingPageForScroll * scrollView.frame.size.width > scrollView.contentOffset.x) {
                                newScrollDirection = CAPSPageMenuScrollDirectionRight;
                            } else if ((CGFloat)_startingPageForScroll * scrollView.frame.size.width < scrollView.contentOffset.x) {
                                newScrollDirection = CAPSPageMenuScrollDirectionLeft;
                            }
                            
                            if (newScrollDirection != CAPSPageMenuScrollDirectionOther) { // 本段滑动中滑动方向改变了
                                if (_lastScrollDirection != newScrollDirection) {
                                    NSInteger index = newScrollDirection == CAPSPageMenuScrollDirectionLeft ? _currentPageIndex + 1 : _currentPageIndex - 1;
                                    
                                    if (index >= 0 && index < _controllerArray.count ){ // 确保index没有越界,滑动是在父视图范围内发生的
                                        // 检查字典,查看该下标是否已经被加载过了,如果没有则加载该子视图控制器
                                        if (![_pagesAddedSet containsObject:@(index)]) {
                                            [self addPageAtIndex:index];
                                            [_pagesAddedSet addObject:@(index)];
                                            NSLog(@"在滑动 -> 方向不同");
                                        }
                                    }
                                }
                            }
                            
                            // 更新最新滑动方向
                            _lastScrollDirection = newScrollDirection;
                        }
                        
                        //=============================================================================
                        // 没有滑动,此处意味着将要滑动,即开始滑动,调用后会设置_didScrollAlready = YES,表示在滑动
                        // lastControllerScrollViewContentOffset默认值0.0,此处是根据这个属性判断开始滑动的方向
                        // 开始滑动就会将即将出现的视图加载出来
                        // 这里将
                        //=============================================================================
                        if (!_didScrollAlready) {
                            
                            // 发生了右滑
                            if (_lastControllerScrollViewContentOffset > scrollView.contentOffset.x) {
                                if (_currentPageIndex != _controllerArray.count - 1 ){ // currentPageIndex不是最后一页
                                    
                                    // 将currentPageIndex的左页添加到出来(即将出现的左页面)
                                    NSInteger index = _currentPageIndex - 1;
                                    if (![_pagesAddedSet containsObject:@(index)] && index < _controllerArray.count && index >= 0) {
                                        [self addPageAtIndex:index];
                                        [_pagesAddedSet addObject:@(index)];
                                        NSLog(@"开始右滑动 -> 不是最后一个");
                                    }
                                    
                                    _lastScrollDirection = CAPSPageMenuScrollDirectionRight;
                                }
                                
                                // 发生了左滑
                            } else if (_lastControllerScrollViewContentOffset < scrollView.contentOffset.x) {
                                if (_currentPageIndex != 0) { // currentPageIndex不是首页
                                    
                                    // 将currentPageIndex的右页添加到出来
                                    NSInteger index = _currentPageIndex + 1;
                                    if (![_pagesAddedSet containsObject:@(index)] && index < _controllerArray.count && index >= 0) {
                                        [self addPageAtIndex:index];
                                        [_pagesAddedSet addObject:@(index)];
                                        NSLog(@"开始左滑动 -> 不是第一个");
                                    }
                                    
                                    _lastScrollDirection = CAPSPageMenuScrollDirectionLeft;
                                }
                            }
                            
                            // 开始滑动了
                            _didScrollAlready = YES;
                        }
                        
                        // 更新最新视图控制器视图位移位置
                        _lastControllerScrollViewContentOffset = scrollView.contentOffset.x;
                    }
                    
                    //============================================================
                    // 这部分是是公共部分
                    // 作用:在滑动了controllerScrollView后,使menuScrollView做对应的滑动
                    //============================================================
                    
                    CGFloat ratio = 1.0;
                    
                    // 以2个滚动视图最大偏移量生成比例 menuScrollView/controllerScrollView,2个滚动视图移动的比例
                    ratio = (_menuScrollView.contentSize.width - self.view.frame.size.width) / (_controllerScrollView.contentSize.width - self.view.frame.size.width);
                    
                    // 菜单项根据controllerScrollView滚动情况一起移动相应距离
                    if (_menuScrollView.contentSize.width > self.view.frame.size.width ){
                        CGPoint offset  = _menuScrollView.contentOffset;
                        offset.x = _controllerScrollView.contentOffset.x * ratio;
                        [_menuScrollView setContentOffset:offset animated: NO];
                    }
                    
                    //=========================================================
                    // 这部分也是公共部分
                    // 作用:将即将出现的视图控制器加载出来
                    // 如果在 didTapMenuItemToScroll = NO 状态下加载过了,则不会加载
                    //=========================================================
                    
                    // 计算当前下标页
                    CGFloat width = _controllerScrollView.frame.size.width;
                    NSInteger page = (NSInteger)(_controllerScrollView.contentOffset.x + (0.5 * width)) / width;
                    
                    // 如果页面改变了
                    if (page != _currentPageIndex) {
                        // 更新页面下标
                        _lastPageIndex = _currentPageIndex;
                        _currentPageIndex = page;
                        
                        // 将即将出现的子视图控制器添加到父视图控制器上
                        if (![_pagesAddedSet containsObject:@(page)] && page < _controllerArray.count && page >= 0){
                            [self addPageAtIndex:page];
                            [_pagesAddedSet addObject:@(page)];
                            NSLog(@"公用 -> 新页面");
                            
                        }
                        
                        // 点击菜单项不会发生滑动,即滑动controllerScrollView方式翻页
                        if (!_didTapMenuItemToScroll) {
                            // 将旧的下标页添加进字典,等滑动结束后,根据情况进行移除
                            if (![_pagesAddedSet containsObject:@(_lastPageIndex)]) {
                                [_pagesAddedSet addObject:@(_lastPageIndex)];
                            }
                            
                            //=======================================================
                            // 在快速滚动时，确保只有3个页面视图在内存中，否则在内存中应该只有一个
                            // 在不停的滑动时候清除内存,保证只有3个界面
                            //=======================================================
                            NSInteger indexLeftTwo = page - 2;
                            if ([_pagesAddedSet containsObject:@(indexLeftTwo)]) {
                                
                                [_pagesAddedSet removeObject:@(indexLeftTwo)];
                                
                                [self removePageAtIndex:indexLeftTwo];
                            }
                            NSInteger indexRightTwo = page + 2;
                            if ([_pagesAddedSet containsObject:@(indexRightTwo)]) {
                                
                                [_pagesAddedSet removeObject:@(indexRightTwo)];
                                
                                [self removePageAtIndex:indexRightTwo];
                            }
                        }
                    }
                    
                    // 在滑动时移动选择指示器视图
                    [self moveSelectionIndicator:page];
                }
            } else {
                //=========================================================================
                // controllerScrollView滑动超过父视图了,则menuScrollView会出现微小的等比例左右移动
                //=========================================================================
                
                // 将超过2个视图能够滑动的最大偏移量作为缩放比例,为了等比移动距离的比例
                CGFloat ratio = 1.0;
                ratio = (_menuScrollView.contentSize.width - self.view.frame.size.width) / (_controllerScrollView.contentSize.width - self.view.frame.size.width);
                
                // 如果menuScrollView的contentSize能够超过父视图,则做想要的小幅度滑动
                if (_menuScrollView.contentSize.width > self.view.frame.size.width) {
                    CGPoint offset = self.menuScrollView.contentOffset;
                    offset.x = _controllerScrollView.contentOffset.x * ratio;
                    [self.menuScrollView setContentOffset:offset animated:NO];
                }
            }
        }
    } else {
        _didLayoutSubviewsAfterRotation = NO;
        
        // 在滑动时移动选择指示器视图
        [self moveSelectionIndicator:self.currentPageIndex];
    }
}


/**
 滚动视图结束滑动减速
 
 @param scrollView 相应的滚动视图
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:_controllerScrollView]) {
        // 调用didMoveToPage的代理方法
        UIViewController *currentController = _controllerArray[_currentPageIndex];
        if ([_delegate respondsToSelector:@selector(didMoveToPage:index:)]) {
            [_delegate didMoveToPage:currentController index:_currentPageIndex];
        }
        
        // 在减速后,除了当前页下标对应的视图,其他视图都删除
        for (NSNumber *num in _pagesAddedSet) {
            if (![num isEqualToNumber:@(self.currentPageIndex)]) {
                [self removePageAtIndex:num.integerValue];
            }
        }
        
        _didScrollAlready = NO;
        _startingPageForScroll = _currentPageIndex;
        
        // 清空下标页数组
        [_pagesAddedSet removeAllObjects];
    }
}


/**
 滚动视图结束点击菜单项发生滚动的动画
 其实此处和 - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView 方法效果等同
 单独处理是因为点击选中菜单项,带动controllerScrollView视图发生滚动,但是不会触发减速停止的方法
 */
- (void)scrollViewDidEndTapScrollingAnimation
{
    // 调用didMoveToPage的代理方法
    UIViewController *currentController = _controllerArray[_currentPageIndex];
    if ([_delegate respondsToSelector:@selector(didMoveToPage:index:)]) {
        [_delegate didMoveToPage:currentController index:_currentPageIndex];
    }
    
    // 在减速后,除了当前页下标对应的视图,其他视图都删除
    for (NSNumber *num in _pagesAddedSet) {
        if (![num isEqualToNumber:@(self.currentPageIndex)]) {
            [self removePageAtIndex:num.integerValue];
        }
    }
    
    _startingPageForScroll = _currentPageIndex;
    _didTapMenuItemToScroll = NO;
    
    // 清空下标页数组
    [_pagesAddedSet removeAllObjects];
}


// MARK: - 操作指示器

/*
 主要做了:
 1.修改指示器的frame
 2.修改菜单项标题label颜色
 */
- (void)moveSelectionIndicator:(NSInteger)pageIndex
{
    // 该下标页没有越界
    if (pageIndex >= 0 && pageIndex < _controllerArray.count) {
        [UIView animateWithDuration:0.15 animations:^{
            
            CGFloat selectionIndicatorWidth = self.selectionIndicatorView.frame.size.width;
            CGFloat selectionIndicatorX = 0.0;
            
            // 此处设置的位置其实就是被选中的菜单项位置,并且和选中菜单项等宽
            if (self.useMenuLikeSegmentedControl) {
                selectionIndicatorX = (CGFloat)pageIndex * (self.view.frame.size.width / (CGFloat)self.controllerArray.count);
                selectionIndicatorWidth = self.view.frame.size.width / (CGFloat)self.controllerArray.count;
            } else if (self.menuItemWidthBasedOnTitleTextWidth) {
                selectionIndicatorWidth = [self.menuItemWidths[pageIndex] floatValue];
                selectionIndicatorX += self.menuMargin;
                
                // 因为菜单项不等宽,所有for循环累加宽度
                if (pageIndex > 0) {
                    for (NSInteger i=0; i<pageIndex; i++) {
                        selectionIndicatorX += (self.menuMargin + [self.menuItemWidths[i] floatValue]);
                    }
                }
            } else {
                if (self.centerMenuItems && pageIndex == 0) {
                    // 中心对称
                    selectionIndicatorX = self.startingMenuMargin + self.menuMargin;
                } else {
                    // 此处如果是centerMenuItems = NO,则startingMenuMargin = 0
                    selectionIndicatorX = self.menuItemWidth * (CGFloat)pageIndex + self.menuMargin * (CGFloat)(pageIndex + 1) + self.startingMenuMargin;
                }
            }
            
            self.selectionIndicatorView.frame = CGRectMake(selectionIndicatorX, self.selectionIndicatorView.frame.origin.y, selectionIndicatorWidth, self.selectionIndicatorView.frame.size.height);
            
            // 将新选中的菜单项的标题色修改为选中色,旧的选中菜单项颜色修改为未选中色
            if (self.menuItems.count > 0) {
                if ([self.menuItems[self.lastPageIndex] titleLabel] != nil && [self.menuItems[self.currentPageIndex] titleLabel] != nil) {
                    [self.menuItems[self.lastPageIndex] titleLabel].textColor = self.unselectedMenuItemLabelColor;
                    [self.menuItems[self.currentPageIndex] titleLabel].textColor = self.selectedMenuItemLabelColor;
                }
            }
        }];
    }
}


// MARK: - 点击菜单项手势

- (void)handleMenuItemTap:(UITapGestureRecognizer *)gestureRecognizer
{
    // 获取手势位置
    CGPoint tappedPoint = [gestureRecognizer locationInView:_menuScrollView];
    
    // 确认手势位置是在菜单上
    if (tappedPoint.y < self.menuScrollView.frame.size.height) {
        
        // 计算点击的第几页
        NSInteger itemIndex = 0;
        
        if (_useMenuLikeSegmentedControl) { // 类似分段控制器格式
            
            // 应为首个menuItem的index是0
            itemIndex = (NSInteger) (tappedPoint.x / (self.view.frame.size.width / (CGFloat)_controllerArray.count));
        } else if (_menuItemWidthBasedOnTitleTextWidth) { // 菜单项的宽基于文本宽度
            
            // 菜单项的左边界
            // 将左侧留白算入第一个菜单项点击范围,所以第一个菜单项的左边界为0.0,因为包括了左留白
            CGFloat menuItemLeftBound = 0.0;
            // 菜单项的右边界
            // 菜单项间的留白,与之相邻的菜单项占1/2
            // 此处的计算里多了一个留白距离是因为第一个菜单项点击范围还包括左留白
            CGFloat menuItemRightBound = [_mutableMenuItemWidths[0] floatValue] + _menuMargin + (_menuMargin / 2);
            
            // 点击第一个菜单项之外的其他菜单项
            if (!(tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound)) {
                for (NSInteger i = 1; i<=_controllerArray.count - 1; i++) {
                    // 本来整个菜单都是点击位置,此处menuItemLeftBound应该为上一个menuItem的menuItemRightBound
                    // + 1.0是为了区分,避免点击分界线的时候认为点击了2个菜单项
                    menuItemLeftBound = menuItemRightBound + 1.0;
                    menuItemRightBound = menuItemLeftBound + [_mutableMenuItemWidths[i] floatValue] + _menuMargin;
                    
                    if (tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound) {
                        itemIndex = i;
                        break;
                    }
                }
            }
        } else {
            CGFloat rawItemIndex = ((tappedPoint.x - _startingMenuMargin) - _menuMargin / 2) / (_menuMargin + _menuItemWidth);
            
#warning rowItemIndex作用不明
            // Prevent moving to first item when tapping left to first item
            if (rawItemIndex < 0) {
                itemIndex = -1;
            } else {
                itemIndex = (NSInteger)rawItemIndex;
            }
        }
        
        // 确保itemIndex没有越界
        if (itemIndex >= 0 && itemIndex < _controllerArray.count) {
            // 如果当前页发生变化着更新
            if (itemIndex != _currentPageIndex) {
                _startingPageForScroll = itemIndex; // 为下段滑动提供起始偏移量
                _lastPageIndex = _currentPageIndex; // 旧的也下标
                _currentPageIndex = itemIndex;      // 当前也下标
                _didTapMenuItemToScroll = YES;      // 确定是点击菜单项发生的滑动
                
                // 如果需要,在当前页和点击页之间添加页面
                // 通俗易懂就是当前页可能为1,但是点击的可能是4,从index为1滑动4,中间会出现2和3,这里说的添加的页面就是2和3
                NSInteger smallerIndex = _lastPageIndex < _currentPageIndex ? _lastPageIndex : _currentPageIndex;
                NSInteger largerIndex = _lastPageIndex > _currentPageIndex ? _lastPageIndex : _currentPageIndex;
                
                if (smallerIndex + 1 != largerIndex) { // 确保2个页面中间还有页面
                    for (NSInteger i=smallerIndex + 1; i< largerIndex; i++) {
                        
                        // 将会出现的页面加载出来
                        if (![_pagesAddedSet containsObject:@(i)]) {
                            [self addPageAtIndex:i];
                            [_pagesAddedSet addObject:@(i)];
                        }
                    }
                }
                
                // 过度中间页面加完了再添加最终会显示的页面
                [self addPageAtIndex:itemIndex];
                
                // 点击完成了,点击页面也加出来了,旧的页面添加进页面字典,方便动画完成后删除
                [_pagesAddedSet addObject:@(_lastPageIndex)];
                
            }
            
            // 点击菜单项,controllerScrollView发生滚动的时间
            double duration = _scrollAnimationDurationOnMenuItemTap / 1000.0;
            
            [UIView animateWithDuration:duration animations:^{
                CGFloat xOffset = (CGFloat)itemIndex * _controllerScrollView.frame.size.width;
                [_controllerScrollView setContentOffset:CGPointMake(xOffset, _controllerScrollView.contentOffset.y)];
            }];
            
#warning 不知道为什么用计时器,此处计时器不会重复调用动画停止的方法,所以不知道为什么不直接调用动画结束方法,而是要用计时器来调用
            if (_tapTimer != nil) {
                [_tapTimer invalidate];
            }
            
            NSTimeInterval timerInterval = (double)_scrollAnimationDurationOnMenuItemTap * 0.001;
            _tapTimer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(scrollViewDidEndTapScrollingAnimation) userInfo:nil repeats:NO];
        }
    }
}

// MARK: - Remove/Add Page


/**
 在该下标下添加页面
 
 @param index 该下标
 */
- (void)addPageAtIndex:(NSInteger)index
{
    // 调用 didMoveToPage 代理方法
    UIViewController *currentController = _controllerArray[index];
    if ([_delegate respondsToSelector:@selector(willMoveToPage:index:)]) {
        [_delegate willMoveToPage:currentController index:index];
    }
    
    UIViewController *newVC = _controllerArray[index];
    
    // 将该下标对应的视图控制器准备加载到父视图下
    [newVC willMoveToParentViewController:self];
    
    // 设置该下标对应的视图控制器的视图位置
    newVC.view.frame = CGRectMake(self.view.frame.size.width * (CGFloat)index, _menuHeight, self.view.frame.size.width, self.view.frame.size.height - _menuHeight);
    
    [self addChildViewController:newVC];           // 将该下标对应的视图控制器添加为子视图控制器
    [_controllerScrollView addSubview:newVC.view]; // 将该下标对应的视图控制器的视图添加到 controllerScrollView 上
    [newVC didMoveToParentViewController:self];    // 将该下标对应的视图控制器加载到父视图控制器上
}


/**
 在该下标下删除页面
 
 @param index 该页面
 */
- (void)removePageAtIndex:(NSInteger)index
{
    UIViewController *oldVC = _controllerArray[index];
    
    [oldVC willMoveToParentViewController:nil];
    
    [oldVC.view removeFromSuperview];
    [oldVC removeFromParentViewController];
    
    [oldVC didMoveToParentViewController:nil];
}


// MARK: - 发生了旋转改变

- (void)viewDidLayoutSubviews
{
#warning 源码bug,横屏后再竖屏,_centerMenuItems模式下，index下标为1的menuItemView的frame不正确已改正
    // 配置_controllerScrollView的contenSize
    _controllerScrollView.contentSize = CGSizeMake(self.view.frame.size.width * (CGFloat)_controllerArray.count, self.view.frame.size.height - _menuHeight);
    
    // 标记旧的屏幕方向是否为竖屏
    BOOL oldCurrentOrientationIsPortrait = _currentOrientationIsPortrait;
    
    // 当前屏幕方向
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    _currentOrientationIsPortrait = UIInterfaceOrientationIsPortrait(orientation);
    
    // 确保一致性,都是竖屏或者都是横屏
    if ((oldCurrentOrientationIsPortrait && UIInterfaceOrientationIsLandscape(orientation)) || (!oldCurrentOrientationIsPortrait && UIInterfaceOrientationIsPortrait(orientation))){
        _didLayoutSubviewsAfterRotation = YES;
        
        //重新设置菜单项相关
        if (_useMenuLikeSegmentedControl) { // 分段控制器模式
            _menuScrollView.contentSize = CGSizeMake(self.view.frame.size.width, _menuHeight);
            
            // 重新配置指示器的位置
            CGFloat selectionIndicatorX = (CGFloat)_currentPageIndex * (self.view.frame.size.width / (CGFloat)_controllerArray.count);
            CGFloat selectionIndicatorWidth = self.view.frame.size.width / (CGFloat)_controllerArray.count;
            _selectionIndicatorView.frame =  CGRectMake(selectionIndicatorX, self.selectionIndicatorView.frame.origin.y, selectionIndicatorWidth, self.selectionIndicatorView.frame.size.height);
            
            // 重新计算下标，设置MenuItemView，titleLabel，menuItemSeparator位置
            NSInteger index = 0;
            
            for (MenuItemView *item in _mutableMenuItems) {
                item.frame = CGRectMake(self.view.frame.size.width / (CGFloat)_controllerArray.count * (CGFloat)index, 0.0, self.view.frame.size.width / (CGFloat)_controllerArray.count, _menuHeight);
                if (item.titleLabel) {
                    item.titleLabel.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width / (CGFloat)_controllerArray.count, _menuHeight);
                }
                if (item.menuItemSeparator){
                    item.menuItemSeparator.frame = CGRectMake(item.frame.size.width - (_menuItemSeparatorWidth / 2), item.menuItemSeparator.frame.origin.y, item.menuItemSeparator.frame.size.width, item.menuItemSeparator.frame.size.height);
                }
                
                index++;
            }
        } else if (_centerMenuItems) { // 菜单项居中
            // 获取左右初留白
            _startingMenuMargin = ((self.view.frame.size.width - (((CGFloat)_controllerArray.count * _menuItemWidth) + ((CGFloat)(_controllerArray.count - 1) * _menuMargin))) / 2.0) -  _menuMargin;
            
            if (_startingMenuMargin < 0.0) {
                _startingMenuMargin = 0.0;
            }
            
            // 设置指示器的位置
            CGFloat selectionIndicatorX = self.menuItemWidth * (CGFloat)_currentPageIndex + self.menuMargin * (CGFloat)(_currentPageIndex + 1) + self.startingMenuMargin;
            _selectionIndicatorView.frame =  CGRectMake(selectionIndicatorX, self.selectionIndicatorView.frame.origin.y, self.selectionIndicatorView.frame.size.width, self.selectionIndicatorView.frame.size.height);
            
            // 重新计算MenuItemView位置
            NSInteger index = 0;
            
            for (MenuItemView *item in _mutableMenuItems) {
                if (index == 0) {
                    item.frame = CGRectMake(_startingMenuMargin + _menuMargin, 0.0, _menuItemWidth, _menuHeight);
                } else {
                    item.frame = CGRectMake(_menuItemWidth * (CGFloat)index + _menuMargin * (CGFloat)(index + 1) + 1.0 + _startingMenuMargin, 0.0, _menuItemWidth, _menuHeight);
                }
                
                index++;
            }
        }
        
        // 重新设置视图控制器view的位置
        for (UIView *view in _controllerScrollView.subviews) {
            view.frame = CGRectMake(self.view.frame.size.width * (CGFloat)(_currentPageIndex), _menuHeight, _controllerScrollView.frame.size.width, self.view.frame.size.height - _menuHeight);
        }
        
        CGFloat xOffset = (CGFloat)(self.currentPageIndex) * _controllerScrollView.frame.size.width;
        [_controllerScrollView setContentOffset:CGPointMake(xOffset, _controllerScrollView.contentOffset.y)];
        
        // 计算新的移动比例
        CGFloat ratio = (_menuScrollView.contentSize.width - self.view.frame.size.width) / (_controllerScrollView.contentSize.width - self.view.frame.size.width);
        
        // 计算menuScrollView的位置
        if (_menuScrollView.contentSize.width > self.view.frame.size.width) {
            CGPoint offset = _menuScrollView.contentOffset;
            offset.x = _controllerScrollView.contentOffset.x * ratio;
            [_menuScrollView setContentOffset:offset animated:NO];
        }
    }
    
    // Hsoi 2015-02-05 - Running on iOS 7.1 complained: "'NSInternalInconsistencyException', reason: 'Auto Layout
    // still required after sending -viewDidLayoutSubviews to the view controller. ViewController's implementation
    // needs to send -layoutSubviews to the view to invoke auto layout.'"
    //
    // http://stackoverflow.com/questions/15490140/auto-layout-error
    //
    // Given the SO answer and caveats presented there, we'll call layoutIfNeeded() instead.
    [self.view layoutIfNeeded];
}


// MARK: - Move to page index

/**
 Move to page at index
 
 :param: index Index of the page to move to
 */
- (void)moveToPage:(NSInteger)index
{
    if (index >= 0 && index < _controllerArray.count) {
        // Update page if changed
        if (index != _currentPageIndex) {
            _startingPageForScroll = index;
            _lastPageIndex = _currentPageIndex;
            _currentPageIndex = index;
            _didTapMenuItemToScroll = YES;
            
            // Add pages in between current and tapped page if necessary
            NSInteger smallerIndex = _lastPageIndex < _currentPageIndex ? _lastPageIndex : _currentPageIndex;
            NSInteger largerIndex = _lastPageIndex > _currentPageIndex ? _lastPageIndex : _currentPageIndex;
            
            if (smallerIndex + 1 != largerIndex) {
                for (NSInteger i=smallerIndex + 1; i<largerIndex; i++) {
                    
                    if (![_pagesAddedSet containsObject:@(i)]) {
                        [self addPageAtIndex:i];
                        [_pagesAddedSet addObject:@(i)];
                    }
                }
            }
            [self addPageAtIndex:index];
            
            // Add page from which tap is initiated so it can be removed after tap is done
            [_pagesAddedSet addObject:@(_lastPageIndex)];
        }
        
        // Move controller scroll view when tapping menu item
        double duration = (double)(_scrollAnimationDurationOnMenuItemTap) / (double)(1000);
        
        [UIView animateWithDuration:duration animations:^{
            CGFloat xOffset = (CGFloat)index * self.controllerScrollView.frame.size.width;
            [self.controllerScrollView setContentOffset:CGPointMake(xOffset, self.controllerScrollView.contentOffset.y) animated:NO];
        }];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}


// MARK: Getter
- (NSArray *)menuItems
{
    return _mutableMenuItems;
}

- (NSArray *)menuItemWidths
{
    return _mutableMenuItemWidths;
}

@end
