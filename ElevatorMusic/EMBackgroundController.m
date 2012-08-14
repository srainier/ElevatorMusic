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
#import <AVFoundation/AVFoundation.h>

@interface EMBackgroundController ()

- (void) startAudioSession;
- (void) endAudioSession;

@end

@interface EMBackgroundController (AudioSessions) <AVAudioSessionDelegate>
@end

@implementation EMBackgroundController

@synthesize interfaceOrientation = interfaceOrientation_;
@synthesize player = player_;

- (id)init {
  self = [super init];
  if (self) {
    interfaceOrientation_ = UIInterfaceOrientationPortrait;
  }
  return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation == self.interfaceOrientation);
}

//
// Public methods
//

- (void) becomeActiveAudioController {
  [self startAudioSession];
  [self becomeFirstResponder];
  [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void) resignActiveAudioController {
  [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
  [self resignFirstResponder];
  [self endAudioSession];
}

//
// Helper methods
//

- (void) startAudioSession {
  AVAudioSession *session = [AVAudioSession sharedInstance];
  session.delegate = self;

  NSError *activationError = nil;
  [session setActive:YES error:&activationError];
  
  NSError *setCategoryError = nil;
  [session setCategory:AVAudioSessionCategoryPlayback
                 error:&setCategoryError];  
}

- (void) endAudioSession {
  AVAudioSession *session = [AVAudioSession sharedInstance];
  session.delegate = nil;
  
  NSError *activationError = nil;
  [session setActive:NO withFlags:AVAudioSessionSetActiveFlags_NotifyOthersOnDeactivation error:&activationError];
}

//
// Remote control event handling.
//

// This is necessary to get play events
- (BOOL) canBecomeFirstResponder {
  return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
  if (event.type == UIEventTypeRemoteControl) {
    switch (event.subtype) {
      case UIEventSubtypeRemoteControlPlay: {
        [player_ play];
        break;
      }
        
      case UIEventSubtypeRemoteControlPause: {
        [player_ pause];
        break;
      }
        
      case UIEventSubtypeRemoteControlStop: {
        [player_ pause];
        break;
      }
        
      case UIEventSubtypeRemoteControlTogglePlayPause: {
        if (player_.isPlaying) {
          [player_ pause];
        } else {
          [player_ play];
        }
        break;
      }
        
      case UIEventSubtypeRemoteControlPreviousTrack: {
        // check setting: function and/or amount
        [player_ jumpByTime:30];
        break;
      }
        
      case UIEventSubtypeRemoteControlNextTrack: {
        // check setting: function and/or amount
        [player_ jumpByTime:-30];
        //[player_ moveToNext];
        break;
      }
        
      case UIEventSubtypeRemoteControlBeginSeekingBackward: {
        [player_ beginSeekForward:NO];
        break;
      }
        
      case UIEventSubtypeRemoteControlEndSeekingBackward: {
        [player_ endSeek];
        break;
      }
        
      case UIEventSubtypeRemoteControlBeginSeekingForward: {
        [player_ beginSeekForward:YES];
        break;
      }
        
      case UIEventSubtypeRemoteControlEndSeekingForward: {
        [player_ endSeek];
        break;
      }
        
      default:
        break;
    }
  } else {
    [super remoteControlReceivedWithEvent:event];
  }
}


@end

@implementation EMBackgroundController (AudioSessions)

- (void) beginInterruption {
  // FROM DOC: By the time this interruption arrives, your audio has already stopped.
  // endAudioSession ?
  [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
  [self resignFirstResponder]; 
}

- (void) endInterruptionWithFlags:(NSUInteger)flags {
  [self becomeActiveAudioController];

  BOOL shouldResume = (flags & AVAudioSessionInterruptionFlags_ShouldResume);
  if (shouldResume) {
    [player_ play];
  }
}


@end
