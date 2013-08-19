//
//  BookImageView.m
//  Books
//
//  Created by 邵 凌 on 13-5-19.
//  Copyright (c) 2013年 邵 凌. All rights reserved.
//

#import "BookImageView.h"


@implementation BookImageView

@synthesize leftFrame=_leftFrame;


- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)drawRect:(CGRect)rect{
  
    // flip the coordinate system
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // draw
    CTFrameDraw(self.leftFrame, context);
    
    UIGraphicsPushContext(context);
}


@end
