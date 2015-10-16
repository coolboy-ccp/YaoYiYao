//
//  MusicListTableViewController.h
//  YaoYiYao
//
//  Created by liqunfei on 15/10/15.
//  Copyright © 2015年 chuchengpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MusicListTableViewControllerDelegate <NSObject>

- (void)selectASongWithTag:(NSInteger)tag;

@end

@interface MusicListTableViewController : UITableViewController
@property (strong,nonatomic) NSArray *songsList;
@property (weak,nonatomic) id<MusicListTableViewControllerDelegate>delegate;
@end
