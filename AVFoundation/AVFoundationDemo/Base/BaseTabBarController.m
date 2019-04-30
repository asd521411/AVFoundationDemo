//
//  BaseTabBarController.m
//  AVFounddationDemo
//
//  Created by 草帽~小子 on 2019/4/25.
//  Copyright © 2019 OnePiece. All rights reserved.
//

#import "BaseTabBarController.h"
#import "BaseNaviViewController.h"
#import "AudioViewController.h"
#import "VideoViewController.h"
#import "MediaViewController.h"
#import "AnimationViewController.h"

@interface BaseTabBarController ()<UITabBarControllerDelegate>
@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) NSArray *normalArr;
@property (nonatomic, strong) NSArray *selectArr;

@end

@implementation BaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10.0F], NSForegroundColorAttributeName:[UIColor colorWithRed:51 / 255.0 green:51 / 255.0 blue:51 / 255.0 alpha:1]} forState:UIControlStateSelected];
    // 字体颜色 未选中
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10.0F],  NSForegroundColorAttributeName:[UIColor colorWithRed:0xdb / 255.0 green:0xdb / 255.0 blue:0xdb / 255.0 alpha:1]} forState:UIControlStateNormal];
    
    [self setControllers];
    self.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)setControllers{
    AudioViewController *audio = [[AudioViewController alloc] init];
    VideoViewController *video = [[VideoViewController alloc] init];
    MediaViewController *media = [[MediaViewController alloc] init];
    AnimationViewController *animation = [[AnimationViewController alloc] init];
    NSArray *vcArr = @[audio, video, media, animation];
    NSMutableArray *naArr = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < vcArr.count; i++) {
        BaseNaviViewController *baseNa = [[BaseNaviViewController alloc] initWithRootViewController:vcArr[i]];
        [naArr addObject:baseNa];
        baseNa.tabBarItem.title = self.titleArr[i];
        baseNa.tabBarItem.image = [[UIImage imageNamed:self.normalArr[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        baseNa.tabBarItem.selectedImage = [[UIImage imageNamed:self.selectArr[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    self.viewControllers = [naArr copy];
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}

- (NSArray *)titleArr {
    if (_titleArr == nil) {
        _titleArr = @[@"Audio", @"Video", @"Medio", @"Animation"];
    }
    return _titleArr;
}

- (NSArray *)normalArr {
    if (_normalArr == nil) {
        _normalArr = @[@"audio", @"video", @"media", @"animation"];
    }
    return _normalArr;
}

- (NSArray *)selectArr {
    if (_selectArr == nil) {
        _selectArr = @[@"audioSele", @"videoSele", @"mediaSele", @"animationSele"];
    }
    return _selectArr;
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
