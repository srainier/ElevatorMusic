//
// EMPlayer.m
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

#import "EMPlayer.h"
#import "EMMediaItem.h"
#import "EMPlayerEvents.h"
#import <AVFoundation/AVFoundation.h>

//
// constants
//

const NSUInteger EM_PLAYER_NO_ITEMS = NSUIntegerMax;

@interface EMPlayer () {
  AVQueuePlayer *_queuePlayer;
  id _timeObserver;
  NSTimer *_seekTimer;
}

@property (nonatomic, strong, readonly) AVPlayerItem* currentPlayerItem;

// Item creation and cleanup
- (AVPlayerItem*) createPlayerItemWithUrl:(NSURL*)url;
- (void) cleanupItem:(AVPlayerItem*)playerItem;

// Item completion
- (void) itemCompleted:(NSNotification*)notification;
- (void) itemFailedToComplete:(NSNotification*)notification;

// Seek Timer methods
- (void) cancelSeekTime;
- (void) seekOnTimer:(NSTimer*)timer;
- (void) seekTimeDelta:(NSTimeInterval)timeDelta afterDuration:(NSTimeInterval)duration;

// Event notification methods
- (void) postPlayerEvent:(NSString*)eventName;
- (void) postPlayerEvent:(NSString*)eventName withItem:(EMMediaItem*)item;
- (void) postPlayerEvent:(NSString*)eventName withItem:(EMMediaItem*)item time:(NSTimeInterval)time duration:(NSTimeInterval)duration;
- (void) postPlayerEvent:(NSString*)eventName withItem:(EMMediaItem*)item forward:(BOOL)forward;

@end

@implementation EMPlayer

@dynamic isPlaying;
@dynamic currentTime;
@dynamic duration;
@dynamic currentPlayerItem;

//
// Parent overrides
//

- (id) init {
  self = [super init];
  if (nil != self) {
    _queuePlayer = nil;
    _timeObserver = nil;
    _isSetup = NO;
  }
  return self;
}

//
// EMPlaybackControl methods and dynamic properties
//

- (BOOL) isPlaying {
  return (nil != _currentItem) ? (0.0 != _queuePlayer.rate) : NO;
}

- (void) play {
  if (nil != _currentItem) {
    [_queuePlayer play];

    // Notify delegate and event listeners.
    if ([self.delegate respondsToSelector:@selector(player:didPlayItem:)]) {
      [self.delegate player:self didPlayItem:self.currentItem];
    }
    [self postPlayerEvent:EMPlayerDidPlay withItem:self.currentItem];
  }
}

- (void) pause {
  if (nil != _currentItem) {
    if (self.isPlaying) {
      [_queuePlayer pause];

      // Notify delegate and event listeners.
      if ([self.delegate respondsToSelector:@selector(player:didPauseItem:)]) {
        [self.delegate player:self didPauseItem:self.currentItem];
      }
      [self postPlayerEvent:EMPlayerDidPause withItem:self.currentItem];
    }    
  }
}

- (void) togglePlayPause {
  if (self.isPlaying) {
    [self pause];
  } else {
    [self play];
  }
}

- (void) jumpToTime:(NSTimeInterval)time {
  if (nil != _currentItem) {
    if (time < 0.0) {
      time = 0.0;
    }

    [_queuePlayer seekToTime:CMTimeMakeWithSeconds(time, 1.0)];
    
    // If the jump-to time is past the end of the AVPlayerItem's duration
    // and the player is paused the AVPlayerItem won't complete.
    // Calling play will lead to the 'did complete' event. Otherwise this
    // will not affect the play/pause state of the player.
    if (CMTimeGetSeconds(self.currentPlayerItem.duration) < time) {
      [_queuePlayer play];
    }
  }
}

- (void) jumpByTime:(NSTimeInterval)timeDelta {
  if (nil != _currentItem) {
    NSTimeInterval time = CMTimeGetSeconds(self.currentPlayerItem.currentTime) + timeDelta;
    [self jumpToTime:time];
  }
}

- (void) beginSeekForward:(BOOL)forward {
  if (nil != _currentItem) {
    [self seekTimeDelta:(forward ? 10.0 : -10.0) afterDuration:0.5];

    // Notify delegate and event listeners.
    if ([self.delegate respondsToSelector:@selector(player:didStartSeekingItem:forward:)]) {
      [self.delegate player:self didStartSeekingItem:self.currentItem forward:YES];
    }
    [self postPlayerEvent:EMPlayerDidStartSeeking withItem:self.currentItem forward:forward];
  }
}

- (void) endSeek {
  if (nil != _currentItem) {
    [self cancelSeekTime];
    
    // Notify delegate and event listeners.
    if ([self.delegate respondsToSelector:@selector(player:didEndSeekingItem:)]) {
      [self.delegate player:self didEndSeekingItem:self.currentItem];
    }
    [self postPlayerEvent:EMPlayerDidEndSeeking withItem:self.currentItem];
  }
}

//
// Public methods and dynamic properties
//

- (NSTimeInterval) currentTime {
  return nil != _currentItem ? CMTimeGetSeconds(self.currentPlayerItem.currentTime) : 0.0;
}


- (NSTimeInterval) duration {
  return nil != _currentItem ? CMTimeGetSeconds(self.currentPlayerItem.duration) : 0.0;
}


- (void) setup {
  _queuePlayer = [[AVQueuePlayer alloc] init];
  [_queuePlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
}


- (void) cleanup {
  [self removeCurrentItem];
}


- (void) addItem:(EMMediaItem*)item {
  
  // Cleanup existing item
  [self removeCurrentItem];

  AVPlayerItem* playerItem = [self createPlayerItemWithUrl:item.url];
  if (nil != playerItem) {

    // Notify delegate and event listeners
    if ([self.delegate respondsToSelector:@selector(player:willInitalizeMediaItem:)]) {
      [self.delegate player:self willInitalizeMediaItem:item]; // not sure about count - before or after amount?
    }
    [self postPlayerEvent:EMPlayerWillInitalizeMediaItem withItem:item];
    
    _currentItem = item;
    [_queuePlayer insertItem:playerItem afterItem:nil];
    
    // The initialized/failed event will come in response to the AVPlayerItem
    // load event.
  }
  
}

- (void) removeCurrentItem {
  
  if (nil != _currentItem) {

    // Stop playback before cleanup.
    [_queuePlayer pause];
    
    // Notify delegate and event listeners of 'will remove'.
    if ([self.delegate respondsToSelector:@selector(player:willRemoveCurrentMediaItem:)]) {
      [self.delegate player:self willRemoveCurrentMediaItem:self.currentItem];
    }
    [self postPlayerEvent:EMPlayerWillRemoveCurrentMediaItem];
    
    // Loop just in case there happens to be more than one item.
    while (0 < _queuePlayer.items.count) {
      // Cleanup the AVPlayerItem at the front of the queue.
      AVPlayerItem* playerItemToRemove = _queuePlayer.items[0];
      [self cleanupItem:playerItemToRemove];
      [_queuePlayer advanceToNextItem];
    }
    _currentItem = nil;
    
    // Notify delegate and event listeners of 'did remove'.
    if ([self.delegate respondsToSelector:@selector(player:didRemoveCurrentMediaItem:)]) {
      [self.delegate player:self didRemoveCurrentMediaItem:self.currentItem];
    }
    [self postPlayerEvent:EMPlayerDidRemoveCurrentMediaItem];
  }
}

//
// NSObject overrides
//

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

  if (object == _queuePlayer && [keyPath isEqualToString:@"status"]) {
    
    NSNumber* changeKind = [change objectForKey:NSKeyValueChangeKindKey];
    if ([@(NSKeyValueChangeSetting) isEqual:changeKind]) {

      // Cleanup the observer.
      [_queuePlayer removeObserver:self forKeyPath:@"status" context:NULL];
            
      if (AVPlayerStatusReadyToPlay == _queuePlayer.status) {
        
        if ([self.delegate respondsToSelector:@selector(playerDidInitialize:)]) {
          [_delegate playerDidInitialize:self];
        }
        [self postPlayerEvent:EMPlayerDidInitalize];
        
      } else {
        if ([self.delegate respondsToSelector:@selector(playerFailedToInitialize:)]) {
          [_delegate playerFailedToInitialize:self];
        }
        [self postPlayerEvent:EMPlayerFailedToInitialize];
      }

    }

  } else if ([object isKindOfClass:[AVPlayerItem class]] && [keyPath isEqualToString:@"status"]) {
    
    NSNumber* changeKind = [change objectForKey:NSKeyValueChangeKindKey];
    
    if ([@(NSKeyValueChangeSetting) isEqual:changeKind]) {

      // Get the player item's index in the queue.
      AVPlayerItem* playerItem = object;
      NSUInteger itemIndex = [_queuePlayer.items indexOfObject:playerItem];
      
      // Get the status of the player item.
      AVPlayerItemStatus playerItemStatus = AVPlayerItemStatusUnknown;
      if (nil != [change objectForKey:NSKeyValueChangeNewKey]) {
        playerItemStatus = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
      } else {
        // If the 'new' key isn't in the change dictionary, check the player item.
        // Not sure how reliable this method is.
        if (NSNotFound == itemIndex) {
          // Can't find the player item, so treat loading as failed.
          playerItemStatus = AVPlayerItemStatusFailed;
        } else {
          playerItemStatus = playerItem.status;
        }
      }

      EMMediaItem* mediaItem = self.currentItem;
      if (AVPlayerItemStatusReadyToPlay == playerItemStatus) {
        
        // Send the 'did initialize' event to the delegate and event observers.
        if ([self.delegate respondsToSelector:@selector(player:didInitalizeMediaItem:)]) {
          [_delegate player:self didInitalizeMediaItem:mediaItem];
        }
        [self postPlayerEvent:EMPlayerDidInitalizeMediaItem withItem:mediaItem];

        // Create a new time observer that specifically checks for time events for this
        // media item. The time observer gets recreated for each media item because
        // the AVPlayer can leak time events for an item after it has been removed.
        // We only want time events to be handled for the player's current item.
        [self clearTimeObserver];
        __block EMPlayer* blockSelf = self;

        _timeObserver = [_queuePlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime t) {
          
          // Only handle the event if the time event is for the current item.
          if (mediaItem == blockSelf.currentItem) {
            // Get the time reported and duration of the currently-playing item.
            NSTimeInterval time = CMTimeGetSeconds(t);
            NSTimeInterval duration = CMTimeGetSeconds(blockSelf.currentPlayerItem.duration);
            
            // Notify delegate and event listeners.
            if ([blockSelf.delegate respondsToSelector:@selector(player:didReachTime:forItem:duration:)]) {
              [blockSelf.delegate player:blockSelf didReachTime:time forItem:blockSelf.currentItem duration:duration];
            }
            [blockSelf postPlayerEvent:EMPlayerDidReachTime withItem:blockSelf.currentItem time:time duration:duration];
          }
          
        }];

      } else {
        
        if ([self.delegate respondsToSelector:@selector(player:failedToInitalizeMediaItem:)]) {
          [_delegate player:self failedToInitalizeMediaItem:mediaItem];
        }
        [self postPlayerEvent:EMPlayerFailedToInitializeMediaItem withItem:mediaItem];
        
      }

    }

  } else if ([object isKindOfClass:[AVPlayerItem class]] && [keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {

    if ([@(NSKeyValueChangeSetting) isEqual:[change objectForKey:NSKeyValueChangeNewKey]]) {

    }
    
  }
}

//
// Helper methods and dynamic properties
//

- (AVPlayerItem*) currentPlayerItem {
  if (nil != _currentItem) {
    if (0 == _queuePlayer.items.count) {
      return nil;
    } else {
      return [_queuePlayer.items objectAtIndex:0];
    }
  } else {
    return nil;
  }
}


- (AVPlayerItem*) createPlayerItemWithUrl:(NSURL*)url {
  
  AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:url];
  
  if (nil != playerItem) {

    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemCompleted:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemFailedToComplete:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:playerItem];
  }
  
  return playerItem;
}

- (void) clearTimeObserver {
  
  if (nil != _timeObserver) {
    [_queuePlayer removeTimeObserver:_timeObserver];
    _timeObserver = nil;
  }
  
}

- (void) cleanupItem:(AVPlayerItem*)playerItem {
  
  [self clearTimeObserver];
  
  [playerItem removeObserver:self forKeyPath:@"status" context:NULL];
  [playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:NULL];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:playerItem];
}


- (void) itemCompleted:(NSNotification*)notification {
  if ([self.delegate respondsToSelector:@selector(player:didCompleteItem:)]) {
    [self.delegate player:self didCompleteItem:self.currentItem];
  }
  
  [self postPlayerEvent:EMPlayerDidComplete withItem:self.currentItem];

  // Don't cleanup automatically - user may want to replay the item, so leave it
  // in queue.
}

- (void) itemFailedToComplete:(NSNotification*)notification {
  // uhhh....???
}

- (void) cancelSeekTime {
  [_seekTimer invalidate];
  _seekTimer = nil;
}

- (void) seekOnTimer:(NSTimer*)timer {
  NSTimeInterval timeDelta = [[timer.userInfo objectForKey:@"timeDelta"] doubleValue];
  NSTimeInterval duration = [[timer.userInfo objectForKey:@"duration"] doubleValue];
  
  [self cancelSeekTime];
  
  if (0 < timeDelta) {
    // forward
    NSTimeInterval currentTime = CMTimeGetSeconds(_queuePlayer.currentTime);
    NSTimeInterval itemDuration = CMTimeGetSeconds(self.currentPlayerItem.duration);
    if (timeDelta < (itemDuration - currentTime)) {
      [_queuePlayer seekToTime:CMTimeMakeWithSeconds(self.currentTime + timeDelta, 1.0)];
      [self seekTimeDelta:timeDelta afterDuration:duration];
    } else {
      // TODO: whatever 'end of track' actions would normally be performed - stop playing, advance, etc
    }
  } else {
    // backward
    if (timeDelta < self.currentTime) {
      [_queuePlayer seekToTime:CMTimeMakeWithSeconds(self.currentTime + timeDelta, 1.0)];
      [self seekTimeDelta:timeDelta afterDuration:duration];
    } else {
      [_queuePlayer seekToTime:CMTimeMakeWithSeconds(0.0, 1.0)];
      // TODO: whatever 'endSeek' actions are here - start playing again, who knows
    }
  }
  
}

- (void) seekTimeDelta:(NSTimeInterval)timeDelta afterDuration:(NSTimeInterval)duration {
  [self cancelSeekTime];
  _seekTimer = [NSTimer scheduledTimerWithTimeInterval:duration
                                                target:self
                                              selector:@selector(seekOnTimer:)
                                              userInfo:@{ @"timeDelta" : @(timeDelta), @"duration" : @(duration) }
                                               repeats:NO];
}

- (void) postPlayerEvent:(NSString*)eventName {
  [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:self];
}

- (void) postPlayerEvent:(NSString*)eventName withItem:(EMMediaItem*)item {
  [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:self userInfo:@{ EMMediaItemKey : item }];
}

- (void) postPlayerEvent:(NSString*)eventName withItem:(EMMediaItem*)item time:(NSTimeInterval)time duration:(NSTimeInterval)duration {
  [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:self userInfo:@{ EMMediaItemKey : item, EMTimeKey : @(time), EMDurationKey : @(duration) }];
}

- (void) postPlayerEvent:(NSString*)eventName withItem:(EMMediaItem*)item forward:(BOOL)forward {
  [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:self userInfo:@{ EMMediaItemKey : item, EMTimeKey : @(forward) }];
}

@end
