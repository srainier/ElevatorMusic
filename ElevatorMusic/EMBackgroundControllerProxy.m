//
//  EMBackgroundControllerProxy.m
//  Puddy
//
//  Created by Shane Arney on 11/11/12.
//  Copyright (c) 2012 srainier. All rights reserved.
//

#import "EMBackgroundControllerProxy.h"

@implementation EMBackgroundControllerProxy

//
// Public methods
//

- (void) becomeActiveAudioController {
  [self startAudioSession];
  [self.proxyResponder becomeFirstResponder];
  [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void) resignActiveAudioController {
  [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
  [self.proxyResponder resignFirstResponder];
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

- (BOOL) handleRemoteControlReceivedEvent:(UIEvent *)event {
  if (event.type == UIEventTypeRemoteControl) {
    switch (event.subtype) {
      case UIEventSubtypeRemoteControlPlay: {
        [self.player play];
        break;
      }
        
      case UIEventSubtypeRemoteControlPause: {
        [self.player pause];
        break;
      }
        
      case UIEventSubtypeRemoteControlStop: {
        [self.player pause];
        break;
      }
        
      case UIEventSubtypeRemoteControlTogglePlayPause: {
        if (self.player.isPlaying) {
          [self.player pause];
        } else {
          [self.player play];
        }
        break;
      }
        
      case UIEventSubtypeRemoteControlPreviousTrack: {
        // check setting: function and/or amount
        [self.player jumpByTime:-30];
        break;
      }
        
      case UIEventSubtypeRemoteControlNextTrack: {
        // check setting: function and/or amount
        [self.player jumpByTime:30];
        //[self.player moveToNext];
        break;
      }
        
      case UIEventSubtypeRemoteControlBeginSeekingBackward: {
        [self.player beginSeekForward:NO];
        break;
      }
        
      case UIEventSubtypeRemoteControlEndSeekingBackward: {
        [self.player endSeek];
        break;
      }
        
      case UIEventSubtypeRemoteControlBeginSeekingForward: {
        [self.player beginSeekForward:YES];
        break;
      }
        
      case UIEventSubtypeRemoteControlEndSeekingForward: {
        [self.player endSeek];
        break;
      }
        
      default:
        break;
    }
    return YES;
  } else {
    return NO;
  }
}

@end

@implementation EMBackgroundControllerProxy (AudioSessions)

- (void) beginInterruption {
  // FROM DOC: By the time this interruption arrives, your audio has already stopped.
  [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
  [self.proxyResponder resignFirstResponder];
}

- (void) endInterruptionWithFlags:(NSUInteger)flags {
  [self becomeActiveAudioController];
  
  BOOL shouldResume = (flags & AVAudioSessionInterruptionFlags_ShouldResume);
  if (shouldResume) {
    [self.player play];
  }
}

@end
