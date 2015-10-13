//
//  TableViewController.m
//  YaoYiYao
//
//  Created by liqunfei on 15/10/9.
//  Copyright © 2015年 chuchengpeng. All rights reserved.
//

#import "TableViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface TableViewController ()
{
    NSInteger cout;
}
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView setContentOffset:CGPointMake(0, 0)];
    cout = 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arra.count;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint contentoffset = self.tableView.contentOffset;
    CGRect frame = self.tableView.frame;
    if (contentoffset.y == self.tableView.contentSize.height - frame.size.height) {
        if (cout < self.allCout) {
            cout += 20;
            if (self.delegate && [self.delegate respondsToSelector:@selector(getMoreImageWithNum:)]) {
                [self.delegate getMoreImageWithNum:cout];
                [self.tableView reloadData];
            }
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"到底了" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
            [alert show];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MYCELL" forIndexPath:indexPath];
    NSDictionary *dic = [self.arra objectAtIndex:indexPath.row];
    NSString *type = [dic objectForKey:@"TYPE"];
    cell.textLabel.text = type;
    UIImage *image = [dic objectForKey:@"IMAGE"];
    cell.imageView.image = image;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeBackgroundImageWithImage:)]) {
        [self.delegate changeBackgroundImageWithImage:indexPath.row];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


@end
