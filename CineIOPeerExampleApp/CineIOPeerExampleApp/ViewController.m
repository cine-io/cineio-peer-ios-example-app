//
//  ViewController.m
//  CineIOPeerExampleApp
//
//  Created by Thomas Shafer on 3/2/15.
//  Copyright (c) 2015 cine.io. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "CinePeerClient.h"
#import "CinePeerClientConfig.h"
#import "CineCall.h"
#import "CineIdentity.h"
#import "RTCMediaStream.h"
#import "RTCEAGLVideoView.h"
#import "MediaStreamAndRenderer.h"

static CGFloat const kLocalViewPadding = 20;

@interface ViewController () <CinePeerClientDelegate>

@property (weak, nonatomic) IBOutlet UIView *videosView;
@property (strong, nonatomic) UIView *videosSubView;
@property (nonatomic, strong) NSMutableArray* videoViews;
@property (nonatomic, strong) CinePeerClient *cinePeerClient;
@end


@implementation ViewController
{
    CGSize _localVideoSize;
    CGSize _remoteVideoSize;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoViews = [[NSMutableArray alloc] init];

    [self initializeVideoViews];

    // Update with your cine.io api keys
    // register for free at https://www.cine.io/
    NSString *CINE_IO_PUBLIC_KEY = @"CINE_IO_PUBLIC_KEY";
    NSString *CINE_IO_SECRET_KEY = @"CINE_IO_SECRET_KEY";

    if ([CINE_IO_PUBLIC_KEY isEqual: @"CINE_IO_PUBLIC_KEY"]){
        NSAssert(NO, @"Please set CINE_IO_PUBLIC_KEY to your own public key. You can register for one for free at https://www.cine.io");
    }

    // Initialize the CinePeerClientConfig class
    CinePeerClientConfig *config = [[CinePeerClientConfig alloc] initWithPublicKey:CINE_IO_PUBLIC_KEY delegate:self];
    // Add the secret key
    // This is only necessary for securely identifying
    // [config setSecretKey:CINE_IO_SECRET_KEY];

    // Create the peer client
    self.cinePeerClient  = [[CinePeerClient alloc] initWithConfig:config];

    // Start up the camera and microphone
    [self.cinePeerClient startMediaStream];

    // Join a room
    NSString *roomName = @"example";
    [self.cinePeerClient joinRoom:roomName];

    // Uncomment to identify
    // NSString *identityName = @"SET-UNIQUE-IDENTITY-HERE";
    // CineIdentity *identity = [config generateIdentity:identityName];
    // [self.cinePeerClient identify:identity];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeVideoViews {
    self.videosView.hidden = NO;
    [self refreshVideoLayout];
}

- (void)refreshVideoLayout {
    // TODO: handle rotation.

    NSLog(@"Reset video layout");
    for(MediaStreamAndRenderer* msr in self.videoViews){
        [msr removeVideoRenderer];
    }
    if (self.videosSubView != nil){
        NSLog(@"removing view");
        [self.videosSubView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    }
    self.videosSubView = [[UIView alloc] initWithFrame:self.videosView.frame];
    [self.videosView addSubview:self.videosSubView];

    NSUInteger offset = kLocalViewPadding;
    for(MediaStreamAndRenderer* msr in self.videoViews){
        offset = [self showMediaStream:msr offset:offset];
    }
}

- (int)showMediaStream:(MediaStreamAndRenderer *)msr offset:(int)offset
{
    NSLog(@"Showing media stream");

    RTCEAGLVideoView *renderer = [msr getRenderer];
    CGRect videoFrame = renderer.frame;

    videoFrame.origin.x = kLocalViewPadding;
    videoFrame.origin.y =  offset + kLocalViewPadding;
    renderer.frame = videoFrame;
    [self.videosSubView addSubview:renderer];

    offset += videoFrame.size.height + kLocalViewPadding;
    return offset;
}

- (MediaStreamAndRenderer *)getMediaStreamAndRendererForPeerConnection:(RTCPeerConnection *)peerConnection
{
    MediaStreamAndRenderer *msrToReturn = nil;
    for(MediaStreamAndRenderer* msr in self.videoViews){
        if ([msr getPeerConnection] == peerConnection)
            msrToReturn = msr;
    }
    return msrToReturn;
}


#pragma mark - CinePeerClientDelegate

- (void) addStream:(RTCMediaStream *)stream peerConnection:(RTCPeerConnection *)peerConnection local:(BOOL)local
{
    NSLog(@"Got media stream");
    MediaStreamAndRenderer *msr = [[MediaStreamAndRenderer alloc] initWithStream:stream peerConnection:peerConnection bounds:self.videosView.bounds local:local view:self];

    [self.videoViews addObject:msr];
    [self refreshVideoLayout];
}


- (void)removeStream:(RTCMediaStream *)mediaStream peerConnection:(RTCPeerConnection *)peerConnection local:(BOOL)local;
{
    NSLog(@"Remove stream");
    MediaStreamAndRenderer *msrToDelete = [self getMediaStreamAndRendererForPeerConnection:peerConnection];
    if (msrToDelete != nil){
        [msrToDelete cleanup];
        [self.videoViews removeObject:msrToDelete];
    }
    NSLog(@"Did removed");

    [self refreshVideoLayout];
}

-(void) handleError:(NSDictionary *)error
{
    NSLog(@"ViewController got error: %@", error);
}

- (void) handleCall:(CineCall *)call
{
    NSLog(@"ViewController got call");
    [call answer];
}


- (void) onCallCancel:(CineCall *)call
{
    NSLog(@"ViewController got call cancel");
}

- (void) onCallReject:(CineCall *)call
{
    NSLog(@"ViewController got call reject");
}

@end
