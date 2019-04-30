//
//  AudioViewController.m
//  AVFounddationDemo
//
//  Created by 草帽~小子 on 2019/4/25.
//  Copyright © 2019 OnePiece. All rights reserved.
//

#import "AudioViewController.h"
#import "SoundEffectViewController.h"

#import <AVFoundation/AVFoundation.h>

#define kRecordAudioFile @"myRecord.caf"

@interface AudioViewController ()<AVAudioRecorderDelegate>

@property (nonatomic, strong) UIButton *soundEffectBtn;

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIButton *pauseBtn;
@property (nonatomic, strong) UIButton *stopBtn;
@property (nonatomic, strong) UIButton *startBtn;
@property (nonatomic, strong) UIButton *resume;

@end

@implementation AudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"Audio";
    
/**
 *添加权限
 <key>NSCameraUsageDescription</key>
 <string>***需要您的同意,才能访问相机</string>
 <key>NSMicrophoneUsageDescription</key>
 <string>***需要您的同意,才能访问麦克风</string>
 */
    
    
    [self setSubViews];
    //[self setConfig];
    //[self setAudioSession];
    //[self speakHintMessage];
    
    // Do any additional setup after loading the view.
}

- (void)setSubViews {
    CGFloat width = 100;
    CGFloat height = 40;
    CGFloat border = (self.view.frame.size.width - width) / 2;
    CGFloat top = 100;
    
    self.soundEffectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.soundEffectBtn.frame = CGRectMake(border, top, width, height);
    self.soundEffectBtn.backgroundColor = [self getRandomColor];
    [self.view addSubview:self.soundEffectBtn];
    [self.soundEffectBtn setTitle:@"音效" forState:UIControlStateNormal];
    [self.soundEffectBtn addTarget:self action:@selector(soundEffectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)soundEffectBtnClick:(UIButton *)sender {
    SoundEffectViewController *sound = [[SoundEffectViewController alloc] init];
    [self.navigationController pushViewController:sound animated:YES];
}


- (void)setConfig{
    //width = 60, height = 40
    CGFloat width = 60;
    CGFloat height = 40;
    CGFloat border = (self.view.frame.size.width - width * 4) / 5;
    CGFloat top = self.view.frame.size.height - 100;
    
    self.startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.startBtn.frame = CGRectMake(border, top, width, height);
    self.startBtn.backgroundColor = [self getRandomColor];
    [self.view addSubview:self.startBtn];
    [self.startBtn setTitle:@"start" forState:UIControlStateNormal];
    [self.startBtn addTarget:self action:@selector(startBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    self.stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.stopBtn.frame = CGRectMake(border * 2 + width, top, width, height);
    self.stopBtn.backgroundColor = [self getRandomColor];
    [self.view addSubview:self.stopBtn];
    [self.stopBtn setTitle:@"stop" forState:UIControlStateNormal];
    [self.stopBtn addTarget:self action:@selector(stopBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    self.pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.pauseBtn.frame = CGRectMake(border * 3 + width * 2, top, width, height);
    self.pauseBtn.backgroundColor = [self getRandomColor];
    [self.view addSubview:self.pauseBtn];
    [self.pauseBtn setTitle:@"pause" forState:UIControlStateNormal];
    [self.pauseBtn addTarget:self action:@selector(pauseBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    self.resume = [UIButton buttonWithType:UIButtonTypeCustom];
    self.resume.frame = CGRectMake(border * 4 + width * 3, top, width, height);
    self.resume.backgroundColor = [self getRandomColor];
    [self.view addSubview:self.resume];
    [self.resume setTitle:@"resume" forState:UIControlStateNormal];
    [self.resume addTarget:self action:@selector(resumeBtn:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)speakHintMessage{
    
    // 这样子可以简单的播放一段语音
    AVSpeechSynthesizer * synthesizer = [[AVSpeechSynthesizer alloc]init];
    // Utterance 表达方式
    AVSpeechSynthesisVoice * voice  = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    AVSpeechUtterance  * utterance = [[AVSpeechUtterance alloc]initWithString:@"准备了猪，开始录制视频了"];
    utterance.rate  = 1.5; // 这个是播放速率 默认1.0
    utterance.voice = voice;
    utterance.pitchMultiplier = 0.8;        // 可在播放待定语句时候改变声调
    utterance.postUtteranceDelay = 0.1; // 语音合成器在播放下一条语句的时候有短暂的停顿  这个属性指定停顿的时间
    [synthesizer speakUtterance:utterance];
    
}

/**
 *  设置音频会话
 */
- (void)setAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //设置为播放和录音转态，录音之后可以播放
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
- (NSURL *)getSavePath {
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *urlPth = [urlStr stringByAppendingPathComponent:kRecordAudioFile];
    NSURL *url = [NSURL fileURLWithPath:urlPth];
    return url;
}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}

/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url = [self getSavePath];
        //创建录音格式设置
        NSDictionary *setting = [self getAudioSetting];
        //创建录音机
        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

/**
 *  创建播放器
 *
 *  @return 播放器
 */
-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSURL *url = [self getSavePath];
        NSError *error = nil;
        _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops = 0;
        [_audioPlayer prepareToPlay];
        if (error) {
            NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}

/**
 *  录音声波监控定制器
 *
 *  @return 定时器
 */
-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

/**
 *  录音声波状态设置
 */
-(void)audioPowerChange{
    [self.audioRecorder updateMeters];//更新测量值
    float power = [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    //CGFloat progress=(1.0/160.0)*(power+160.0);
    //[self.audioPower setProgress:progress];
}


#pragma mark - UI事件
/**
 *  点击录音按钮
 *
 *  @param sender 录音按钮
 */
- (void)startBtn:(UIButton *)sender{
    if (![self.audioRecorder isRecording]) {
        [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
        self.timer.fireDate = [NSDate distantPast];
    }
}

/**
 *  点击暂定按钮
 *
 *  @param sender 暂停按钮
 */
- (void)pauseBtn:(UIButton *)sender{
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder pause];
        self.timer.fireDate = [NSDate distantFuture];
    }
}

/**
 *  点击恢复按钮
 *  恢复录音只需要再次调用record，AVAudioSession会帮助你记录上次录音位置并追加录音
 *
 *  @param sender 恢复按钮
 */
- (void)resumeBtn:(UIButton *)sender{
    [self startBtn:sender];
}


/**
 *  点击停止按钮
 *
 *  @param sender 停止按钮
 */
- (void)stopBtn:(UIButton *)sender{
    [self.audioRecorder stop];
    self.timer.fireDate = [NSDate distantFuture];
    //self.audioPower.progress=0.0;
}

#pragma mark - 录音机代理方法
/**
 *  录音完成，录音完成后播放录音
 *
 *  @param recorder 录音机对象
 *  @param flag     是否成功
 */
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
    }
    NSLog(@"录音完成!");
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
