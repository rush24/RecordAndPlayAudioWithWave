//
//  ViewController.m
//  playVoiceDemo1
//
//  Created by 张智勇 on 16/3/29.
//  Copyright © 2016年 张智勇. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SCSiriWaveformView.h"

@interface ViewController ()<AVAudioRecorderDelegate,AVAudioPlayerDelegate>

@property (nonatomic,strong) AVAudioRecorder *audioRecorder; //音频录音机
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;     //音频播放器
@property (nonatomic,strong) NSTimer *timer;            //刷新声波的定时器
@property (nonatomic,strong) SCSiriWaveformView *waveView;  //声波视图

@property (nonatomic,strong) UIButton *recordButton;
@property (nonatomic,strong) UIButton *finishButton;
@property (nonatomic,strong) UIButton *reRecordButton;
@property (nonatomic,strong) UIButton *playButton;
@property (nonatomic,strong) UIButton *cancelButton;
@property (nonatomic,strong) UILabel *timeLabel;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setViews];
    [self setAudioSession];

}

- (void)setViews{
    
    UIButton *recordButton = [[UIButton alloc]initWithFrame:CGRectMake(120, 40, 80, 40)];
    [recordButton setTitle:@"开始" forState:UIControlStateNormal];
    [recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(record) forControlEvents:UIControlEventTouchUpInside];
    _recordButton = recordButton;
    [self.view addSubview:recordButton];
    
    UIButton *finishButton = [[UIButton alloc]initWithFrame:CGRectMake(120, 100, 80, 40)];
    [finishButton setTitle:@"完成" forState:UIControlStateNormal];
    [finishButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [finishButton addTarget:self action:@selector(finishRecording) forControlEvents:UIControlEventTouchUpInside];
    _finishButton = finishButton;
    [self.view addSubview:finishButton];
    
    UIButton *playButton = [[UIButton alloc]initWithFrame:CGRectMake(40, 70, 80, 40)];
    [playButton setTitle:@"播放" forState:UIControlStateNormal];
    [playButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    _playButton = playButton;
    [self.view addSubview:playButton];
    
    UIButton *reRecordButton = [[UIButton alloc]initWithFrame:CGRectMake(200, 70, 80, 40)];
    [reRecordButton setTitle:@"重录" forState:UIControlStateNormal];
    [reRecordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [reRecordButton addTarget:self action:@selector(reRecord) forControlEvents:UIControlEventTouchUpInside];
    _reRecordButton = reRecordButton;
    [self.view addSubview:reRecordButton];
    
    UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(120, 200, 80, 40)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton = cancelButton;
    [self.view addSubview:cancelButton];
    
    UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 260, 120, 40)];
    [timeLabel setTextColor:[UIColor blackColor]];
    [timeLabel setTextAlignment:NSTextAlignmentCenter];
    _timeLabel = timeLabel;
    [self.view addSubview:timeLabel];
    
    _waveView = [[SCSiriWaveformView alloc]initWithFrame:CGRectMake(0, 400, 320, 168)];
    _waveView.backgroundColor = [self.view backgroundColor];
    [_waveView setWaveColor:[UIColor whiteColor]];
    [_waveView setPrimaryWaveLineWidth:2.0f];
    [_waveView setSecondaryWaveLineWidth:1.0];
    [self.view addSubview:_waveView];
    
    //隐藏录音前不应该出现的按钮
    _finishButton.hidden = YES;
    _playButton.hidden = YES;
    _reRecordButton.hidden = YES;

}

/**
 *  设置音频会话
 */
- (void)setAudioSession{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

/**
 *  录音文件设置
 *
 *  @return 返回录音设置
 */
- (NSDictionary *)getAudioSetting
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];  //设置录音格式
    [dic setObject:@(44100.0) forKey:AVSampleRateKey];                 //设置采样率
    [dic setObject:@(1) forKey:AVNumberOfChannelsKey];              //设置通道，这里采用单声道
    [dic setObject:@(32) forKey:AVLinearPCMBitDepthKey];             //每个采样点位数，分为8，16，24，32
    [dic setObject:@(YES) forKey:AVLinearPCMIsFloatKey];            //是否使用浮点数采样
    [dic setObject:@(AVAudioQualityMax) forKey:AVEncoderAudioQualityKey];
    return dic;
}

/**
 *  录音存储路径
 *
 *  @return 返回存储路径
 */
- (NSURL *)getSavePath
{
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"voice1.pcm"]];
    NSLog(@"url: %@",url);
    return url;
}

- (AVAudioRecorder *)audioRecorder
{
    if (!_audioRecorder) {
        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[self getSavePath] settings:[self getAudioSetting] error:&error];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES; //是否启用录音测量，如果启用录音测量可以获得录音分贝等数据信息
        if (error) {
            NSLog(@"创建录音机对象发生错误:%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

- (AVAudioPlayer *)audioPlayer
{
    if (!_audioPlayer) {
        NSError *error = nil;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[self getSavePath] error:&error];
        _audioPlayer.delegate = self;
        _audioPlayer.meteringEnabled = YES;
        if (error) {
            NSLog(@"创建音频播放器对象发生错误:%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}

#pragma mark - AVAudioRecorderDelegate
//录音成功
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"录音成功!");
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"播放完毕");
    [_playButton setTitle:@"播放" forState:UIControlStateNormal];
    self.timer.fireDate = [NSDate distantFuture];
    [_waveView updateWithLevel:-160];   //waveView没有输入状态
    self.audioPlayer = nil;
}

#pragma mark - Action
- (void)recordPowerChange{
    [self.audioRecorder updateMeters];  //更新测量值
    CGFloat power = pow (10, [_audioRecorder averagePowerForChannel:0] / 60); //取得第一个通道的音频，注意音频强度范围时-160到0
    NSLog(@"--record: %f",power);
    [_waveView updateWithLevel:power];
    [_timeLabel setText:[NSString stringWithFormat:@"%d秒",(int)self.audioRecorder.currentTime]];

}

- (void)playPowerChange{
    [self.audioPlayer updateMeters];  //更新测量值
    CGFloat power = pow (10, [_audioPlayer averagePowerForChannel:0] / 60); //取得第一个通道的音频，注意音频强度范围时-160到0
    NSLog(@"--play: %f",power);
    [_waveView updateWithLevel:power];
}

//- (NSString *)calCurrentRecordTime{
//    NSTimeInterval currentRecordTime = _startTime - self.audioRecorder.currentTime;
//    NSLog(@"-----%d",(int)self.audioRecorder.currentTime);
//    int hour = (int)(currentRecordTime/3600);
//    int minute = (int)(currentRecordTime - hour*3600)/60;
//    int second = currentRecordTime - hour*3600 - minute*60;
//    return [NSString stringWithFormat:@"%d秒",second];
//}

- (void)record{
    [_waveView setWaveColor:[UIColor grayColor]];
    
    if (![self.audioRecorder isRecording]) {    //不是正在录制
        NSLog(@"录制");
        //隐藏录制时需要隐藏的按钮
        _reRecordButton.hidden = YES;
        _playButton.hidden = YES;
        _finishButton.hidden = YES;
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(recordPowerChange) userInfo:nil repeats:YES];
        [self.audioRecorder record];
        self.timer.fireDate = [NSDate distantPast]; //开启定时器
        [_recordButton setTitle:@"暂停" forState:UIControlStateNormal];
    }else{  //正在录制
        NSLog(@"暂停");
        //显示暂停后需要显示的按钮
        _finishButton.hidden = NO;
        
        [self.audioRecorder pause];
        self.timer.fireDate = [NSDate distantFuture];   //停止计时器
        [_waveView updateWithLevel:-160];   //waveView没有输入状态
        [_recordButton setTitle:@"开始" forState:UIControlStateNormal];

    }
}

- (void)reRecord{
    NSLog(@"重录");
    if([self.audioPlayer isPlaying]){
        [self.audioPlayer stop];
        self.timer.fireDate = [NSDate distantFuture];
    }
    self.audioPlayer = nil;
    [self.audioRecorder deleteRecording];
    [_waveView updateWithLevel:-160];   //waveView没有输入状态
    [_playButton setTitle:@"播放" forState:UIControlStateNormal];
    
    _recordButton.hidden = NO;
    _reRecordButton.hidden = YES;
    _playButton.hidden = YES;
}

- (void)finishRecording{
    NSLog(@"完成");
    
    //隐藏和显示按钮
    _finishButton.hidden = YES;
    _recordButton.hidden = YES;
    _playButton.hidden = NO;
    _reRecordButton.hidden = NO;
    
    [self.audioRecorder stop];
    self.timer.fireDate = [NSDate distantFuture];

}

- (void)play{
    NSLog(@"播放");
    
    if([self.audioPlayer isPlaying]){   //正在播放
        [self.audioPlayer pause];
        self.timer.fireDate = [NSDate distantFuture]; //关闭定时器
        [_waveView updateWithLevel:-160];   //waveView没有输入状态
        [_playButton setTitle:@"播放" forState:UIControlStateNormal];
    }else{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(playPowerChange) userInfo:nil repeats:YES];
        self.timer.fireDate = [NSDate distantPast]; //开启定时器
        [self.audioPlayer play];
        [_playButton setTitle:@"暂停" forState:UIControlStateNormal];
    }
}

- (void)cancel{
    [self.audioRecorder stop];
    [self.audioPlayer stop];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filepath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"voice1.caf"];
    if([fileManager fileExistsAtPath:filepath]){
        [self.audioRecorder deleteRecording];
    }
    
    self.timer.fireDate = [NSDate distantFuture];
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"取消,退出当前界面");

}

@end
