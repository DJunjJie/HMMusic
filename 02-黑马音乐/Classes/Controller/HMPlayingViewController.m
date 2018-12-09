//
//  HMPlayingViewController.m
//  02-黑马音乐
//
//  Created by apple on 14-8-8.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HMPlayingViewController.h"
#import "HMMusic.h"
#import "HMMusicTool.h"
#import <AVFoundation/AVFoundation.h>
#import "HMAudioTool.h"
#import "HMLrcView.h"

@interface HMPlayingViewController ()<AVAudioPlayerDelegate>
- (IBAction)exit;
- (IBAction)lyricOrPic:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (nonatomic, strong) HMMusic *playingMusic;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UIButton *slider;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *currentTimeView;
/**
 *  播放进度定时器
 */
@property (nonatomic, strong) NSTimer *currentTimeTimer;
/**
 *  歌词显示的定时器
 */
@property (nonatomic, strong) CADisplayLink *lrcTimer;
- (IBAction)previous;
- (IBAction)next;
- (IBAction)playOrPause;
- (IBAction)tapProgressBg:(UITapGestureRecognizer *)sender;
- (IBAction)panSlider:(UIPanGestureRecognizer *)sender;
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseButton;
@property (weak, nonatomic) IBOutlet HMLrcView *lrcView;

@end

@implementation HMPlayingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.currentTimeView.layer.cornerRadius = 10;
}

#pragma mark - 公共方法
/**
 *  显示
 */
- (void)show
{
    // 0.禁用整个app的点击事件
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    window.userInteractionEnabled = NO;
    
    // 1.添加播放界面
    self.view.frame = window.bounds;
    self.view.hidden = NO;
    [window addSubview:self.view];
    
    // 2.如果换了歌曲
    if (self.playingMusic != [HMMusicTool playingMusic]) {
        [self resetPlayingMusic];
    }
    
    // 3.动画显示
    self.view.y = self.view.height;
    [UIView animateWithDuration:1.0 animations:^{
        self.view.y = 0;
    } completion:^(BOOL finished) {
        // 开始播放音乐
        [self startPlayingMusic];
        
        window.userInteractionEnabled = YES;
    }];
}

#pragma mark - 定时器处理
- (void)addCurrentTimeTimer
{
    if (self.player.isPlaying == NO) return;
    
   // [self removeCurrentTimeTimer];
    
    // 保证定时器的工作是及时的
    [self updateCurrentTime];
    
    self.currentTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.currentTimeTimer forMode:NSRunLoopCommonModes];
}

- (void)removeCurrentTimeTimer
{
    [self.currentTimeTimer invalidate];
    self.currentTimeTimer = nil;
}

/**
 *  更新播放进度
 */
- (void)updateCurrentTime
{
    // 1.计算进度值
    double progress = self.player.currentTime / self.player.duration;
    
    // 2.设置滑块的x值
    CGFloat sliderMaxX = self.view.width - self.slider.width;
    self.slider.x = sliderMaxX * progress;
    [self.slider setTitle:[self strWithTime:self.player.currentTime] forState:UIControlStateNormal];
    
    // 3.设置进度条的宽度
    self.progressView.width = self.slider.center.x;
}

- (void)addLrcTimer
{
    if (self.player.isPlaying == NO || self.lrcView.hidden) return;
    
    //[self removeLrcTimer];
    
    // 保证定时器的工作是及时的
    [self updateLrc];
    
    self.lrcTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrc)];
    [self.lrcTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)removeLrcTimer
{
    [self.lrcTimer invalidate];
    self.lrcTimer = nil;
}

/**
 *  更新歌词
 */
- (void)updateLrc
{
    self.lrcView.currentTime = self.player.currentTime;
}

#pragma mark - 音乐控制
/**
 *  重置正在播放的音乐
 */
- (void)resetPlayingMusic
{
    // 1.重置界面数据
    self.iconView.image = [UIImage imageNamed:@"play_cover_pic_bg"];
    self.singerLabel.text = nil;
    self.songLabel.text = nil;
    self.durationLabel.text = nil;
    
    // 2.停止播放
    [HMAudioTool stopMusic:self.playingMusic.filename];
    self.player = nil;
    
    // 3.停止定时器
    [self removeCurrentTimeTimer];
    [self removeLrcTimer];
    
    // 4.设置播放按钮状态
    self.playOrPauseButton.selected = NO;
}

/**
 *  开始播放音乐
 */
- (void)startPlayingMusic
{
    if (self.playingMusic == [HMMusicTool playingMusic]) {
        [self addCurrentTimeTimer];
        [self addLrcTimer];
        return;
    }
    
    // 1.设置界面数据
    self.playingMusic = [HMMusicTool playingMusic];
    self.iconView.image = [UIImage imageNamed:self.playingMusic.icon];
    self.singerLabel.text = self.playingMusic.singer;
    self.songLabel.text = self.playingMusic.name;
    
    // 2.开始播放
    self.player = [HMAudioTool playMusic:self.playingMusic.filename];
    self.player.delegate = self;
    
    // 3.设置时长
    self.durationLabel.text = [self strWithTime:self.player.duration];
    
    // 4.开始定时器
    [self addCurrentTimeTimer];
    [self addLrcTimer];
    
    // 5.设置播放按钮状态
    self.playOrPauseButton.selected = YES;
    
    // 6.切换歌词（加载新的歌词）
    self.lrcView.lrcname = self.playingMusic.lrcname;
}

#pragma mark - 私有方法
/**
 *  时长长度 -> 时间字符串
 */
- (NSString *)strWithTime:(NSTimeInterval)time
{
    int minute = time / 60;
    int second = (int)time % 60;
    return [NSString stringWithFormat:@"%d:%d", minute, second];
}

#pragma mark - 内部控件的监听
/**
 *  退出
 */
- (IBAction)exit {
    // 移除定时器
    [self removeCurrentTimeTimer];
    [self removeLrcTimer];
    
    // 0.禁用整个app的点击事件
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    window.userInteractionEnabled = NO;
    
    // 1.动画隐藏
    [UIView animateWithDuration:1.0 animations:^{
        self.view.y = self.view.height;
    } completion:^(BOOL finished) {
        self.view.hidden = YES;
        window.userInteractionEnabled = YES;
    }];
}

- (IBAction)lyricOrPic:(UIButton *)sender {
    if (self.lrcView.isHidden) { // 显示歌词，盖住图片
        self.lrcView.hidden = NO;
        sender.selected = YES;
        
        [self addLrcTimer];
    } else { // 隐藏歌词，显示图片
        self.lrcView.hidden = YES;
        sender.selected = NO;
        
        [self removeLrcTimer];
    }
}

- (IBAction)previous {
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    window.userInteractionEnabled = NO;
    
    // 1.重置当前歌曲
    [self resetPlayingMusic];
    
    // 2.获得下一首歌曲
    [HMMusicTool setPlayingMusic:[HMMusicTool previousMusic]];
    
    // 3.播放下一首
    [self startPlayingMusic];
    
    window.userInteractionEnabled = YES;
}

- (IBAction)next {
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    window.userInteractionEnabled = NO;
    
    // 1.重置当前歌曲
    [self resetPlayingMusic];
    
    // 2.获得下一首歌曲
    [HMMusicTool setPlayingMusic:[HMMusicTool nextMusic]];
    
    // 3.播放下一首
    [self startPlayingMusic];
    
    window.userInteractionEnabled = YES;
}

- (IBAction)playOrPause {
    if (self.playOrPauseButton.isSelected) { // 暂停
        self.playOrPauseButton.selected = NO;
        [HMAudioTool pauseMusic:self.playingMusic.filename];
        [self removeCurrentTimeTimer];
        [self removeLrcTimer];
    } else { // 继续播放
        self.playOrPauseButton.selected = YES;
        [HMAudioTool playMusic:self.playingMusic.filename];
        [self addCurrentTimeTimer];
        [self addLrcTimer];
    }
}

/**
 *  点击了进度条背景
 */
- (IBAction)tapProgressBg:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:sender.view];
    
    // 切换歌曲的当前播放时间
    self.player.currentTime = (point.x / sender.view.width) * self.player.duration;
    
    [self updateCurrentTime];
}

- (IBAction)panSlider:(UIPanGestureRecognizer *)sender {
    // 获得挪动的距离
    CGPoint t = [sender translationInView:sender.view];
    [sender setTranslation:CGPointZero inView:sender.view];
    
    // 控制滑块和进度条的frame
    CGFloat sliderMaxX = self.view.width - self.slider.width;
    self.slider.x += t.x;
    if (self.slider.x < 0) {
        self.slider.x = 0;
    } else if (self.slider.x > sliderMaxX) {
        self.slider.x = sliderMaxX;
    }
    
    self.progressView.width = self.slider.center.x;
    
    // 设置时间值
    double progress = self.slider.x / sliderMaxX;
    NSTimeInterval time = self.player.duration * progress;
    [self.slider setTitle:[self strWithTime:time] forState:UIControlStateNormal];
    
    // 显示半透明指示器的文字
    [self.currentTimeView setTitle:self.slider.currentTitle forState:UIControlStateNormal];
    self.currentTimeView.x = self.slider.x;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"UIGestureRecognizerStateBegan");
        // 停止定时器
        [self removeCurrentTimeTimer];
        
        // 显示半透明指示器
        self.currentTimeView.hidden = NO;
        self.currentTimeView.y = self.currentTimeView.superview.height - 10 - self.currentTimeView.height;
    } else if (sender.state == UIGestureRecognizerStateEnded) { // 手松开
        // 设置播放器的时间
        self.player.currentTime = time;
        
        NSLog(@"UIGestureRecognizerStateEnded");
        // 开始定时器
        [self addCurrentTimeTimer];
        
        // 隐藏半透明指示器
        self.currentTimeView.hidden = YES;
    }
    
}

#pragma mark - AVAudioPlayerDelegate
/**
 *  播放器播放完毕后就会调用
 */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self next];
}

/**
 *  当播放器遇到中断的时候调用（比如来电）
 */
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    if (self.player.isPlaying) {
        [self playOrPause];
    }
}

/**
 *  当中断结束的时候调用
 */
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    
}
@end
