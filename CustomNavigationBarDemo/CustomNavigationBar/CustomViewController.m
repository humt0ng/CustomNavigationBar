//
//  CustomViewController.m
//  CustomNavigationBarDemo
//
//  Created by jimple on 14-1-6.
//  Copyright (c) 2014年 Jimple Chen. All rights reserved.
//

#import "CustomViewController.h"
#import "CustomNaviBarView.h"
#import "CustomNavigationController.h"

@interface CustomViewController ()

@property (nonatomic, readonly) CustomNaviBarView *m_viewNaviBar;

@end

@implementation CustomViewController
@synthesize m_viewNaviBar = _viewNaviBar;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.wantsFullScreenLayout = YES;
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.wantsFullScreenLayout = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _viewNaviBar = [[CustomNaviBarView alloc] initWithFrame:Rect(0.0f, 0.0f, [CustomNaviBarView barSize].width, [CustomNaviBarView barSize].height)];
    _viewNaviBar.m_viewCtrlParent = self;
    [self.view addSubview:_viewNaviBar];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[[UIImage imageNamed:@"GlobalBg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [UtilityFunc cancelPerformRequestAndNotification:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_viewNaviBar && !_viewNaviBar.hidden)
    {
        [self.view bringSubviewToFront:_viewNaviBar];
    }else{}
    
    [self compatibleLayoutSubView:self.view];
}

/**
 *	@brief	在viewWillAppear中调用。 加入导航条后会使所有view的位置都出错，此方法可以统一调整所有子view的位置及高度
 */
#define TEST_AUTO_ADJUST 0
- (void)compatibleLayoutSubView:(UIView*)superview {
    if (!superview) {
        NSAssert(0, nil);
        return;
    }

    CGFloat navH = [CustomNaviBarView barSize].height;
    CGFloat viewH = superview.frame.size.height;

#if TEST_AUTO_ADJUST
    const NSString* k_o = @"orgrect";
    const NSString* k_c = @"correct_results";
    const int _TM = UIViewAutoresizingFlexibleTopMargin;
    const int _BM = UIViewAutoresizingFlexibleBottomMargin;
    const int _H = UIViewAutoresizingFlexibleHeight;

    //assuming that is 64px hegiht navigationbar add into superview, subview need adujst
    NSDictionary* test_map = @{
                            NUM_INT(_TM|_BM|_H):@{k_o:VAL_RECT(Rect(0,50,280,336)),k_c:VAL_RECT(Rect(0,108,280,298))},

                            NUM_INT(_TM|_BM):@{k_o:VAL_RECT(Rect(0,50,280,336)),k_c:VAL_RECT(Rect(0,100,280,336))},

                            NUM_INT(_TM|_H):@{k_o:VAL_RECT(Rect(0,50,280,336)),k_c:VAL_RECT(Rect(0,106,280,280))},

                            NUM_INT(_TM):@{k_o:VAL_RECT(Rect(0,50,280,336)),k_c:VAL_RECT(Rect(0,50,280,336))},

                            NUM_INT(_BM|_H):@{k_o:VAL_RECT(Rect(0,50,280,336)),k_c:VAL_RECT(Rect(0,114,280,294))},

                            NUM_INT(_BM):@{k_o:VAL_RECT(Rect(0,50,280,336)),k_c:VAL_RECT(Rect(0,114,280,336))},

                            NUM_INT(_H):@{k_o:VAL_RECT(Rect(0,50,280,336)),k_c:VAL_RECT(Rect(0,114,280,272))},

                            NUM_INT(0):@{k_o:VAL_RECT(Rect(0,50,280,336)),k_c:VAL_RECT(Rect(0,114,280,336))},
                         };

    superview = [[UIView alloc] initWithFrame:Rect(0, 0, 320, 568)];
    [test_map enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        UIView* subView = [[UIView alloc] init];
        subView.autoresizingMask = [key intValue];
        subView.frame = [obj[k_o] CGRectValue];
        [superview addSubview:subView];
    }];

#endif

    for (UIView* subView in superview.subviews) {
        if (subView == _viewNaviBar) {
            continue;
        }

        CGFloat y = subView.frame.origin.y;
        CGFloat h = subView.frame.size.height;

        UIViewAutoresizing mask = subView.autoresizingMask;
        BOOL isFlexTop      = (mask & UIViewAutoresizingFlexibleTopMargin);
        BOOL isFlexBottom   = (mask & UIViewAutoresizingFlexibleBottomMargin);
        BOOL isFlexHeight   = (mask & UIViewAutoresizingFlexibleHeight);

        if (isFlexBottom && isFlexTop) {
            if (isFlexHeight) {
                CGFloat rate = SAFE_DIVISION(viewH - navH, viewH);
                y = y * rate;
                h = h * rate;
            }
            else {
                y -= navH * SAFE_DIVISION(y, viewH - h);
            }
        }
        else if (isFlexBottom) {
            if (isFlexHeight) {
                h = h * SAFE_DIVISION(viewH - navH - y, viewH - y);
            }
            else {

            }
        }
        else if (isFlexTop) {
            if (isFlexHeight) {
                CGFloat rate = SAFE_DIVISION(y + h - navH, y + h);
                h = h * rate;
                y = y * rate;
            }
            else {
                y -= navH;
            }
        }
        else {
            if (isFlexHeight) {
                h -= navH;
            }
            else {

            }
        }
        
        y+= navH;

        if (h < 0) {
            h = 0;
        }

        CGRect rc = subView.frame;
        rc.origin.y = round(y);
        rc.size.height = round(h);
        subView.frame = rc;
#if TEST_AUTO_ADJUST
        CGRect rcResult = [test_map[NUM_INT(subView.autoresizingMask)][k_c] CGRectValue];
        if (!CGRectEqualToRect(rcResult, subView.frame)) {
            NSLog(@"view:%@ map:%@",subView,test_map[NUM_INT(subView.autoresizingMask)]);
        }
#endif
    }
}

#pragma mark -

- (void)bringNaviBarToTopmost
{
    if (_viewNaviBar)
    {
        [self.view bringSubviewToFront:_viewNaviBar];
    }else{}
}

- (void)hideNaviBar:(BOOL)bIsHide
{
    _viewNaviBar.hidden = bIsHide;
}

- (void)setNaviBarTitle:(NSString *)strTitle
{
    if (_viewNaviBar)
    {
        [_viewNaviBar setTitle:strTitle];
    }else{APP_ASSERT_STOP}
}

- (void)setNaviBarLeftBtn:(UIButton *)btn
{
    if (_viewNaviBar)
    {
        [_viewNaviBar setLeftBtn:btn];
    }else{APP_ASSERT_STOP}
}

- (void)setNaviBarRightBtn:(UIButton *)btn
{
    if (_viewNaviBar)
    {
        [_viewNaviBar setRightBtn:btn];
    }else{APP_ASSERT_STOP}
}

- (void)naviBarAddCoverView:(UIView *)view
{
    if (_viewNaviBar && view)
    {
        [_viewNaviBar showCoverView:view animation:YES];
    }else{}
}

- (void)naviBarAddCoverViewOnTitleView:(UIView *)view
{
    if (_viewNaviBar && view)
    {
        [_viewNaviBar showCoverViewOnTitleView:view];
    }else{}
}

- (void)naviBarRemoveCoverView:(UIView *)view
{
    if (_viewNaviBar)
    {
        [_viewNaviBar hideCoverView:view];
    }else{}
}

// 是否可右滑返回
- (void)navigationCanDragBack:(BOOL)bCanDragBack
{
    if (self.navigationController)
    {
        [((CustomNavigationController *)(self.navigationController)) navigationCanDragBack:bCanDragBack];
    }else{}
}



@end
