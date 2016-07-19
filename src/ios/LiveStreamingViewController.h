//
//  LiveStreamingViewController.h
//
//  Created by xwang on 24/05/16.
//
//

#import <UIKit/UIKit.h>
#import "LSMediaCapture.h"
#import "nMediaLiveStreamingDefs.h"

@interface LiveStreamingViewController : UIViewController

@property(nonatomic, strong) NSString *url;
@property(nonatomic, strong) NSString *streamingTitle;
@property(nonatomic, strong) NSDictionary *options;

- (id)initWithURL:(NSString *)url title:(NSString *)title andOptions:(NSDictionary *)options;
- (void)addChannelName:(NSString *)name andMessage:(NSString *)message;

@end