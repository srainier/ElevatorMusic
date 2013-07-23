//
//  EMPlayerSession.m
//  Puddy
//
//  Created by Shane Arney on 11/11/12.
//  Copyright (c) 2012 srainier. All rights reserved.
//

#import "EMPlayerSession.h"
#import "EMPlayer.h"

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

- (BOOL) handleRemoteControlReceivedEvent:(UIEvent *)event withPlayer:(EMPlayer *)player {
  if (event.type == UIEventTypeRemoteControl) {
    switch (event.subtype) {
      case UIEventSubtypeRemoteControlPlay: {
        [player play];
        break;
      }
        
      case UIEventSubtypeRemoteControlPause: {
        [player pause];
        break;
      }
        
      case UIEventSubtypeRemoteControlStop: {
        [player pause];
        break;
      }
        
      case UIEventSubtypeRemoteControlTogglePlayPause: {
        if (player.isPlaying) {
          [player pause];
        } else {
          [player play];
        }
        break;
      }
        
      case UIEventSubtypeRemoteControlPreviousTrack: {
        [player jumpByTime:-30];
        break;
      }
        
      case UIEventSubtypeRemoteControlNextTrack: {
        [player jumpByTime:30];
        break;
      }
        
      case UIEventSubtypeRemoteControlBeginSeekingBackward: {
        [player beginSeekForward:NO];
        break;
      }
        
      case UIEventSubtypeRemoteControlEndSeekingBackward: {
        [player endSeek];
        break;
      }
        
      case UIEventSubtypeRemoteControlBeginSeekingForward: {
        [player beginSeekForward:YES];
        break;
      }
        
      case UIEventSubtypeRemoteControlEndSeekingForward: {
        [player endSeek];
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