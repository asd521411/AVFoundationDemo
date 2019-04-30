//
//  SoundEffectViewController.m
//  AVFounddationDemo
//
//  Created by 草帽~小子 on 2019/4/30.
//  Copyright © 2019 OnePiece. All rights reserved.
//

#import "SoundEffectViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface SoundEffectViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *tableArr;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SoundEffectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"sound effect";
    
    [self setSubViews];
    
    // Do any additional setup after loading the view.
}

- (void)setSubViews {
    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"tableView";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.text = self.tableArr[indexPath.row];
        cell.backgroundColor = [self getRandomColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self playSoundEffect:self.tableArr[indexPath.row]];
}

/**
 *  播放完成回调函数
 *
 *  @param soundID    系统声音ID
 *  @param clientData 回调时传递的数据
 */

void soundCompleteCallBack(SystemSoundID soundID, void *clientData){
    NSLog(@"播放完成");
    AudioServicesDisposeSystemSoundID(soundID);
}

- (void)playSoundEffect:(NSString *)name{
    NSLog(@"音效播放");
    //获取音效文件路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:@".mp3"];
    //创建音效文件URL
    NSURL *fileUrl = [NSURL URLWithString:filePath];
    //音效声音的唯一标示ID
    SystemSoundID soundID = 0;
    //将音效加入到系统音效服务中，NSURL需要桥接成CFURLRef，会返回一个长整形ID，用来做音效的唯一标示
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    //设置音效播放完成后的回调C语言函数
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
        AudioServicesPlayAlertSoundWithCompletion(soundID, ^{
            NSLog(@"播放完成");
        });
    }else {
        AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallBack, NULL);
    };
    //开始播放音效
    AudioServicesPlaySystemSound(soundID);
    //播放音频并震动
    AudioServicesPlayAlertSound(soundID);
}

- (NSArray *)tableArr {
    if (!_tableArr) {
        _tableArr = @[@"tone0",@"tone1",@"tone2",@"tone3",@"tone4",@"tone5",@"tone6"];
    }
    return _tableArr;
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
