//
//  ShowAllBooksViewController.m
//  Books
//
//  Created by 邵 凌 on 13-6-24.
//  Copyright (c) 2013年 邵 凌. All rights reserved.
//

#import "ShowAllBooksViewController.h"
#import "ShowBookNamesCell.h"

@interface ShowAllBooksViewController ()<UITableViewDelegate,UITableViewDataSource>


@property NSArray *allBooksArray;
@property NSMutableArray *selectBookIndexArray;//存放选中要添加的书籍INDEXPATH ROW


@end

@implementation ShowAllBooksViewController
@synthesize allBooksArray=_allBooksArray;
@synthesize showBookTableView=_showBookTableView;
@synthesize selectBookIndexArray=_selectBookIndexArray;
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
    NSBundle *bundle=[NSBundle mainBundle];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *array=[fileManager contentsOfDirectoryAtPath:[bundle resourcePath] error:nil];
    
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"BookNames.plist"];
    NSMutableArray *booksArray=[[[NSMutableArray alloc]initWithContentsOfFile:path]mutableCopy];
    if(!booksArray){
        booksArray=[[[NSMutableArray alloc]initWithContentsOfFile:[bundle pathForResource:@"BookNames" ofType:@"plist"]]mutableCopy];
    }
    NSString *booksName;
    for(int i=0;i<array.count;i++){
        booksName=[array objectAtIndex:i];
        if([booksName hasSuffix:@".txt"]){
            if(![booksArray containsObject:booksName]){
                [booksArray addObject:booksName];
            }
        }
    }
    
    [booksArray writeToFile:path atomically:YES];
    self.allBooksArray=[NSMutableArray arrayWithArray:booksArray];
    
}
//一共有多少rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allBooksArray.count;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(ShowBookNamesCell *)getBookCell:(UITableView *)tableView{
    
    ShowBookNamesCell *cell = [tableView dequeueReusableCellWithIdentifier: @"showBookNameCell"];
    
    if (cell == nil) {
        
        cell = [[ShowBookNamesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"showBookNameCell"];
        
    }
//    //解决UITableView重用问题 具体看我在COCO上面提的问题
//    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
//    for (UIView *subview in subviews) {
//        subview.hidden=YES;
//    }
    
    return cell;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        
    NSUInteger row = [indexPath row];
    ShowBookNamesCell *cell=[self getBookCell:tableView];
    
    cell.textLabel.text=[self.allBooksArray objectAtIndex:row];
    cell.textLabel.tag=row;
   return cell;

}
- (IBAction)addBookAction:(id)sender {
  

}



//判断tableviewcell是否被选中
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!self.selectBookIndexArray){
        self.selectBookIndexArray=[[NSMutableArray alloc]initWithCapacity:self.allBooksArray.count];
          }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectBookIndexArray addObject:indexPath];
            }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        if([self.selectBookIndexArray containsObject:indexPath]){
            [self.selectBookIndexArray removeObject:indexPath];
                }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}


@end
