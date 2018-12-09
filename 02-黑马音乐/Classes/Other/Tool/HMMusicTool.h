//
//  HMMusicTool.h
//  02-黑马音乐
//
//  Created by apple on 14-8-8.
//  Copyright (c) 2014年 heima. All rights reserved.
//  管理音乐数据（音乐模型）

#import <Foundation/Foundation.h>
@class HMMusic;

@interface HMMusicTool : NSObject
/**
 *  返回所有的歌曲
 */
+ (NSArray *)musics;

/**
 *  返回正在播放的歌曲
 */

+ (HMMusic *)playingMusic;
+ (void)setPlayingMusic:(HMMusic *)playingMusic;

/**
 *  下一首歌曲
 */
+ (HMMusic *)nextMusic;

/**
 *  上一首歌曲
 */
+ (HMMusic *)previousMusic;
@end
