//
//  TableViewController.h
//  YaoYiYao
//
//  Created by liqunfei on 15/10/9.
//  Copyright © 2015年 chuchengpeng. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TableViewControllerDelegate <NSObject>

- (void)changeBackgroundImageWithImage:(NSInteger)image;
- (void)getMoreImageWithNum:(NSInteger)num;
@end

@interface TableViewController : UITableViewController
@property (nonatomic,strong) NSArray *arra;
@property (nonatomic,assign) NSInteger allCout;
@property (nonatomic,weak) id<TableViewControllerDelegate>delegate;
@end
