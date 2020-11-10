//
//  ViewController.m
//  HBRollingChange
//
//  Created by Mac on 2020/11/10.
//  Copyright © 2020 yanruyu. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#define SCREEN_WIDTH            ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT           ([[UIScreen mainScreen] bounds].size.height)
#define kDevice_Is_iPhoneXScreen  (SCREEN_HEIGHT == 812.0f || SCREEN_HEIGHT == 896.0f)
#define bAllNavTotalHeight (kDevice_Is_iPhoneXScreen ? 88 : 64)
//系统状态栏高度
#define bStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define     HOME_SPACING_LEFT                13
@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic,weak) UIView * customNavView;
@property (nonatomic ,strong)UIView *searchBoxView;
@property (nonatomic ,strong)UIImageView *searchImgView;//搜索img
@property (nonatomic ,strong)UILabel *searchTitleLab;//搜索标题
@property (nonatomic ,strong)UIView *topBackgroundView;
@property (nonatomic ,strong)CAGradientLayer *topGradLayer;
@property (nonatomic, assign) CGFloat lastOffsetY;
@property (nonatomic ,assign)BOOL isRequest;//YES  刷新 NO不刷新
@property (nonatomic ,strong)UIButton *cartBuyBtn;//购物车
@property (nonatomic ,strong)UIButton *signButton;//签到
@property (nonatomic ,strong)UIButton *logoButton;//logo
@property (nonatomic ,strong)UILabel *logoLabel;//标签
@property (nonatomic ,assign)NSInteger selectItemIndex;
@property (nonatomic ,strong)UICollectionViewFlowLayout *fallLayout;
@end

static NSString * const cellID = @"cellID";

@implementation ViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self showNaviWithoffSetY:self.lastOffsetY];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"首页";
    //添加子视图
    [self addHomeSubTabSubView];
}

#pragma mark ==========getter==========
-(void)addHomeSubTabSubView{
    //背景view
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 156+bAllNavTotalHeight)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    self.topBackgroundView = view;
    //设置填充颜色
    CAGradientLayer *gradLayer = [CAGradientLayer layer];
    gradLayer.frame = view.bounds;
    gradLayer.colors = @[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor redColor].CGColor];
    gradLayer.locations = @[@0.0, @1.0];
    gradLayer.startPoint = CGPointMake(0, 0);
    gradLayer.endPoint = CGPointMake(1.0, 0);
    gradLayer.type = kCAGradientLayerAxial;
    [view.layer addSublayer:gradLayer];
    self.topGradLayer = gradLayer;
    //设置弧形
    CGFloat arcLineY = 84+bAllNavTotalHeight;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat radius = width;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, arcLineY)];
    [path addArcWithCenter:CGPointMake(width/2, arcLineY - sin(M_PI/3)*width) radius:radius startAngle:M_PI*2/3.0 endAngle:M_PI*1/3.0 clockwise:NO];
    [path addLineToPoint:CGPointMake(width, 0)];
    [path addLineToPoint:CGPointMake(0, 0)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    gradLayer.mask = shapeLayer;
    //设置导航栏
    UIView *naviView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, bAllNavTotalHeight)];
    naviView.backgroundColor = [UIColor whiteColor];
    self.customNavView = naviView;
    //添加子视图
    [self setupCustomNaviBar];
    [self.view addSubview:self.customNavView];
    //设置搜索view
    UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(15, bAllNavTotalHeight + 15, SCREEN_WIDTH-2*15, 30)];
    searchView.backgroundColor = [UIColor whiteColor];
    searchView.layer.cornerRadius = 15;
//    searchView.layer.borderColor = red_Color.CGColor;
//    searchView.layer.borderWidth = 2;
    searchView.clipsToBounds = YES;
    [self.view addSubview:searchView];
    self.searchBoxView = searchView;
    
    [self.searchBoxView addSubview:self.searchImgView];
    [self.searchImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.searchBoxView).offset(10);
        make.centerY.equalTo(self.searchBoxView);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    //添加searchtitle
    [self.searchBoxView addSubview:self.searchTitleLab];
    [self.searchTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.searchImgView.mas_right).offset(8);
        make.centerY.equalTo(self.searchBoxView);
        make.height.mas_equalTo(13);
    }];
    //设置collectionView
   [self.view addSubview:self.collectionView];
}
#pragma mark ==========导航栏子视图==========
-(void)setupCustomNaviBar{
    [self.customNavView addSubview:self.cartBuyBtn];
    [self.cartBuyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.customNavView).offset(-10);
        make.bottom.equalTo(self.customNavView).offset(-14);
        make.size.mas_equalTo(CGSizeMake(27, 27));
    }];
    
    [self.customNavView addSubview:self.signButton];
    [self.signButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.cartBuyBtn.mas_left).offset(-10);
        make.bottom.equalTo(self.customNavView).offset(-10);
        make.size.mas_equalTo(CGSizeMake(27, 30));
    }];
    
    [self.customNavView addSubview:self.logoButton];
    [self.logoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.customNavView).offset(10);
        make.bottom.equalTo(self.customNavView).offset(-10);
        make.size.mas_equalTo(CGSizeMake(26, 26));
    }];
    
    
    [self.customNavView addSubview:self.logoLabel];
    [self.logoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.logoButton.mas_right).offset(10);
        make.centerY.equalTo(self.logoButton);
        make.height.mas_equalTo(14);
    }];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yOffset  = scrollView.contentOffset.y;
//    NSLog(@"打印一下滚动的轨迹%f",yOffset);
    [self showNaviWithoffSetY:yOffset];

      //判断是否有刘海
        CGFloat searchBoxOffY = 0;
        CGFloat scrollOffY = 0;
        CGFloat collectionOffYY = 0;
        if (kDevice_Is_iPhoneXScreen) {
            searchBoxOffY = bStatusBarHeight+15;
            scrollOffY = bStatusBarHeight;
            collectionOffYY = bAllNavTotalHeight-30;
        } else {
            searchBoxOffY = bAllNavTotalHeight-3;
            scrollOffY = bStatusBarHeight+3;
            collectionOffYY = bAllNavTotalHeight;
        }
    if (yOffset>0) {
        if(yOffset <  (bAllNavTotalHeight + 15)) {
            if (yOffset>searchBoxOffY) {
                //小于15
                CGRect f = self.searchBoxView.frame;
//                f.origin.y = 15;
                f.origin.y = scrollOffY;
                //改变头部视图的frame
                self.searchBoxView.frame = f;
                self.searchBoxView.backgroundColor = RGBA(229, 229, 229, 1);
            }else{
                CGRect f = self.searchBoxView.frame;
                f.origin.y = bAllNavTotalHeight + 15-yOffset;
                f.size.width = (SCREEN_WIDTH-2*15) - 2*yOffset;
                //改变头部视图的frame
                self.searchBoxView.frame = f;
            }
            
        }else{
            CGRect f = self.searchBoxView.frame;
            f.origin.y = scrollOffY;
            f.size.width = (SCREEN_WIDTH-2*HOME_SPACING_LEFT) - 2*(bAllNavTotalHeight);
            //改变头部视图的frame
            self.searchBoxView.frame = f;
        }
        
        if(yOffset <  (bAllNavTotalHeight + 60)) {
            if (yOffset>collectionOffYY) {
                CGRect f = self.collectionView.frame;
                f.origin.y = bAllNavTotalHeight;
                f.size.height = SCREEN_HEIGHT-bAllNavTotalHeight;
                //改变头部视图的frame
                self.collectionView.frame = f;
            }else{
                CGRect f = self.collectionView.frame;
                f.origin.y = bAllNavTotalHeight + 60-yOffset;
                f.size.height = SCREEN_HEIGHT-bAllNavTotalHeight-60+yOffset;
                //改变头部视图的frame
                self.collectionView.frame = f;
            }
        }
    }
}
- (void)showNaviWithoffSetY:(CGFloat)offSetY{
    //tableView相对于图片的偏移量
    self.lastOffsetY = offSetY;
    CGFloat alpha = (offSetY)/bAllNavTotalHeight;
    if (alpha>=1) {
        //黑色
        self.customNavView.backgroundColor = [UIColor whiteColor];
        self.logoLabel.alpha = 0.0;
        self.logoButton.alpha = 0.0;
        [self.cartBuyBtn setImage:[UIImage imageNamed:@"yx_icon_gouwuc_hei"] forState:UIControlStateNormal];
        [self.signButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else{
        self.customNavView.backgroundColor = RGBA(255, 255, 255, alpha);
        self.logoLabel.alpha = (1-alpha);
        self.logoButton.alpha = (1-alpha);
        [self.cartBuyBtn setImage:[UIImage imageNamed:@"yx_icon_gouwuc"] forState:UIControlStateNormal];
        [self.signButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}
#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 20;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [NSString stringWithFormat:@"UICollectionViewCell%ld",(long)indexPath.row];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:identifier];
    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    return cell;
    
}
//cell 高度
-(CGSize)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return CGSizeMake(SCREEN_WIDTH, 50);
}
#pragma mark ==========设置header高度==========
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
   return CGSizeMake(SCREEN_WIDTH, 10);
}

#pragma mark ==========设置footer高度==========
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(SCREEN_WIDTH, 0.01);
}

#pragma mark ==========点击事件==========
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}


#pragma mark setter and Getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *fallLayout = [[UICollectionViewFlowLayout alloc] init];
        fallLayout.itemSize=CGSizeMake(SCREEN_WIDTH, 100);
        fallLayout.minimumLineSpacing = 0;
        fallLayout.minimumInteritemSpacing = 0;
        fallLayout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 120);
        fallLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.fallLayout = fallLayout;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, bAllNavTotalHeight+60, SCREEN_WIDTH, SCREEN_HEIGHT-bAllNavTotalHeight-60) collectionViewLayout:fallLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}
-(UIImageView *)searchImgView{
    if (!_searchImgView) {
        _searchImgView = ({
            UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectZero];
            //添加图片
            imgView.image = [UIImage imageNamed:@"yx_icon_sousuo"];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            imgView ;
        }) ;
    }
    return _searchImgView ;
}
-(UILabel *)searchTitleLab{
    if (!_searchTitleLab) {
        _searchTitleLab = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];//初始化控件
            //常用属性
            label.text = @"搜索商品";//内容显示
            label.textColor = [UIColor grayColor];//设置字体颜色
            label.font = [UIFont systemFontOfSize:13];//设置字体大小
            label.textAlignment = NSTextAlignmentLeft;//设置对齐方式
            label.numberOfLines = 1; //行数
            
            label ;
        }) ;
    }
    return _searchTitleLab ;
}
//购物车
-(UIButton *)cartBuyBtn{
    if (!_cartBuyBtn) {
        _cartBuyBtn = ({
            //创建按钮
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            //设置标题
            [button setImage:[UIImage imageNamed:@"yx_icon_gouwuc"] forState:UIControlStateNormal];
            
            //添加点击事件
            [button addTarget:self action:@selector(clickCartBuyButton:) forControlEvents:UIControlEventTouchUpInside];
            
            button;
        });
    }
    return _cartBuyBtn;
}
-(UIButton *)signButton{
    if (!_signButton) {
        _signButton = ({
            //创建按钮
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            //设置标题
            [button setTitle:@"签到" forState:UIControlStateNormal];
            //设置字体大小
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            //设置title颜色
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"yx_icon_qiandao"] forState:UIControlStateNormal];
//            [button layoutButtonWithEdgeInsetsStyle:GLButtonEdgeInsetsStyleTop imageTitleSpace:-5];
            //添加点击事件
            [button addTarget:self action:@selector(clickSignButton:) forControlEvents:UIControlEventTouchUpInside];
            
            button;
        });
    }
    return _signButton;
}
-(UIButton *)logoButton{
    if (!_logoButton) {
        _logoButton = ({
            //创建按钮
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            //设置标题
            [button setImage:[UIImage imageNamed:@"yx_logo"] forState:UIControlStateNormal];
            //添加点击事件
            //[button addTarget:self action:@selector(clickYanLogoButton:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _logoButton;
}
-(UILabel *)logoLabel{
    if (!_logoLabel) {
        _logoLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];//初始化控件
            //常用属性
            label.text = @"会员注册0门槛，升级享受更惠价格";//内容显示
            label.textColor = [UIColor whiteColor];//设置字体颜色
            label.font = [UIFont systemFontOfSize:13];//设置字体大小
            label.textAlignment = NSTextAlignmentLeft;//设置对齐方式
            label.numberOfLines = 1; //行数
            
            label ;
        }) ;
    }
    return _logoLabel ;
}
#pragma mark ==========点击购物车==========
-(void)clickCartBuyButton:(UIButton *)button{
    
}
#pragma mark ==========点击签到==========
-(void)clickSignButton:(UIButton *)button{
    
}
//#pragma mark =======初始化导航栏==========
//- (HBHomeCusNavView *)customNavView
//{
//    if (_customNavView == nil) {
//        _customNavView = [HBHomeCusNavView CustomNavigationBar];
//        _customNavView.backgroundColor = black_Color;
//    }
//    return _customNavView;
//}
@end
