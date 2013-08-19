//
//  ReadBookViewController.m
//  Books
//
//  Created by 邵 凌 on 13-4-30.
//  Copyright (c) 2013年 邵 凌. All rights reserved.
//

#import "ReadBookViewController.h"

@interface ReadBookViewController() <UITextViewDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *bookTextView;


@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolBar;

//用百分比显示阅读到多少
@property (weak, nonatomic) IBOutlet UIBarButtonItem *showCurrPagePercent;

@property (nonatomic)NSUInteger allPages;
@property (nonatomic)NSUInteger currentPage;
@property (nonatomic,retain)NSString *content;
@property (nonatomic,retain)UIAlertView *alertView;
@end

@implementation ReadBookViewController
@synthesize bookTextView=_bookTextView;
@synthesize selectBookDict=_selectBookDict;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bookTextView.delegate=self;
    
    NSString *bookName=[self.selectBookDict objectForKey:@"bookName"];
    
    NSString *bookNamePreFix=[bookName substringToIndex: [bookName rangeOfString:@"."].location];
    NSString *bookNamesufFix=[bookName substringFromIndex: [bookName rangeOfString:@"."].location+1];
    
    //读取书籍
    self.content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:bookNamePreFix ofType:bookNamesufFix ]encoding:NSUTF8StringEncoding error:nil];
    //放到TEXTVIEW里显示
    self.bookTextView.text=self.content;
    
   
    
    //text内容不能做修改
    self.bookTextView.editable=NO;
    self.bookTextView.scrollEnabled = NO;//是否可以拖动
    //字体 背景色 字体颜色等后期要做成供用户自行修改。
    self.bookTextView.font = [UIFont italicSystemFontOfSize:20];
    self.bookTextView.textColor = [UIColor blackColor];
    self.bookTextView.backgroundColor = [UIColor grayColor];
    
    
    //默认navigationBar和bottomToolBar都是HIDDEN的
    self.navigationController.navigationBar.hidden=YES;
    self.bottomToolBar.hidden=YES;
    //增加单击手势
    [self addTapGesture];
    //算出当前书本一共有多少页
   
    self.allPages=self.bookTextView.contentSize.height/([[UIScreen mainScreen]bounds].size.height)+1;
       //默认当前页为1
    self.currentPage=1;
    self.showCurrPagePercent.title=self.setReadCurrPageByPercent;
    
    //test
    CTTextAlignment alignment = kCTLeftTextAlignment;
    CTParagraphStyleSetting alignmentStyle;
    alignmentStyle.spec=kCTParagraphStyleSpecifierAlignment;//指定为对齐属性
    alignmentStyle.valueSize=sizeof(alignment);
    alignmentStyle.value=&alignment;
    
    
    //over
    
    UIPanGestureRecognizer *panGesture=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(upOrDownPanPage:)];
    [self.bookTextView addGestureRecognizer:panGesture];
}
-(void)upOrDownPanPage:(UIPanGestureRecognizer *)panGesture{
    //CGFloat beganLocationX=0;
    CGFloat endedLocationX=0;
    //if(panGesture.state==UIGestureRecognizerStateBegan){
    //   beganLocationX=[panGesture translationInView:self.bookTextView].x;
    
    //}
    if(panGesture.state==UIGestureRecognizerStateEnded){
        endedLocationX=[panGesture translationInView:self.bookTextView].x;
        //负数为下一页，正数为上一页
        if(endedLocationX>0){
            [self upPage];
        }
        if(endedLocationX<0){
            [self downPage];
        }
        
    }
    // [panGesture setTranslation:CGPointZero inView:self.bookTextView];
    
    
    
    
}
//第一页或者最后一页但弹提示框告知用户
-(void)alertViewTips:(NSString *)msg{
    self.alertView= [[UIAlertView alloc]init];
    [self.alertView setTitle:@"温馨提示"];
    [self.alertView setMessage:msg];
    [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector: @selector(performDismiss:)userInfo:nil repeats:NO];
    [self.alertView show];
}
//自动关闭UIAlertView 方法
- (void) performDismiss: (NSTimer *)timer
{
    [self.alertView dismissWithClickedButtonIndex:0 animated:NO];//important
}
//向上翻页
-(void)upPage{
    
    if(self.currentPage==1){
        [self alertViewTips:@"已经是第一页"];
        return;
    }
    self.currentPage=self.currentPage-1;
    [self.bookTextView setContentOffset:CGPointMake(0, (int)(self.currentPage-1) * ([[UIScreen mainScreen]bounds].size.height)) animated:YES];
    
    self.showCurrPagePercent.title=self.setReadCurrPageByPercent;
}

//向下翻页
-(void)downPage{
    if(self.currentPage==self.allPages){
        [self alertViewTips:@"已经是最后一页"];
        return;
    }
     self.currentPage=self.currentPage+1;
    [self.bookTextView setContentOffset:CGPointMake(0, (int)(self.currentPage-1) * ([[UIScreen mainScreen]bounds].size.height)) animated:YES];
    
    
    self.showCurrPagePercent.title=self.setReadCurrPageByPercent;
    
}


//设置当前页对应全书一共多少百分比,保留2位小数
-(NSString *) setReadCurrPageByPercent{
    double d=(double)self.currentPage/self.allPages;
    NSNumber *number=[[NSNumber alloc]initWithDouble:d*100];
    NSString *percent=[number stringValue];
    percent=[percent substringToIndex:4];
    percent=[percent stringByAppendingString:@"%"];
    return percent;
    
}
//增加textView点击一次的手势
-(void)addTapGesture{
    self.bookTextView.userInteractionEnabled=YES;
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapToShowNavigationBarAndBottomToolBar:)];
    tapGesture.numberOfTouchesRequired=1;//手指数
    tapGesture.numberOfTapsRequired=1;//点击一次
    tapGesture.delegate=self;
    [self.bookTextView addGestureRecognizer:tapGesture];
}
//判断点击一次是否显示或隐藏NavigationBar和bottomToolBar
-(void)singleTapToShowNavigationBarAndBottomToolBar:(UIGestureRecognizer *)sender{
    if(self.navigationController.navigationBar.isHidden){
        self.navigationController.navigationBar.hidden=NO;
        self.bottomToolBar.hidden=NO;
    }else{
        self.bottomToolBar.hidden=YES;
        self.navigationController.navigationBar.hidden=YES;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
