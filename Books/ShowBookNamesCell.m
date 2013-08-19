//
//  ShowBookNamesCell.m
//  Books
//
//  Created by 邵 凌 on 13-6-24.
//  Copyright (c) 2013年 邵 凌. All rights reserved.
//

#import "ShowBookNamesCell.h"

@implementation ShowBookNamesCell
@synthesize bookNameLabel=_bookNameLabel;


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
