//
//  ReadBooksViewController.h
//  Books
//
//  Created by 邵 凌 on 13-5-19.
//  Copyright (c) 2013年 邵 凌. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReadBooksViewController : UIViewController
-(void)setSelectBookDict:(NSDictionary *)selectBookDict AndTag:(NSUInteger *)selectBookTag;
-(void)setFontSize:(CGFloat *)fontSize AndFontArray:(NSArray *)fontArray;
-(void)setCurrPageIndex:(NSUInteger *)currPageIndex AndCurrCount:(NSUInteger *)currCont;
@end
