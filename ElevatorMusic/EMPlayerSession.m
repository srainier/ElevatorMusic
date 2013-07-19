//
//  EMPlayerSession.m
//  Puddy
//
//  Created by Shane Arney on 11/11/12.
//  Copyright (c) 2012 srainier. All rights reserved.
//

#import "EMPlayerSession.h"
#import "EMPlayer+globalPlayer.h"

@implementation EMPlayerSession

//
// Public methods
//

- (void) startAudioSession {
  AVAudioSession *session = [AVAudioSession sharedInstance];
  
  NSError *activationError = nil;
  [session setActive:YES error:&activationError];
  
  NSError *setCategoryError = nil;
  [session setCategory:AVAudioSessionCategoryPlayback
                 error:&setCategoryError];
}

- (void) endAudioSession {
  AVAudioSession *session = [AVAudioSession sharedInstance];
  
  NSError *activationError = nil;
  [session setActive:NO
         withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
               error:&activationError];
}

//
// Remote control event handling.
//

- (BOOL) handleRemoteControlReceivedEvent:(UIEvent *)event {
  if (event.type == UIEventTypeRemoteControl) {
    switch (event.subtype) {
      case UIEventSubtypeRemoteControlPlay: {
        [[EMPlayer globalPlayer] play];
        break;
      }
        
      case UIEventSubtypeRemoteControlPause: {
        [[EMPlayer globalPlayer] pause];
        break;
      }
        
      case UIEventSubtypeRemoteControlStop: {
        [[EMPlayer globalPlayer] pause];
        break;
      }
        
      case UIEventSubtypeRemoteControlTogglePlayPause: {
        if ([EMPlayer globalPlayer].isPlaying) {
          [[EMPlayer globalPlayer] pause];
        } else {
          [[EMPlayer globalPlayer] play];
        }
        break;
      }
        
      case UIEventSubtypeRemoteControlPreviousTrack: {
        [[EMPlayer globalPlayer] jumpByTime:-30];
        break;
      }
        
      case UIEventSubtypeRemoteControlNextTrack: {
        [[EMPlayer globalPlayer] jumpByTime:30];
        break;
      }
        
      case UIEventSubtypeRemoteControlBeginSeekingBackward: {
        [[EMPlayer globalPlayer] beginSeekForward:NO];
        break;
      }
        
      case UIEventSubtypeRemoteControlEndSeekingBackward: {
        [[EMPlayer globalPlayer] endSeek];
        break;
      }
        
      case UIEventSubtypeRemoteControlBeginSeekingForward: {
        [[EMPlayer globalPlayer] beginSeekForward:YES];
        break;
      }
        
      case UIEventSubtypeRemoteControlEndSeekingForward: {
        [[EMPlayer globalPlayer] endSeek];
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