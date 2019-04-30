//
//  MediaViewController.m
//  AVFounddationDemo
//
//  Created by 草帽~小子 on 2019/4/25.
//  Copyright © 2019 OnePiece. All rights reserved.
//

#import "MediaViewController.h"
#import "PhotographViewController.h"

@interface MediaViewController ()
@property (nonatomic, strong) UIButton *photographBtn;
//@property (nonatomic, strong) UIButton *<#name#>;
@end

@implementation MediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cyanColor];
    
    [self setConfig];
    
    // Do any additional setup after loading the view.
}

- (void)setConfig{
    self.photographBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.photographBtn.frame = CGRectMake((self.view.frame.size.width - 100) / 2, 100, 100, 80);
    self.photographBtn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.photographBtn];
    [self.photographBtn setTitle:@"照相" forState:UIControlStateNormal];
    [self.photographBtn addTarget:self action:@selector(photographBtn:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)photographBtn:(UIButton *)sender {
    PhotographViewController *photo = [[PhotographViewController alloc] init];
    [self.navigationController pushViewController:photo animated:YES];
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
