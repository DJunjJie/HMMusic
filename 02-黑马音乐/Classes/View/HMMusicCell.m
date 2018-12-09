//
//  HMMusicCell.m
//  02-黑马音乐
//
//  Created by apple on 14-8-8.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HMMusicCell.h"
#import "HMMusic.h"
#import "Colours.h"
#import "UIImage+MJ.h"

@implementation HMMusicCell
+ (instancetype)cellWithTableView:(UITableView *)tableView
{   static NSString *ID = @"music";
   // static NSString *ID = @"music";
    HMMusicCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[HMMusicCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    return cell;
}

- (void)setMusic:(HMMusic *)music
{
    _music = music;
    
    self.textLabel.text = music.name;
    self.detailTextLabel.text = music.singer;
    self.imageView.image = [UIImage circleImageWithName:music.singerIcon borderWidth:3 borderColor:[UIColor pinkColor]];
}

@end
