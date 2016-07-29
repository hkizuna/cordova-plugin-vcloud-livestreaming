//
//  LiveStreamingViewController.m
//
//  Created by xwang on 24/05/16.
//
//

#import "LiveStreamingViewController.h"
#import "UIView+Toast.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@class QualityViewController;

@interface QualityView : UIView
@property (nonatomic, strong) UIButton *mediumQualityButton;
@property (nonatomic, strong) UIButton *highQualityButton;
@property (nonatomic, strong) UIButton *superQualityButton;
@end

@implementation QualityView

LSVideoStreamingQuality streamingQuality = LS_VIDEO_QUALITY_SUPER;

- (id)init
{
  self = [super initWithFrame:CGRectZero];
  if (self) {
    [self createUI];
  }
  return self;
}

- (id)initWith:(LSVideoStreamingQuality) quality
{
  streamingQuality = quality;
  return [self init];
}

- (void)createUI
{
  self.mediumQualityButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.mediumQualityButton.tag = 1;
  self.mediumQualityButton.frame = CGRectMake(10, 0, 44, 44);
  self.mediumQualityButton.titleLabel.font = [UIFont systemFontOfSize:13];
  [self.mediumQualityButton setBackgroundImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-unselected"] forState:UIControlStateNormal];
  [self.mediumQualityButton setTitle:@"标清" forState:UIControlStateNormal];
  [self.mediumQualityButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
  [self.mediumQualityButton setTitleColor:UIColorFromRGB(0x393b43) forState:UIControlStateNormal];
  [self.mediumQualityButton addTarget:self action:@selector(onSelected:) forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:self.mediumQualityButton];

  self.highQualityButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.highQualityButton.tag = 2;
  self.highQualityButton.frame = CGRectMake(78, 0, 44, 44);
  self.highQualityButton.titleLabel.font = [UIFont systemFontOfSize:13];
  [self.highQualityButton setBackgroundImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-unselected"] forState:UIControlStateNormal];
  [self.highQualityButton setTitle:@"高清" forState:UIControlStateNormal];
  [self.highQualityButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
  [self.highQualityButton setTitleColor:UIColorFromRGB(0x393b43) forState:UIControlStateNormal];
  [self.highQualityButton addTarget:self action:@selector(onSelected:) forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:self.highQualityButton];

  self.superQualityButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.superQualityButton.tag = 3;
  self.superQualityButton.frame = CGRectMake(146, 0, 44, 44);
  self.superQualityButton.titleLabel.font = [UIFont systemFontOfSize:13];
  [self.superQualityButton setBackgroundImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-unselected"] forState:UIControlStateNormal];
  [self.superQualityButton setTitle:@"超清" forState:UIControlStateNormal];
  [self.superQualityButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
  [self.superQualityButton setTitleColor:UIColorFromRGB(0x393b43) forState:UIControlStateNormal];
  [self.superQualityButton addTarget:self action:@selector(onSelected:) forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:self.superQualityButton];

  switch (streamingQuality) {
    case LS_VIDEO_QUALITY_MEDIUM:
      [self.mediumQualityButton setBackgroundImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-selected"] forState:UIControlStateNormal];
      break;
    case LS_VIDEO_QUALITY_HIGH:
      [self.highQualityButton setBackgroundImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-selected"] forState:UIControlStateNormal];
      break;
    case LS_VIDEO_QUALITY_SUPER:
      [self.superQualityButton setBackgroundImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-selected"] forState:UIControlStateNormal];
      break;
    default:
      break;
  }
}

- (void)onSelected:(id)sender
{
  [self.mediumQualityButton setBackgroundImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-unselected"] forState:UIControlStateNormal];
  [self.highQualityButton setBackgroundImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-unselected"] forState:UIControlStateNormal];
  [self.superQualityButton setBackgroundImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-unselected"] forState:UIControlStateNormal];
  switch ([sender tag]) {
    case 1:
      [self.mediumQualityButton setBackgroundImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-selected"] forState:UIControlStateNormal];
      streamingQuality = LS_VIDEO_QUALITY_MEDIUM;
      break;
    case 2:
      [self.highQualityButton setBackgroundImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-selected"] forState:UIControlStateNormal];
      streamingQuality = LS_VIDEO_QUALITY_HIGH;
      break;
    case 3:
      [self.superQualityButton setBackgroundImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-selected"] forState:UIControlStateNormal];
      streamingQuality = LS_VIDEO_QUALITY_SUPER;
      break;
  }
}

- (LSVideoStreamingQuality)streamingQuality
{
  return streamingQuality;
}

@end

@interface QualityViewController : UIViewController
@end

@implementation QualityViewController

LSVideoStreamingQuality presentQuality = LS_VIDEO_QUALITY_SUPER;

- (id) initWith:(LSVideoStreamingQuality) quality
{
  presentQuality = quality;
  return [self init];
}

- (void)loadView
{
  self.view = [[QualityView alloc] initWith:presentQuality];
}

- (LSVideoStreamingQuality)streamingQuality
{
  return [((QualityView *) self.view) streamingQuality];
}

- (CGSize)preferredContentSize
{
  return CGSizeMake(200.0f, 44.0f);
}

@end

@interface UIAlertController (ContentViewController)
@property (nonatomic,retain) UIViewController * contentViewController;
@end

@interface LiveStreamingViewController()

@property (nonatomic, strong) UIView *streamingView;
@property (nonatomic, strong) UIControl *streamingOverlay;
@property (nonatomic, strong) UIControl *controlOverlay;
@property (nonatomic, strong) UIView *topControlView;
@property (nonatomic, strong) UIView *bottomControlView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *playButtonBack;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *qualityButton;
@property (nonatomic, strong) UIButton *micButton;
@property (nonatomic, strong) UIButton *channelButton;
@property (nonatomic, strong) UIButton *snapshotButton;
@property (nonatomic, strong) UITextView *channelTextView;
@property (nonatomic, strong) LSMediaCapture *mediaCapture;
@property (nonatomic, strong) UIProgressView *blowLevelProgress;

@end

@implementation LiveStreamingViewController

CGFloat screenWidth;
CGFloat screenHeight;

BOOL statusBarHide = NO;
BOOL onAir = NO;
BOOL flashOn = NO;
BOOL audioOn = YES;
BOOL videoOn = YES;
BOOL micOn = YES;
BOOL channelOn = YES;

AVAudioRecorder *recorder;
NSTimer *volumeLevelTimer;
const float ALPHA = 0.05f;
float lowPassResults = 0.0f;
float blowLevel = 0.0f;

LSVideoStreamingQuality currentStreamingQuality = LS_VIDEO_QUALITY_SUPER;

- (instancetype)initWithURL:(NSString *)url title:(NSString *)title andOptions:(NSDictionary *)options
{
  self = [self initWithNibName:nil bundle:nil];
  if (self) {
    self.url = url;
    self.streamingTitle = title;
    self.options = options;
  }
  [self initBlowDetection];
  return self;
}

- (void)initBlowDetection
{
  NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                            [NSNumber numberWithInt:kAudioFormatAppleLossless], AVFormatIDKey,
                            [NSNumber numberWithInt:0], AVNumberOfChannelsKey,
                            [NSNumber numberWithInt:AVAudioQualityMax], AVEncoderAudioQualityKey, nil];

  AVAudioSession *audioSession = [AVAudioSession sharedInstance];
  [audioSession setActive:YES error:nil];
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
  recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:@"/dev/null"] settings:settings error:nil];
  if (recorder) {
    [recorder prepareToRecord];
    recorder.meteringEnabled = TRUE;
    [recorder record];
    volumeLevelTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES];
  }
}

- (void)levelTimerCallback:(NSTimer *)timer {
  [recorder updateMeters];
  float peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
  lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
  if (lowPassResults > 0.5) {
    blowLevel = lowPassResults * 2 - 1.0;
  }
  else {
    blowLevel = 0.0f;
  }
  [self.blowLevelProgress setProgress:1 - blowLevel animated:YES];
}
- (void)addChannelName:(NSString *)name andMessage:(NSString *)message
{
  NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.channelTextView.attributedText];
  NSMutableAttributedString *newAttributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@\n", name, message] attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
  [newAttributedText addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x28ECFD) range:NSMakeRange(0, name.length)];
  [attributedText appendAttributedString:newAttributedText];
  self.channelTextView.attributedText = attributedText;
  [self.channelTextView scrollRangeToVisible:NSMakeRange(0, self.channelTextView.attributedText.length - 1)];
}

- (void)loadView
{
  // swapped for landscape orientation
  screenHeight = CGRectGetWidth([UIScreen mainScreen].bounds);
  screenWidth = CGRectGetHeight([UIScreen mainScreen].bounds);

  self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
  self.streamingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];

  // streaming overlay
  self.streamingOverlay = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
  [self.streamingOverlay addTarget:self action:@selector(onClickStreamingOverlay:) forControlEvents:UIControlEventTouchDown];

  // control overlay
  self.controlOverlay = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
  [self.controlOverlay addTarget:self action:@selector(onClickControlOverlay:) forControlEvents:UIControlEventTouchDown];

  // top control view
  self.topControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 64)];
  self.topControlView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];

  // back button
  self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.backButton setTitle:@"完成" forState:UIControlStateNormal];
  self.backButton.frame = CGRectMake(0, 20, 44, 44);
  [self.backButton addTarget:self action:@selector(onClickBack:) forControlEvents:UIControlEventTouchUpInside];
  [self.topControlView addSubview:self.backButton];

  // title label
  self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44 + 12.5, 20, screenWidth - 198 - 12.5, 44)];
  self.titleLabel.text = self.streamingTitle;
  self.titleLabel.textAlignment = NSTextAlignmentLeft;
  self.titleLabel.textColor = [UIColor whiteColor];
  [self.topControlView addSubview:self.titleLabel];

  // flash button
  self.flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.flashButton setImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-bolt"] forState:UIControlStateNormal];
  self.flashButton.frame = CGRectMake(screenWidth - 198, 20, 44, 44);
  [self.flashButton addTarget:self action:@selector(onClickCameraFlash:) forControlEvents:UIControlEventTouchUpInside];
  [self.topControlView addSubview:self.flashButton];

  // camera button
  self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.cameraButton setImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-reverse-camera"] forState:UIControlStateNormal];
  self.cameraButton.frame = CGRectMake(screenWidth - 132, 20, 44, 44);
  [self.cameraButton addTarget:self action:@selector(onClickSwitchCamera:) forControlEvents:UIControlEventTouchUpInside];
  [self.topControlView addSubview:self.cameraButton];

  // quality button
  self.qualityButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.qualityButton setImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-quality"] forState:UIControlStateNormal];
  self.qualityButton.frame = CGRectMake(screenWidth - 66, 20, 44, 44);
  [self.qualityButton addTarget:self action:@selector(onClickQuality:) forControlEvents:UIControlEventTouchUpInside];
  [self.topControlView addSubview:self.qualityButton];

  // bottom control view
  self.bottomControlView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight - 44, screenWidth, 44)];
  self.bottomControlView.backgroundColor = [UIColor blackColor];
  self.bottomControlView.alpha = 0.7;

  // play button back
  self.playButtonBack = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/2 - 61/2, -20, 61, 61)];
  self.playButtonBack.layer.cornerRadius = 61/2;
  self.playButtonBack.backgroundColor = [UIColor blackColor];
  [self.bottomControlView addSubview:self.playButtonBack];

  // play button
  self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.playButton setImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-play"] forState:UIControlStateNormal];
  self.playButton.frame = CGRectMake(screenWidth/2 - 60/2, screenHeight - 64, 60, 60);
  [self.playButton addTarget:self action:@selector(onClickPlay:) forControlEvents:UIControlEventTouchUpInside];

  // mic button
  self.micButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.micButton setImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-mic"] forState:UIControlStateNormal];
  self.micButton.frame = CGRectMake(12.5, 0, 44, 44);
  [self.micButton addTarget:self action:@selector(onClickMic:) forControlEvents:UIControlEventTouchUpInside];
  [self.bottomControlView addSubview:self.micButton];

  // blow level progress
  self.blowLevelProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
  self.blowLevelProgress.layer.frame = CGRectMake(43, 15.5, 100, 13);
  [self.blowLevelProgress setProgressTintColor:[UIColor blackColor]];
  [self.blowLevelProgress setTrackImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-volume-level-progress"]];
  [self.blowLevelProgress setProgress:1 animated:YES];
  self.blowLevelProgress.transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
  [self.bottomControlView addSubview:self.blowLevelProgress];

  // channel button
  self.channelButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.channelButton setImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-chat"] forState:UIControlStateNormal];
  self.channelButton.frame = CGRectMake(screenWidth - 132, 0, 44, 44);
  [self.channelButton addTarget:self action:@selector(onClickChannel:) forControlEvents:UIControlEventTouchUpInside];
  [self.bottomControlView addSubview:self.channelButton];

  // snapshot button
  self.snapshotButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.snapshotButton setImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-camera"] forState:UIControlStateNormal];
  self.snapshotButton.frame = CGRectMake(screenWidth - 66, 0, 44, 44);
  [self.snapshotButton addTarget:self action:@selector(onClickSnapsot:) forControlEvents:UIControlEventTouchUpInside];
  [self.bottomControlView addSubview:self.snapshotButton];

  // channel text view
  self.channelTextView = [[UITextView alloc] initWithFrame:CGRectMake(screenWidth - 140 - 7.5, 64 + 7.5, 140, screenHeight - 64 - 44 - 15)];
  self.channelTextView.returnKeyType = UIReturnKeyDone;
  self.channelTextView.backgroundColor = [UIColor clearColor];
  self.channelTextView.font = [UIFont systemFontOfSize:15];
  self.channelTextView.textColor = [UIColor whiteColor];
  self.channelTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
  self.channelTextView.selectable = NO;

  [self.controlOverlay addSubview:self.topControlView];
  [self.controlOverlay addSubview:self.bottomControlView];
  [self.controlOverlay addSubview:self.channelTextView];
  [self.controlOverlay addSubview:self.playButton];
  [self.streamingOverlay addSubview:self.controlOverlay];

  [self.view addSubview:self.streamingView];
  [self.view addSubview:self.streamingOverlay];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
  [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];

  // remove notifiations
  [[NSNotificationCenter defaultCenter] removeObserver:self name:LS_LiveStreaming_Started object:self.mediaCapture];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:LS_LiveStreaming_Finished object:self.mediaCapture];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:LS_LiveStreaming_Bad object:self.mediaCapture];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // request accesses
  BOOL granted = [self requestMediaCapturerAccessWithCompletionHandler:^(BOOL value, NSError *error) {
    if (error) {
      NSLog(@"%@",[error localizedDescription]);
    }
  }];
  if (!granted) {
    return;
  }

  // set streaming options
  LSLiveStreamingParaCtx paraCtx;
  paraCtx.eOutStreamType = LS_HAVE_AV;
  paraCtx.eOutFormatType = LS_OUT_FMT_RTMP;
  paraCtx.eHaraWareEncType = NO;

  // set video
  paraCtx.sLSVideoParaCtx.fps = 25;
  paraCtx.sLSVideoParaCtx.codec = LS_VIDEO_CODEC_H264;
  paraCtx.sLSVideoParaCtx.videoStreamingQuality = LS_VIDEO_QUALITY_SUPER;
  paraCtx.sLSVideoParaCtx.cameraPosition = LS_CAMERA_POSITION_BACK;
  paraCtx.sLSVideoParaCtx.interfaceOrientation = LS_CAMERA_ORIENTATION_RIGHT;
  paraCtx.sLSVideoParaCtx.videoRenderMode = LS_VIDEO_RENDER_MODE_SCALE_NONE;
  paraCtx.sLSVideoParaCtx.isCameraFlashEnabled = YES;
  paraCtx.sLSVideoParaCtx.isCameraZoomPinchGestureOn = NO;
  paraCtx.sLSVideoParaCtx.isVideoWaterMarkEnabled = YES;

  // set audio
  paraCtx.sLSAudioParaCtx.bitrate = 64000;
  paraCtx.sLSAudioParaCtx.codec = LS_AUDIO_CODEC_AAC;
  paraCtx.sLSAudioParaCtx.frameSize = 2048;
  paraCtx.sLSAudioParaCtx.numOfChannels = 1;
  paraCtx.sLSAudioParaCtx.samplerate = 44100;

  // init
  self.mediaCapture = [[LSMediaCapture alloc] initLiveStream:self.url withLivestreamParaCtx:paraCtx];

  // add notifications
  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onStartLiveStream:) name:LS_LiveStreaming_Started object:self.mediaCapture];
  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onFinishedLiveStream:) name:LS_LiveStreaming_Finished object:self.mediaCapture];
  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onBadNetworking:) name:LS_LiveStreaming_Bad object:self.mediaCapture];

  // set preview
  [self.mediaCapture startVideoPreview:self.streamingView];
}

- (BOOL)prefersStatusBarHidden
{
  return statusBarHide;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - notifications

-(void)onStartLiveStream:(NSNotification*)notification
{
  NSLog(@"onStartLiveStream called.");
  dispatch_async(dispatch_get_main_queue(), ^{
    onAir = YES;
    [self.playButton setImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-pause"] forState:UIControlStateNormal];
    [self.view makeToast:@"直播已开始" duration:1.0 position:CSToastPositionCenter];
    if (!micOn) {
      [self.mediaCapture pauseAudioLiveStream];
    }
  });
}

-(void)onFinishedLiveStream:(NSNotification*)notification
{
  NSLog(@"onFinishedLiveStream called.");
  dispatch_async(dispatch_get_main_queue(), ^{
    onAir = NO;
    [self.playButton setImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-play"] forState:UIControlStateNormal];
    [self.view makeToast:@"直播已结束" duration:1.0 position:CSToastPositionCenter];
  });
}

-(void)onBadNetworking:(NSNotification*)notification
{
  NSLog(@"onBadNetworking called.");
}

#pragma mark - IBActions

- (void)onClickStreamingOverlay:(id)sender
{
  NSLog(@"onClickStreamingOverlay called.");
  self.controlOverlay.hidden = NO;
  statusBarHide = NO;
  [self setNeedsStatusBarAppearanceUpdate];
}

- (void)onClickControlOverlay:(id)sender
{
  NSLog(@"onClickControlOverlay called.");
  self.controlOverlay.hidden = YES;
  statusBarHide = YES;
  [self setNeedsStatusBarAppearanceUpdate];
}

- (void)onClickBack:(id)sender
{
  NSLog(@"onClickBack called.");
  if (onAir) {
    [self.mediaCapture stopLiveStream:^(NSError *error) {
      if (!error) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
          if (self.presentingViewController) {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
          }
        });
      }
    }];
  }
  else {
    if (self.presentingViewController) {
      [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
  }
}

- (void)onClickPlay:(id)sender
{
  NSLog(@"onClickPlay called.");
  if (!onAir) {
    // live error callback
    self.mediaCapture.onLiveStreamError = ^(NSError *error) {
      if (error) {
        NSLog(@"%@",[error localizedDescription]);
      }
    };
    // live statistics callback
    self.mediaCapture.onStatisticInfoGot = ^(LSStatistics *statistics) {
      if (statistics) {

      }
    };
    // start live
    NSError *error = nil;
    [self.mediaCapture startLiveStreamWithError:&error];
    if (error) {
      NSLog(@"%@",[error localizedDescription]);
    }
  }
  else {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否结束此次直播" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
      [self.mediaCapture stopLiveStream:^(NSError *error) {
        if (error) {
          NSLog(@"%@",[error localizedDescription]);
        }
      }];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
  }
}

- (void)onClickQuality:(id)sender
{
  NSLog(@"onClickQuality called.");
  if (!onAir) {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择直播推流品质" message:nil preferredStyle:UIAlertControllerStyleAlert];
    QualityViewController *qualityViewController = [[QualityViewController alloc] initWith:currentStreamingQuality];
    [alertController setContentViewController:qualityViewController];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
      currentStreamingQuality =[qualityViewController streamingQuality];
      [self.mediaCapture setVideoParameters:currentStreamingQuality bitrate:0 fps:25 cameraOrientation:LS_CAMERA_ORIENTATION_RIGHT];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
  }
  else {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"直播过程中无法选择推流品质" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
  }
}

- (void)onClickSwitchCamera:(id)sender
{
  NSLog(@"onClickSwitchCamera called.");
  [self.mediaCapture switchCamera];
}

- (void)onClickCameraFlash:(id)sender
{
  NSLog(@"onClickCameraFlash called.");
  flashOn = !flashOn;
  self.mediaCapture.flash = flashOn;
}

- (void)onClickMic:(id)sender
{
  NSLog(@"onClickMic called.");
  micOn = !micOn;
  if (micOn) {
    [self.micButton setImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-mic"] forState:UIControlStateNormal];
    [self.mediaCapture resumeAudioLiveStream];
  }
  else {
    [self.micButton setImage:[UIImage imageNamed:@"CDVLiveStreaming.bundle/ios-mic-off"] forState:UIControlStateNormal];
    [self.mediaCapture pauseAudioLiveStream];
  }
}

- (void)onClickChannel:(id)sender
{
  NSLog(@"onClickChannel called.");
  channelOn = !channelOn;
  self.channelTextView.hidden = !channelOn;
}

- (void)onClickSnapsot:(id)sender
{
  NSLog(@"onClickSnapshot called.");
  if (!onAir) {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"直播未开始前无法截图" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
  }
  else {
    [self.mediaCapture snapShotWithCompletionBlock:^(UIImage *snapImage) {
      UIImageWriteToSavedPhotosAlbum(snapImage, nil, nil, nil);
      PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
      BOOL authorized = NO;
      switch (status) {
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusNotDetermined:
          authorized = NO;
          break;
        case PHAuthorizationStatusAuthorized:
          authorized = YES;
          break;
      }

      UIAlertController *alertController = NULL;
      if (authorized) {
        alertController = [UIAlertController alertControllerWithTitle:@"截图已保存到相册" message:nil preferredStyle:UIAlertControllerStyleAlert];
      }
      else {
        alertController = [UIAlertController alertControllerWithTitle:@"无法访问相册" message:@"请在设置中允许悠课访问你的相册" preferredStyle:UIAlertControllerStyleAlert];
      }
      UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
      [alertController addAction:action];
      [self presentViewController:alertController animated:YES completion:nil];
    }];
  }
}

- (BOOL)requestMediaCapturerAccessWithCompletionHandler:(void (^)(BOOL, NSError*))handler {
  AVAuthorizationStatus videoAuthorStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
  AVAuthorizationStatus audioAuthorStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];

  if (AVAuthorizationStatusAuthorized == videoAuthorStatus && AVAuthorizationStatusAuthorized == audioAuthorStatus) {
    handler(YES, nil);
  }
  else {
    if (AVAuthorizationStatusRestricted == videoAuthorStatus || AVAuthorizationStatusDenied == videoAuthorStatus) {
      NSString *errMsg = NSLocalizedString(@"此应用需要访问摄像头，请设置", @"此应用需要访问摄像头，请设置");
      NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errMsg};
      NSError *error = [NSError errorWithDomain:@"访问权限" code:0 userInfo:userInfo];
      handler(NO, error);
      return NO;
    }
    if (AVAuthorizationStatusRestricted == audioAuthorStatus || AVAuthorizationStatusDenied == audioAuthorStatus) {
      NSString *errMsg = NSLocalizedString(@"此应用需要访问麦克风，请设置", @"此应用需要访问麦克风，请设置");
      NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errMsg};
      NSError *error = [NSError errorWithDomain:@"访问权限" code:0 userInfo:userInfo];
      handler(NO, error);
      return NO;
    }

    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
      if (granted) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
          if (granted) {
            handler(YES, nil);
          }
          else {
            NSString *errMsg = NSLocalizedString(@"不允许访问麦克风", @"不允许访问麦克风");
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errMsg};
            NSError *error = [NSError errorWithDomain:@"访问权限" code:0 userInfo:userInfo];
            handler(NO, error);
          }
        }];
      }
      else {
        NSString *errMsg = NSLocalizedString(@"不允许访问摄像头", @"不允许访问摄像头");
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errMsg};
        NSError *error = [NSError errorWithDomain:@"访问权限" code:0 userInfo:userInfo];
        handler(NO, error);
      }
    }];
  }
  return YES;
}

@end