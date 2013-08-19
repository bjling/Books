//
//  BooksCell.h
//  Books
//
//  Created by 邵 凌 on 13-4-29.
//  Copyright (c) 2013年 邵 凌. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BooksCell : UITableViewCell
//故事版直接建了3个BOOK Button 虽然不是很优雅。但代码里就不必考虑SIZE等问题。

@property (weak, nonatomic) IBOutlet UIButton *book1;
@property (weak, nonatomic) IBOutlet UIButton *book2;
@property (weak, nonatomic) IBOutlet UIButton *book3;

@end
