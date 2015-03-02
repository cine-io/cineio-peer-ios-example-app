//
//  MediaStreamAndRenderer.m
//  CineIOPeerExampleApp
//
//  Created by Thomas Shafer on 3/2/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "RTCMediaStream.h"
#import "RTCVideoTrack.h"
#import "RTCEAGLVideoView.h"
#import "MediaStreamAndRenderer.h"
#import "ViewController.h"

@interface MediaStreamAndRenderer () <RTCEAGLVideoViewDelegate>

@property (nonatomic, strong) RTCMediaStream* mediaStream;
@property (nonatomic, strong) RTCEAGLVideoView* renderer;
@property (nonatomic, strong) RTCPeerConnection* peerConnection;
@property (nonatomic, weak) ViewController* viewController;

@property BOOL local;
@property CGRect bounds;

@end


@implementation MediaStreamAndRenderer

- (id)initWithStream:(RTCMediaStream *)mediaStream peerConnection:(RTCPeerConnection *)thePeerConnection bounds:(CGRect)bounds local:(BOOL)local view:(ViewController *)viewController
{
    if (self = [super init]) {
        self.mediaStream = mediaStream;
        self.local = local;
        self.peerConnection = thePeerConnection;
        self.bounds = bounds;
        self.viewController = viewController;
        RTCEAGLVideoView *theRenderer = [[RTCEAGLVideoView alloc] initWithFrame:bounds];
        theRenderer.delegate = self;

        RTCVideoTrack *track = [mediaStream.videoTracks firstObject];
        [track addRenderer:theRenderer];
        self.renderer = theRenderer;
    }
    return self;

}
- (RTCPeerConnection *)getPeerConnection
{
    return self.peerConnection;
}


- (void)updateVideoFrame:(CGSize)theSize;
{
    CGSize defaultAspectRatio = CGSizeMake(4, 3); //arbitrary 4:3 aspect ratio
    CGSize aspectRatio = CGSizeEqualToSize(theSize, CGSizeZero) ? defaultAspectRatio : theSize;
    CGRect videoFrame = AVMakeRectWithAspectRatioInsideRect(aspectRatio, self.bounds);
    // just to make the video smaller
    videoFrame.size.width = videoFrame.size.width / 3;
    videoFrame.size.height = videoFrame.size.height / 3;

    self.renderer.frame = videoFrame;
}

- (RTCEAGLVideoView *)getRenderer
{
    return self.renderer;
}

- (void)cleanup
{
    if (self.renderer != nil){
        RTCVideoTrack *track = [[self.mediaStream videoTracks] firstObject];
        if (track != nil){
            [track removeRenderer:self.renderer];
        }
        [self removeVideoRenderer];
    }
    self.renderer = nil;
}

- (void)removeVideoRenderer
{
    if (self.renderer != nil){
        if ([self.renderer superview] != nil){
            [self.renderer removeFromSuperview];
        }
    }

}

#pragma mark - RTCEAGLVideoViewDelegate

- (void)videoView:(RTCEAGLVideoView*)videoView didChangeVideoSize:(CGSize)size {
    NSLog(@"DID CHANGE SIZE");
    [self updateVideoFrame:size];
    [self.viewController refreshVideoLayout];
}

@end
