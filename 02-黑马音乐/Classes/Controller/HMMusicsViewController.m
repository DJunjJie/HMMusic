//
//  HMMusicsViewController.m
//  02-黑马音乐
//
//  Created by apple on 14-8-8.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HMMusicsViewController.h"
#import "HMPlayingViewController.h"
#import "MJExtension.h"
#import "HMMusic.h"
#import "HMMusicTool.h"
#import "HMMusicCell.h"

@interface HMMusicsViewController ()
@property (nonatomic, strong) HMPlayingViewController *playingVc;
@end

@implementation HMMusicsViewController

- (HMPlayingViewController *)playingVc
{
    if (!_playingVc) {
        self.playingVc = [[HMPlayingViewController alloc] init];
    }
    return _playingVc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [HMMusicTool musics].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HMMusicCell *cell = [HMMusicCell cellWithTableView:tableView];
    cell.music = [HMMusicTool musics][indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1.取消选中被点击的这行
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 2.设置正在播放的歌曲
    [HMMusicTool setPlayingMusic:[HMMusicTool musics][indexPath.row]];
    
    // 3.显示播放界面
    [self.playingVc show];
}
@end
