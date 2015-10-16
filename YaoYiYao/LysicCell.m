//
//  LysicCell.m
//  YaoYiYao
//
//  Created by liqunfei on 15/10/15.
//  Copyright © 2015年 chuchengpeng. All rights reserved.
//

#import "LysicCell.h"

@implementation LysicCell

- (void)awakeFromNib {
   self.selectionStyle = UITableViewCellSelectionStyleNone;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
   
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];

}


@end
