//
//  ReadBooksViewController.m
//  Books
//
//  Created by 邵 凌 on 13-5-19.
//  Copyright (c) 2013年 邵 凌. All rights reserved.
//

#import "ReadBooksViewController.h"
#import "BookImageView.h"
#import <CoreText/CoreText.h>

@interface ReadBooksViewController ()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet BookImageView *bookImageView;

@property (nonatomic,retain)NSString *content;
@property CGFloat characterSpacing; //字间距
@property CGFloat linesSpacing; //行间距
@property NSUInteger currContentIndex;//当前屏幕能存放的字体INDEX
@property NSUInteger allContentIndex;//到目前页一共存放了多少字体INDEX
@property (nonatomic)NSUInteger allPages;//书籍总页数
@property (nonatomic)NSUInteger currentPage;//书籍当前页
@property (nonatomic,retain)UIAlertView *alertView;
@property (nonatomic)NSDictionary *selectBookDict;
@property (nonatomic)NSUInteger *selectBookTag;
@property BOOL b;

@property  NSMutableArray *booksContentIndexArray;//数组每一页存放的字体INDEX

@property (weak, nonatomic) IBOutlet UIToolbar *buttomToolBar;
//用百分比显示阅读到多少
@property (weak, nonatomic) IBOutlet UIBarButtonItem *showScheduleItem;

@end

@implementation ReadBooksViewController


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
    
    self.linesSpacing = 0.0f;
    
    //读取配置文件里的最后一次阅读到多少页，下次直接从这里读取
    NSString *pageIndex=[self.selectBookDict objectForKey:@"pageIndex"];
    
    int index=pageIndex.intValue;
    
    
    //起始默认1，到时候应该从配置文件读取
    self.currentPage=1;
    //每页显示内容计算方法
    [self showBookByPagePer];
    self.showScheduleItem.title=self.setReadCurrPageByPercent;
    
    NSLog(@"%i",index);
    if(index!=1){
        self.b=YES;
       
     //  [self loadBookArray];
        for(int i=1;i<index;i++){
            [self downPage];
        }
        
        self.b=NO;
    }
    //点击一次隐藏或显示NavigationBar and BottomToolBar hidden or show
    [self addTapGesture];
    
    [self setNavigationBarAndBottomToolBarHidden];
    
    
    [self setTurnOverPageGesture ];
    
    
}
-(void)loadBookArray{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
//        [NSThread sleepForTimeInterval:1];
        for(int i=1;i<50;i++){
            [self downPage];
        }
        NSLog(@"group1");
    });
    dispatch_group_async(group, queue, ^{
//        [NSThread sleepForTimeInterval:2];
        for(int i=51;i<100;i++){
            [self downPage];
        }
        NSLog(@"group2");
    });
    dispatch_group_async(group, queue, ^{
//        [NSThread sleepForTimeInterval:3];
        for(int i=101;i<150;i++){
            [self downPage];
        }
        NSLog(@"group3");
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"updateUi");
    });
}
-(void)setTurnOverPageGesture{
    
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(upOrDownPanPage:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view] addGestureRecognizer:recognizer];
    
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(upOrDownPanPage:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [[self view] addGestureRecognizer:recognizer];
    
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(upOrDownPanPage:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [[self view] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(upOrDownPanPage:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self view] addGestureRecognizer:recognizer];
    
    
    
    [self.bookImageView addGestureRecognizer:recognizer];
}

-(void)showBookByPagePer{
    //读取书籍内容
    [self readBookContent];
    //设置文章属性
       [self setContentAttribute];
  
    
    [self.bookImageView setNeedsDisplay];
    
}
-(void)setContentAttribute{
  
    //去掉空行
    // NSString *myString = [self.content stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
    //创建AttributeString
    NSMutableAttributedString *string =[[NSMutableAttributedString alloc]initWithString:self.content];
    
    //创建字体以及字体大小
    CTFontRef helvetica = CTFontCreateWithName(CFSTR("Helvetica"),  self.characterSpacing, NULL);
    
    //添加字体目标字符串从下标0开始到字符串结尾
    [string addAttribute:(id)kCTFontAttributeName
                   value:(id)CFBridgingRelease(helvetica)
                   range:NSMakeRange(0, [string length])];
    
    //创建文本对齐方式
    CTTextAlignment alignment = kCTJustifiedTextAlignment;//这种对齐方式会自动调整，使左右始终对齐
    CTParagraphStyleSetting alignmentStyle;
    alignmentStyle.spec=kCTParagraphStyleSpecifierAlignment;//指定为对齐属性
    alignmentStyle.valueSize=sizeof(alignment);
    alignmentStyle.value=&alignment;
    
    //创建文本行间距
    CGFloat lineSpace=self.linesSpacing;//间距数据
    CTParagraphStyleSetting lineSpaceStyle;
    lineSpaceStyle.spec=kCTParagraphStyleSpecifierLineSpacing;//指定为行间距属性
    lineSpaceStyle.valueSize=sizeof(lineSpace);
    lineSpaceStyle.value=&lineSpace;
    
    //创建样式数组
    CTParagraphStyleSetting settings[]={
        alignmentStyle,lineSpaceStyle
    };
    
    //设置样式
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings));
    
    //给字符串添加样式attribute
    [string addAttribute:(id)kCTParagraphStyleAttributeName
                   value:(id)CFBridgingRelease(paragraphStyle)
                   range:NSMakeRange(0, [string length])];

      // layout master
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)CFBridgingRetain(string));
      //计算书籍一共有多少页并显示在前台
    if(!self.allPages){
    [self calculatePages:framesetter];
    }

    CGMutablePathRef leftColumnPath = CGPathCreateMutable();
    //这里的-20是为了和UIVIEW的BOUNDS.size.height一样大
    CGPathAddRect(leftColumnPath, NULL,
                  CGRectMake(0, 0,
                             [[UIScreen mainScreen]bounds].size.width,
                             [[UIScreen mainScreen]bounds].size.height-20));
    CTFrameRef leftFrame = CTFramesetterCreateFrame(framesetter,
                                                    CFRangeMake(0, 0),
                                                    leftColumnPath, NULL);
    CFRange frameRange= CTFrameGetVisibleStringRange(leftFrame);
    
    
    self.currContentIndex=frameRange.length;
    
    if(!self.booksContentIndexArray){
        self.booksContentIndexArray=[[NSMutableArray alloc]initWithCapacity:self.allPages];
    }
    self.bookImageView.leftFrame=leftFrame;
  

}
//读取书籍内容
-(void)readBookContent{
   
      NSString *bookName=[self.selectBookDict objectForKey:@"bookName"];
    NSString *bookNamePreFix=[bookName substringToIndex: [bookName rangeOfString:@"."].location];
    NSString *bookNamesufFix=[bookName substringFromIndex: [bookName rangeOfString:@"."].location+1];
    //读取书籍
    self.content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:bookNamePreFix ofType:bookNamesufFix ]encoding:NSUTF8StringEncoding error:nil];
    
    if(!self.allPages){
        self.content=[self.content substringFromIndex:self.allContentIndex];
     }else{
         @try {
             NSRange range=NSMakeRange(self.allContentIndex, 1000);
             self.content =[self.content substringWithRange:range];

         }
         @catch (NSException *exception) {
             self.content=[self.content substringFromIndex:self.allContentIndex];

         }
        
    }
  
    
}
-(void)setNavigationBarAndBottomToolBarHidden{
    //默认navigationBar和bottomToolBar都是HIDDEN的
    self.navigationController.navigationBar.hidden=YES;
    self.buttomToolBar.hidden=YES;
}

//增加textView点击一次的手势
-(void)addTapGesture{
    self.bookImageView.userInteractionEnabled=YES;
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapToShowNavigationBarAndBottomToolBar:)];
    tapGesture.numberOfTouchesRequired=1;//手指数
    tapGesture.numberOfTapsRequired=1;//点击一次
    tapGesture.delegate=self;
    [self.bookImageView addGestureRecognizer:tapGesture];
}
//判断点击一次是否显示或隐藏NavigationBar和bottomToolBar
-(void)singleTapToShowNavigationBarAndBottomToolBar:(UIGestureRecognizer *)sender{
    if(self.navigationController.navigationBar.isHidden){
        self.navigationController.navigationBar.hidden=NO;
        self.buttomToolBar.hidden=NO;
    }else{
        self.buttomToolBar.hidden=YES;
        self.navigationController.navigationBar.hidden=YES;
    }
}
-(void)upOrDownPanPage:(UISwipeGestureRecognizer *)recognizer{
    if (recognizer.direction==UISwipeGestureRecognizerDirectionDown||recognizer.direction==UISwipeGestureRecognizerDirectionLeft) {
        [self downPage];
        
    }
    if (recognizer.direction==UISwipeGestureRecognizerDirectionUp||recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        [self upPage];
        
    }
    
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
    
    NSNumber *index=[self.booksContentIndexArray lastObject];
    [self.booksContentIndexArray removeLastObject];
    self.allContentIndex-=index.intValue;
    [self showBookByPagePer];
    
    self.showScheduleItem.title=self.setReadCurrPageByPercent;
    [UIView beginAnimations:@"animationID" context:nil];
    [UIView setAnimationDuration:0.7f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
    [UIView commitAnimations];
    
    [self writePageIndex];
    
}

//向下翻页
-(void)downPage{
    if(self.currentPage==self.allPages){
        [self alertViewTips:@"已经是最后一页"];
        return;
    }
    self.currentPage=self.currentPage+1;
    
    
    [self.booksContentIndexArray addObject:[NSNumber numberWithInt:self.currContentIndex]];
    
    self.allContentIndex+=self.currContentIndex;
      [self showBookByPagePer];
  
    self.showScheduleItem.title=self.setReadCurrPageByPercent;
    [UIView beginAnimations:@"animationID" context:nil];
    [UIView setAnimationDuration:0.7f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.view cache:YES];
    
    [UIView commitAnimations];
    
    [self writePageIndex];
   
    
}
- (NSString *)getTimeNow
{
    NSString* date;
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    //[formatter setDateFormat:@"YYYY.MM.dd.hh.mm.ss"];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
    date = [formatter stringFromDate:[NSDate date]];
    NSString* timeNow = [[NSString alloc] initWithFormat:@"%@", date];
    return timeNow;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
-(void)calculatePages:(CTFramesetterRef)framesetter{
    
    CGSize screenSize=CGSizeMake([[UIScreen mainScreen]bounds].size.width, CGFLOAT_MAX);
    
    //计算文本绘制size
    CGSize tmpSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), NULL, screenSize, NULL);
    //计算出一共有多少页
    self.allPages=tmpSize.height/([[UIScreen mainScreen]bounds].size.height-20);
    
   }

//设置当前页对应全书一共多少百分比,保留2位小数
-(NSString *) setReadCurrPageByPercent{
    double d=(double)self.currentPage/self.allPages;
    NSNumber *number=[[NSNumber alloc]initWithDouble:d*100];
    NSString *percent=[number stringValue];
    if(percent.length>4){
    percent=[percent substringToIndex:4];
    }
    percent=[percent stringByAppendingString:@"%"];
    return percent;
}
-(void)writePageIndex{
    if(!self.b){
        
         NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"BookDetail.plist"];
        
         NSMutableArray *booksArray=[[[NSMutableArray alloc]initWithContentsOfFile:path]mutableCopy];
        NSUInteger index=self.selectBookTag;
   
        NSMutableDictionary *rowDict=[[[NSMutableDictionary alloc]initWithDictionary:[booksArray objectAtIndex:index]]mutableCopy];
     
        [rowDict setObject:   [NSString stringWithFormat: @"%d", self.currentPage] forKey:@"pageIndex"];
        
        [booksArray replaceObjectAtIndex:index withObject:rowDict];
        [booksArray writeToFile:path atomically:YES];
    }
}
-(void)setSelectBookDict:(NSDictionary *)selectBookDict AndTag:(NSUInteger *)selectBookTag{
    self.selectBookDict=selectBookDict;
    self.selectBookTag=selectBookTag;
}
@end
