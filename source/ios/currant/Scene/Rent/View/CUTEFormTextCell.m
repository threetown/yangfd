//
//  CUTEFormTextCell.m
//  currant
//
//  Created by Foster Yin on 4/27/15.
//  Copyright (c) 2015 Foster Yin. All rights reserved.
//

#import "CUTEFormTextCell.h"
#import "CUTECommonMacro.h"
#import "CUTEUIMacro.h"

@implementation CUTEFormTextCell

+ (CGFloat)heightForField:(FXFormField *)field width:(CGFloat)width
{
    return CUTE_CELL_DEFAULT_HEIGHT;
}

- (void)update {
    [super update];

    self.textLabel.font = [UIFont systemFontOfSize:16];
    self.textLabel.textColor = HEXCOLOR(0x555555, 1);
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
