//
//  PhotographViewController.m
//  AVFounddationDemo
//
//  Created by 草帽~小子 on 2019/4/26.
//  Copyright © 2019 OnePiece. All rights reserved.
//

#import "PhotographViewController.h"
#import <AVFoundation/AVFoundation.h>
typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface PhotographViewController ()<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession *avCaptureSession;//负责输入和输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureDeviceInput *avCaptureDeviceInput;//负责从AVCaptureDevice获得输入数据

@property (strong,nonatomic) AVCaptureMovieFileOutput *captureMovieFileOutput;//视频输出流
@property (assign,nonatomic) BOOL enableRotation;//是否允许旋转（注意在视频录制过程中禁止屏幕旋转
@property (assign,nonatomic) CGRect *lastBounds;//旋转的前大小
@property (assign,nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;//后台任务标识

@property (nonatomic, strong) AVCaptureStillImageOutput *avCaptureStillImageOutput;//照片输出流
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *avCaptureVideoPreviewLayer;//相机拍摄预览图层
@property (nonatomic, strong) UIView *viewContainer;
@property (nonatomic, strong) UIButton *takeButton;//拍照按钮;
@property (nonatomic, strong) UIButton *shotChangeBtn;
@property (nonatomic, strong) UIButton *flashAutoButton;//自动闪光灯按钮
@property (nonatomic, strong) UIButton *flashOnButton;//打开闪光灯按钮
@property (nonatomic, strong) UIButton *flashOffButton;//关闭闪光灯按钮
@property (nonatomic, strong) UIImageView *focusCursor; //聚焦光标

@end

@implementation PhotographViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setConfig];
    // Do any additional setup after loading the view.
}

- (void)setConfig {
    
    self.viewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.width)];
    self.viewContainer.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:self.viewContainer];
    
    CGFloat width = 50;
    CGFloat top = self.view.frame.size.height - 100;
    CGFloat border = (self.view.frame.size.width - 50 * 5) / 6;
    self.takeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.takeButton.frame = CGRectMake(border, top, 50, 50);
    self.takeButton.backgroundColor = [self getRandomColor];
    self.takeButton.layer.cornerRadius = 25;
    self.takeButton.layer.masksToBounds = YES;
    [self.view addSubview:self.takeButton];
    [self.takeButton setBackgroundImage:[UIImage imageNamed:@"media"] forState:UIControlStateNormal];
    [self.takeButton addTarget:self action:@selector(takeButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.shotChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.shotChangeBtn.frame = CGRectMake(border * 2 + 50, top, 50, 50);
    self.shotChangeBtn.backgroundColor = [self getRandomColor];
    self.shotChangeBtn.layer.cornerRadius = 25;
    self.shotChangeBtn.layer.masksToBounds = YES;
    [self.view addSubview:self.shotChangeBtn];
    [self.shotChangeBtn setTitle:@"turn" forState:UIControlStateNormal];
    [self.shotChangeBtn addTarget:self action:@selector(shotChangeBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    self.flashAutoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.flashAutoButton.frame = CGRectMake(border * 3 + width * 2, top, 50, 50);
    self.flashAutoButton.backgroundColor = [self getRandomColor];
    self.flashAutoButton.layer.cornerRadius = 25;
    self.flashAutoButton.layer.masksToBounds = YES;
    [self.view addSubview:self.flashAutoButton];
    [self.flashAutoButton setTitle:@"auto" forState:UIControlStateNormal];
    [self.flashAutoButton addTarget:self action:@selector(flashAutoClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.flashOnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.flashOnButton.frame = CGRectMake(border * 4 + width * 3, top, 50, 50);
    self.flashOnButton.backgroundColor = [self getRandomColor];
    self.flashOnButton.layer.cornerRadius = 25;
    self.flashOnButton.layer.masksToBounds = YES;
    [self.view addSubview:self.flashOnButton];
    [self.flashOnButton setTitle:@"on" forState:UIControlStateNormal];
    [self.flashOnButton addTarget:self action:@selector(flashOnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.flashOffButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.flashOffButton.frame = CGRectMake(border * 5 + width * 4, top, 50, 50);
    self.flashOffButton.backgroundColor = [self getRandomColor];
    self.flashOffButton.layer.cornerRadius = 25;
    self.flashOffButton.layer.masksToBounds = YES;
    [self.view addSubview:self.flashOffButton];
    [self.flashOffButton setTitle:@"off" forState:UIControlStateNormal];
    [self.flashOffButton addTarget:self action:@selector(flashOffClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //在控制器视图将要展示时创建并初始化会话、摄像头设备、输入、输出、预览图层，并且添加预览图层到视图中，除此之外还做了一些初始化工作，例如添加手势（点击屏幕进行聚焦）、初始化界面等。
    //初始化会话
    _avCaptureSession = [[AVCaptureSession alloc] init];
    if ([_avCaptureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {//设置分辨率
        [_avCaptureSession setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    //获得输入设备
    AVCaptureDevice *captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得后置摄像头
    if (!captureDevice) {
        NSLog(@"取得后置摄像头时出现问题.");
        return;
    }
    
    NSError *error = nil;
    //根据输入设备初始化设备输入对象，用于获得输入数据
    _avCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
#warning 视频
    //添加一个音频输入设备
    AVCaptureDevice *audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    AVCaptureDeviceInput *audioCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:&error];
    if (error) {
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
#warning 拍照
    //初始化设备输出对象，用于获得输出数据
    _avCaptureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
#warning 视频
    //初始化设备输出对象，用于获得输出数据
    _captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc]init];
    
    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    [_avCaptureStillImageOutput setOutputSettings:outputSettings];//输出设置
    
    if ([_avCaptureSession canAddInput:_avCaptureDeviceInput]) {
        [_avCaptureSession addInput:_avCaptureDeviceInput];
#warning 视频
        [_avCaptureSession addInput:audioCaptureDeviceInput];
    }
    
    if ([_avCaptureSession canAddOutput:_avCaptureStillImageOutput]) {
        [_avCaptureSession addOutput:_avCaptureStillImageOutput];
        [_avCaptureSession addOutput:_captureMovieFileOutput];
    }
    //创建视频预览层，用于实时展示摄像头状态
    _avCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_avCaptureSession];
    CALayer *layer = self.viewContainer.layer;
    layer.masksToBounds = YES;
    _avCaptureVideoPreviewLayer.frame = layer.bounds;
    _avCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//填充模式
    //将视频预览层添加到界面中
    [layer insertSublayer:_avCaptureVideoPreviewLayer below:self.focusCursor.layer];
    
    _enableRotation = YES;
    [self addNotificationToCaptureDevice:captureDevice];
    [self addGenstureRecognizer];
    
    [self setFlashModeButtonStatus];
}
//MARK: 在控制器视图展示和视图离开界面时启动、停止会话。

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.avCaptureSession startRunning];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.avCaptureSession stopRunning];
}

-(void)dealloc{
    [self removeNotification];
}

#pragma mark - UI方法
#pragma mark 拍照
- (void)takeButton:(UIButton *)sender {
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection = [self.avCaptureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    //根据连接取得设备输出的数据
    [self.avCaptureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            //            ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
            //            [assetsLibrary writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
        }

    }];
}

- (void)shotChangeBtn:(UIButton *)sender {
    AVCaptureDevice *currentDevice = [self.avCaptureDeviceInput device];
    AVCaptureDevicePosition currentPosition = [currentDevice position];
    [self removeNotificationFromCaptureDevice:currentDevice];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition = AVCaptureDevicePositionFront;
    if (currentPosition == AVCaptureDevicePositionUnspecified||currentPosition == AVCaptureDevicePositionFront) {
        toChangePosition = AVCaptureDevicePositionBack;
    }
    toChangeDevice = [self getCameraDeviceWithPosition:toChangePosition];
    [self addNotificationToCaptureDevice:toChangeDevice];
    //获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:toChangeDevice error:nil];
    
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.avCaptureSession beginConfiguration];
    //移除原有输入对象
    [self.avCaptureSession removeInput:self.avCaptureDeviceInput];
    //添加新的输入对象
    if ([self.avCaptureSession canAddInput:toChangeDeviceInput]) {
        [self.avCaptureSession addInput:toChangeDeviceInput];
        self.avCaptureDeviceInput = toChangeDeviceInput;
    }
    //提交会话配置
    [self.avCaptureSession commitConfiguration];
    
    [self setFlashModeButtonStatus];
}

#pragma mark 自动闪光灯开启
- (void)flashAutoClick:(UIButton *)sender {
    [self setFlashMode:AVCaptureFlashModeAuto];
    [self setFlashModeButtonStatus];
}
#pragma mark 打开闪光灯
- (void)flashOnClick:(UIButton *)sender {
    [self setFlashMode:AVCaptureFlashModeOn];
    [self setFlashModeButtonStatus];
}
#pragma mark 关闭闪光灯
- (void)flashOffClick:(UIButton *)sender {
    [self setFlashMode:AVCaptureFlashModeOff];
    [self setFlashModeButtonStatus];
}
#pragma mark - 通知
/**
 *  给输入设备添加通知
 */
-(void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice{
    //注意添加区域改变捕获通知必须首先设置设备允许捕获
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled = YES;
    }];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    //捕获区域发生改变
    [notificationCenter addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
-(void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
/**
 *  移除所有通知
 */
-(void)removeNotification{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

-(void)addNotificationToCaptureSession:(AVCaptureSession *)captureSession{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    //会话出错
    [notificationCenter addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:captureSession];
}

/**
 *  设备连接成功
 *
 *  @param notification 通知对象
 */
-(void)deviceConnected:(NSNotification *)notification{
    NSLog(@"设备已连接...");
}
/**
 *  设备连接断开
 *
 *  @param notification 通知对象
 */
-(void)deviceDisconnected:(NSNotification *)notification{
    NSLog(@"设备已断开.");
}
/**
 *  捕获区域改变
 *
 *  @param notification 通知对象
 */
-(void)areaChange:(NSNotification *)notification{
    NSLog(@"捕获区域改变...");
}

/**
 *  会话出错
 *
 *  @param notification 通知对象
 */
-(void)sessionRuntimeError:(NSNotification *)notification{
    NSLog(@"会话发生错误.");
}
//MARK: 定义闪光灯开闭及自动模式功能，注意无论是设置闪光灯、白平衡还是其他输入设备属性，在设置之前必须先锁定配置，修改完后解锁。
/**
 *  改变设备属性的统一操作方法
 *
 *  @param propertyChange 属性改变操作
 */
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice = [self.avCaptureDeviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

/**
 *  设置闪光灯模式
 *
 *  @param flashMode 闪光灯模式
 */
-(void)setFlashMode:(AVCaptureFlashMode )flashMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}


/**
 *  设置聚焦模式
 *
 *  @param focusMode 聚焦模式
 */
-(void)setFocusMode:(AVCaptureFocusMode )focusMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}
/**
 *  设置曝光模式
 *
 *  @param exposureMode 曝光模式
 */
-(void)setExposureMode:(AVCaptureExposureMode)exposureMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
    }];
}
/**
 *  设置聚焦点
 *
 *  @param point 聚焦点
 */
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

/**
 *  添加点按手势，点按时聚焦
 */
-(void)addGenstureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [self.viewContainer addGestureRecognizer:tapGesture];
}
-(void)tapScreen:(UITapGestureRecognizer *)tapGesture{
    CGPoint point = [tapGesture locationInView:self.viewContainer];
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint = [self.avCaptureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

/**
 *  设置闪光灯按钮状态
 */
-(void)setFlashModeButtonStatus{
    AVCaptureDevice *captureDevice = [self.avCaptureDeviceInput device];
    AVCaptureFlashMode flashMode = captureDevice.flashMode;
    if([captureDevice isFlashAvailable]){
        self.flashAutoButton.hidden = NO;
        self.flashOnButton.hidden = NO;
        self.flashOffButton.hidden = NO;
        self.flashAutoButton.enabled = YES;
        self.flashOnButton.enabled = YES;
        self.flashOffButton.enabled = YES;
        switch (flashMode) {
            case AVCaptureFlashModeAuto:
                self.flashAutoButton.enabled = NO;
                break;
            case AVCaptureFlashModeOn:
                self.flashOnButton.enabled = NO;
                break;
            case AVCaptureFlashModeOff:
                self.flashOffButton.enabled = NO;
                break;
            default:
                break;
        }
    }else{
        self.flashAutoButton.hidden=YES;
        self.flashOnButton.hidden=YES;
        self.flashOffButton.hidden=YES;
    }
}

/**
 *  设置聚焦光标位置
 *
 *  @param point 光标位置
 */
-(void)setFocusCursorWithPoint:(CGPoint)point{
    self.focusCursor.center = point;
    self.focusCursor.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursor.alpha = 1.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.focusCursor.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursor.alpha = 0;
    }];
}

#pragma mark - 私有方法

/**
 *  取得指定位置的摄像头
 *
 *  @param position 摄像头位置
 *
 *  @return 摄像头设备
 */
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
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
