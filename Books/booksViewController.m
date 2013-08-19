//
//  booksViewController.m
//  Books
//
//  Created by 邵 凌 on 13-4-23.
//  Copyright (c) 2013年 邵 凌. All rights reserved.
//

#import "booksViewController.h"
#import "booksCell.h"
#import <QuartzCore/QuartzCore.h>
//#import "ReadBookViewController.h"
#import "ReadBooksViewController.h"
@interface booksViewController ()

@end

@implementation booksViewController
@synthesize bookTableView=_bookTableView;
@synthesize booksArray=_booksArray;
NSInteger rowCount;

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"BookDetail.plist"];
    NSArray *booksArray=[[NSArray alloc]initWithContentsOfFile:path];
    if(!booksArray){
        //获取项目路径
        NSBundle *bundle=[NSBundle mainBundle];
        NSString *plistPath = [bundle pathForResource:@"BookDetail" ofType:@"plist"];
        
        self.booksArray=[[NSArray alloc]initWithContentsOfFile:plistPath];
        [self.booksArray writeToFile:path atomically:YES];
    }else{
        self.booksArray=booksArray;
    }
    
    
    
    //书架3个一组，所以需要做下面这个分页处理
    rowCount=(self.booksArray.count+3-1)/3;
}
//书架3个一组，所以需要做下面这个分页处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return rowCount;
}
-(BooksCell *)getBookCell:(UITableView *)tableView{
    
    BooksCell *cell=[tableView dequeueReusableCellWithIdentifier:@"bookCell"];
    if(cell==nil){
        cell=[[BooksCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bookCell"];
    }
    //解决UITableView重用问题 具体看我在COCO上面提的问题
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
    for (UIView *subview in subviews) {
        subview.hidden=YES;
    }
    
    return cell;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger row =[indexPath row];
    NSUInteger startIndex=row*3;
    NSUInteger endIndex=startIndex+3;
    if(endIndex>=self.booksArray.count)endIndex=self.booksArray.count;
    NSUInteger flag=0;
    BooksCell *cell=[self getBookCell:tableView];
    for(;startIndex<endIndex;startIndex++){
        NSDictionary *rowDict=[self.booksArray objectAtIndex:startIndex];
        if(rowDict!=nil){
            flag++;
            if(flag==1){
                [cell.book1 setBackgroundImage:[UIImage imageNamed:[rowDict objectForKey:@"imagePath"]] forState: UIControlStateNormal];
                cell.book1.tag=startIndex;
                [self setButtonInteractionAndHiddenEnabled:cell.book1];
            }
            else if(flag==2){
                [cell.book2 setBackgroundImage:[UIImage imageNamed:[rowDict objectForKey:@"imagePath"]] forState: UIControlStateNormal];
                cell.book2.tag=startIndex;
                [self setButtonInteractionAndHiddenEnabled:cell.book2];
            }
            else if(flag==3){
                [cell.book3 setBackgroundImage:[UIImage imageNamed:[rowDict objectForKey:@"imagePath"]] forState: UIControlStateNormal];
                cell.book3.tag=startIndex;
                [self setButtonInteractionAndHiddenEnabled:cell.book3];
            }
        }
    }
    return cell;
}
-(void)setButtonInteractionAndHiddenEnabled:(UIButton *)button{
    button.userInteractionEnabled=YES;
    button.hidden=NO;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showAllBooks"]){
    
    }else{
    NSUInteger index=[sender tag];
    [segue.destinationViewController setSelectBookDict: [self.booksArray objectAtIndex:index]AndTag: index] ;
    }
    
}

@end
