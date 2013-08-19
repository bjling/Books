//
//  booksViewController.h
//  Books
//
//  Created by 邵 凌 on 13-4-23.
//  Copyright (c) 2013年 邵 凌. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface booksViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITableView *bookTableView;

@property(strong,nonatomic)NSArray *booksArray;
@end
