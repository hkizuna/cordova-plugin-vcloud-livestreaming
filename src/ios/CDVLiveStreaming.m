//
//  CDVLiveStreaming.m
//
//  Created by xwang on 24/05/16.
//
//

#import "CDVLiveStreaming.h"
#import "LiveStreamingViewController.h"

@implementation CDVLiveStreaming:CDVPlugin

LiveStreamingViewController *streamingViewController;

- (void)play:(CDVInvokedUrlCommand *)command
{
  NSArray *arguments = [command arguments];
  if ([arguments count] != 3) {
    [self failWithCallbackId:command.callbackId withMessage:@"参数错误"];
    return;
  }

  NSString *url = [arguments objectAtIndex:0];
  NSString *title = [arguments objectAtIndex:1];
  NSDictionary *options = [arguments objectAtIndex:2];

  streamingViewController = [[LiveStreamingViewController alloc] initWithURL:url title:title andOptions:options];
  if (streamingViewController == nil) {
    [self failWithCallbackId:command.callbackId withMessage:@"初始化错误"];
    return;
  }

  [self.viewController presentViewController:streamingViewController animated:NO completion:^{
    [self successWithCallbackId:command.callbackId withMessage:@"大丈夫"];
  }];
}

- (void)channel:(CDVInvokedUrlCommand *)command
{
  NSArray *arguments = [command arguments];
  if ([arguments count] != 2) {
    [self failWithCallbackId:command.callbackId withMessage:@"参数错误"];
    return;
  }

  NSString *name = [arguments objectAtIndex:0];
  NSString *content = [arguments objectAtIndex:1];

  [streamingViewController addChannelName:name andMessage:content];
  [self successWithCallbackId:command.callbackId withMessage:@"大丈夫"];
}

#pragma mark Helper Function
- (void)successWithCallbackId:(NSString *)callbackId withMessage:(NSString *)message
{
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)failWithCallbackId:(NSString *)callbackId withMessage:(NSString *)message
{
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

@end