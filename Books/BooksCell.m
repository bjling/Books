//
//  BooksCell.m
//  Books
//
//  Created by 邵 凌 on 13-4-29.
//  Copyright (c) 2013年 邵 凌. All rights reserved.
//

#import "BooksCell.h"

@implementation BooksCell
@synthesize book1=_book1;
@synthesize book2=_book2;
@synthesize book3=_book3;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
