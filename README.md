# Cine.io peer iOS example

This is an iOS example application using [cine.io Peer iOS SDK][cineio-peer-ios]. It supports joining rooms, identifying, calling, and showing local and remove streams.

## How to run Locally

1. Update `CINE_IO_PUBLIC_KEY` and `CINE_IO_SECRET_KEY` in [ViewController.m][public-key]
* Install the pods in the CineIOPeerExampleApp directory
  ```shell
  cd CineIOPeerExampleApp && pod install
  ```
* Open `CineIOPeerExampleApp.xcworkspace`
*
* Run the app on an iOS device.

## Quick walkthrough

### ViewController.m

This class creates a new `CinePeerClientConfig` and passes it to a new `CinePeerClient`.

It then starts the camera, joins an example room, and optionally identifies.

This class is also a `CinePeerClientDelegate`. It must implement the following methods:
```objective-c
- (void) addStream:(RTCMediaStream *)stream peerConnection:(RTCPeerConnection *)peerConnection local:(BOOL)local
- (void) removeStream:(RTCMediaStream *)mediaStream peerConnection:(RTCPeerConnection *)peerConnection local:(BOOL)local;
- (void) handleError:(NSDictionary *)error
- (void) handleCall:(CineCall *)call
- (void) onCallCancel:(CineCall *)call
- (void) onCallReject:(CineCall *)call
```

On addStream it creates a `MediaStreamAndRenderer`. This holds the media stream and creates a renderer. It adds the newly created `MediaStreamAndRenderer` to an array. Then it refreshes the UI showing all of the media streams.

On removeStream, it deletes the corresponding `MediaStreamAndRenderer` and refreshes the UI.

### MediaStreamAndRenderer.m

This class holds all of the information associated with the media stream. It holds an instance of a `RTCEAGLVideoView`, which is required to show the media stream. It also listens to video size changes and appropriately resizes the video and then tells the `ViewController` to refresh the UI.

<!-- external links -->
[cineio-peer]:https://www.cine.io/products/peer
[cineio-peer-ios]:https://github.com/cine-io/cineio-peer-ios
[public-key]:CineIOPeerExampleApp/CineIOPeerExampleApp/ViewController.m
