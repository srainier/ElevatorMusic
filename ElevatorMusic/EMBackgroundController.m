//
// EMBackgroundController.m
//
// Copyright (c) 2012 Shane Arney (srainier@gmail.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "EMBackgroundController.h"
#import "EMPlayer.h"
#import "EMBackgroundControllerProxy.h"
#import <AVFoundation/AVFoundation.h>

@interface EMBackgroundController () {
  EMBackgroundControllerProxy* backgroundControllerProxy_;
}

@end

@implementation EMBackgroundController

@synthesize allowedInterfaceOrientations = allowedInterfaceOrientations_;
@synthesize player = player_;

- (void) setPlayer:(id<EMPlaybackControl>)player {
  player_ = player;
  backgroundControllerProxy_.player = player;
}

- (id)init {
  self = [super init];
  if (self) {
    backgroundControllerProxy_ = [[EMBackgroundControllerProxy alloc] init];
    backgroundControllerProxy_.proxyResponder = self;
    allowedInterfaceOrientations_ = UIInterfaceOrientationPortrait
                                  | UIInterfaceOrientationPortraitUpsideDown
                                  | UIInterfaceOrientationLandscapeLeft
                                  | UIInterfaceOrientationLandscapeRight;
  }
  return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation & self.allowedInterfaceOrientations);
}

//
// Public methods
//

- (void) becomeActiveAudioController {
  [backgroundControllerProxy_ becomeActiveAudioController];
}

- (void) resignActiveAudioController {
  [backgroundControllerProxy_ resignActiveAudioController];
}

//
// Remote control event handling.
//

// This is necessary to get play events
- (BOOL) canBecomeFirstResponder {
  return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
  if (![backgroundControllerProxy_ handleRemoteControlReceivedEvent:event]) {
    [super remoteControlReceivedWithEvent:event];
  }
}

@end
