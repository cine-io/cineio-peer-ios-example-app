//
//  MediaStreamAndRenderer.h
//  CineIOPeerExampleApp
//
//  Created by Thomas Shafer on 3/2/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#ifndef CineIOPeerExampleApp_MediaStreamAndRenderer_h
#define CineIOPeerExampleApp_MediaStreamAndRenderer_h

@class RTCMediaStream;
@class RTCEAGLVideoView;
@class RTCPeerConnection;
@class ViewController;

@interface MediaStreamAndRenderer : NSObject
- (id)initWithStream:(RTCMediaStream *)mediaStream peerConnection:(RTCPeerConnection *)peerConnection bounds:(CGRect)bounds local:(BOOL)local view:(ViewController *)viewController;
- (RTCEAGLVideoView *)getRenderer;
- (RTCPeerConnection *)getPeerConnection;
- (void)removeVideoRenderer;
- (void)cleanup;

@end


#endif
