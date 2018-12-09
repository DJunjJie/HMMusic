//
//  HMMusicTool.m
//  02-黑马音乐
//
//  Created by apple on 14-8-8.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HMMusicTool.h"
#import "HMMusic.h"
#import "MJExtension.h"

@implementation HMMusicTool
static NSArray *_musics;
static HMMusic *_playingMusic;

/**
 *  返回所有的歌曲
 */
+ (NSArray *)musics
{
    if (!_musics) {
        _musics = [HMMusic objectArrayWithFilename:@"Musics.plist"];
    }
    return _musics;
}

/**
 *  返回正在播放的歌曲
 */
+ (HMMusic *)playingMusic
{
    return _playingMusic;
}

+ (void)setPlayingMusic:(HMMusic *)playingMusic
{
    if (!playingMusic || ![[self musics] containsObject:playingMusic]) return;
    if (_playingMusic == playingMusic) return;
    
    _playingMusic = playingMusic;
}

/**
 *  下一首歌曲
 */
+ (HMMusic *)nextMusic
{
    NSInteger nextIndex = 0;
    if (_playingMusic) {
        NSInteger playingIndex = [[self musics] indexOfObject:_playingMusic];
        nextIndex = playingIndex + 1;
        if (nextIndex >= [self musics].count) {
            nextIndex = 0;
        }
    }
    return [self musics][nextIndex];
}

/**
 *  上一首歌曲
 */
+ (HMMusic *)previousMusic
{
    NSInteger previousIndex = 0;
    if (_playingMusic) {
        NSInteger playingIndex = [[self musics] indexOfObject:_playingMusic];
        previousIndex = playingIndex - 1;
        if (previousIndex < 0) {
            previousIndex = [self musics].count - 1;
        }
    }
    return [self musics][previousIndex];
}
@end
