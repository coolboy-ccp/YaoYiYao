//
//  MusicListTableViewController.m
//  YaoYiYao
//
//  Created by liqunfei on 15/10/15.
//  Copyright © 2015年 chuchengpeng. All rights reserved.
//

#import "MusicListTableViewController.h"

@interface MusicListTableViewController ()

@end

@implementation MusicListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.songsList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell" forIndexPath:indexPath];
    NSString *str = self.songsList[indexPath.row];
    cell.textLabel.text = [[str componentsSeparatedByString:@"YaoYiYao.app/"] lastObject];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectASongWithTag:)]) {
        [self.delegate selectASongWithTag:indexPath.row];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
