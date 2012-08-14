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
  NSMutableArray* items_;
  AVQueuePlayer* queuePlayer_;
  id timeObserver_;
  NSTimer* seekTimer_;
}

@property (nonatomic, readonly) BOOL isItemsEmpty;
@property (nonatomic, readonly) BOOL hasCurrentItem;

@property (nonatomic, strong, readonly) AVPlayerItem* currentPlayerItem;
@property (nonatomic, strong, readonly) AVPlayerItem* nextPlayerItem;

- (BOOL) validateQueueItems;

// Item creation and cleanup
- (AVPlayerItem*) createPlayerItemWithUrl:(NSURL*)url;
- (void) cleanupItem:(AVPlayerItem*)playerItem;

// Item completion
- (void) advanceToNextItem;
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
- (void) postPlayerEvent:(NSString*)eventName withOldItem:(EMMediaItem*)oldItem withNewItem:(EMMediaItem*)newItem;
- (void) postPlayerEvent:(NSString*)eventName withItem:(EMMediaItem*)item atIndex:(NSUInteger)index;

@end

@implementation EMPlayer

@dynamic isPlaying;
@synthesize isSetup = isSetup_;
@dynamic currentTime;
@dynamic items;
@dynamic currentItem;
@dynamic nextItem;
@synthesize delegate = delegate_;
@dynamic isItemsEmpty;
@dynamic hasCurrentItem;
@dynamic currentPlayerItem;
@dynamic nextPlayerItem;

//
// Parent overrides
//

- (id) init {
  self = [super init];
  if (nil != self) {
    items_ = [NSMutableArray array];
    queuePlayer_ = nil;
    timeObserver_ = nil;
    isSetup_ = NO;
  }
  return self;
}

//
// EMPlaybackControl methods and dynamic properties
//

- (BOOL) isPlaying {
  if (self.hasCurrentItem) {
    // TODO: player/item status?
    return (0.0 != queuePlayer_.rate);
  } else {
    return NO;
  }
}

- (void) play {
  if (self.hasCurrentItem) {
    [queuePlayer_ play];
    if ([self.delegate respondsToSelector:@selector(player:didPlayItem:)]) {
      [self.delegate player:self didPlayItem:self.currentItem];
    }
    [self postPlayerEvent:EMPlayerDidPlay withItem:self.currentItem];
  }
}

- (void) pause {
  if (self.hasCurrentItem) {
    [queuePlayer_ pause];
    if ([self.delegate respondsToSelector:@selector(player:didPauseItem:)]) {
      [self.delegate player:self didPauseItem:self.currentItem];
    }
    [self postPlayerEvent:EMPlayerDidPause withItem:self.currentItem];
  }
}

- (void) jumpToTime:(NSTimeInterval)time {
  
  if (self.hasCurrentItem) {
    if (time < CMTimeGetSeconds(self.currentPlayerItem.duration)) {
      if (time < 0.0) {
        time = 0.0;
      }

      [queuePlayer_ seekToTime:CMTimeMakeWithSeconds(time, 1.0)];

    } else {
      // TODO: track completion logic here.
      // Hmm - will this trigger 'track complete' event?
    }
  }
}

- (void) jumpByTime:(NSTimeInterval)timeDelta {
  if (self.hasCurrentItem) {
    NSTimeInterval time = CMTimeGetSeconds(self.currentPlayerItem.currentTime) + timeDelta;
    [self jumpToTime:time];
  }
}

- (void) beginSeekForward:(BOOL)forward {
  // NOTE: could experiment with faster playback rather than jumping...
  [self seekTimeDelta:(forward ? 10.0 : -10.0) afterDuration:0.5];
  if ([self.delegate respondsToSelector:@selector(player:didStartSeekingItem:forward:)]) {
    [self.delegate player:self didStartSeekingItem:self.currentItem forward:YES];
  }
  [self postPlayerEvent:EMPlayerDidStartSeeking withItem:self.currentItem forward:forward];
}

- (void) endSeek {
  [self cancelSeekTime];
  if ([self.delegate respondsToSelector:@selector(player:didEndSeekingItem:)]) {
    [self.delegate player:self didEndSeekingItem:self.currentItem];
  }
  [self postPlayerEvent:EMPlayerDidEndSeeking withItem:self.currentItem];
}

- (BOOL) moveToNext {
  [self advanceToNextItem];
  return YES;
}

//
// Public methods and dynamic properties
//

- (NSTimeInterval) currentTime {
  return self.hasCurrentItem ? CMTimeGetSeconds(self.currentPlayerItem.currentTime) : 0.0;
}

- (NSArray*)items {
  return [NSArray arrayWithArray:items_];
}

- (EMMediaItem*) currentItem {
  if (self.hasCurrentItem) {
    return [items_ objectAtIndex:0];
  } else {
    return nil;
  }
}

- (EMMediaItem*) nextItem {
  if (self.hasCurrentItem) {
    return (1 < items_.count) ? [items_ objectAtIndex:1] : nil;
  } else {
    return nil;
  }
}


- (void) setup {
  queuePlayer_ = [[AVQueuePlayer alloc] init];
  [queuePlayer_ addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void) cleanup {

  // TODO: this was thrown together.
  [queuePlayer_ pause];
  if (0 < queuePlayer_.items.count) {
    [self removeItemAtIndex:0 error:nil];
  }
}

- (BOOL) addItem:(EMMediaItem*)media error:(NSError**)error {
  return [self insertItem:media atIndex:items_.count];
}

- (BOOL) insertItem:(EMMediaItem*)item atIndex:(NSUInteger)index {
  
  // sanity check:
  if (items_.count != queuePlayer_.items.count) {
    NSLog(@"items (%d) and queue items (%d) out of sync", items_.count, queuePlayer_.items.count);
  }
  
  NSUInteger existingItemIndex = [items_ indexOfObject:item];
  if (NSNotFound != existingItemIndex) {
    @throw [NSException exceptionWithName:@"EMPlayerException" reason:@"Inserting media item that already exists" userInfo:nil];
  }
  
  BOOL didInsert = NO;
  if (index <= items_.count) {
    AVPlayerItem* playerItem = [self createPlayerItemWithUrl:item.url];
    if (nil != playerItem) {
      AVPlayerItem* playerItemInsertAfter = (0 == index) ? nil : [queuePlayer_.items objectAtIndex:index - 1];

      if ([self.delegate respondsToSelector:@selector(player:willAddItem:atIndex:)]) {
        [self.delegate player:self willAddItem:item atIndex:index]; // not sure about count - before or after amount?
      }
      [self postPlayerEvent:EMPlayerWillAddItem withItem:item atIndex:index];
      
      [queuePlayer_ insertItem:playerItem afterItem:playerItemInsertAfter];
      [items_ insertObject:item atIndex:index];

      if ([self.delegate respondsToSelector:@selector(player:didAddItem:atIndex:)]) {
        [self.delegate player:self didAddItem:item atIndex:index]; // not sure about count - before or after amount?
      }
      [self postPlayerEvent:EMPlayerWillAddItem withItem:item atIndex:index];
      
      didInsert = YES;
    }
  }
  
  return didInsert;
}

- (BOOL) insertItems:(NSArray*)items atIndex:(NSUInteger)index {
  // TODO: special case for inserting at index '0'
  return NO;
}

- (BOOL) removeItem:(EMMediaItem*)item {
  NSUInteger removeItemIndex = [items_ indexOfObject:item];
  if (NSNotFound != removeItemIndex) {
    return nil != [self removeItemAtIndex:removeItemIndex error:nil];
  } else {
    return NO;
  }
}

- (EMMediaItem*) removeItemAtIndex:(NSUInteger)index error:(NSError**)error {

  // sanity check:
  if (items_.count != queuePlayer_.items.count) {
    NSLog(@"items (%d) and queue items (%d) out of sync", items_.count, queuePlayer_.items.count);
  }
  
  EMMediaItem* removedItem = nil;
  
  if (index < items_.count) {
    removedItem = [items_ objectAtIndex:index];
    
    if ([self.delegate respondsToSelector:@selector(player:willRemoveItem:atIndex:)]) {
      [self.delegate player:self willRemoveItem:removedItem atIndex:index];
    }
    [self postPlayerEvent:EMPlayerWillRemoveItem withItem:removedItem atIndex:index];
    
    AVPlayerItem* playerItemToRemove = [queuePlayer_.items objectAtIndex:index];
    if (0 == index) {
      // special case - advance?
      [queuePlayer_ pause]; // post notif?
                            // what about end of track cleanup?
      [self cleanupItem:playerItemToRemove];
      [queuePlayer_ advanceToNextItem];
    } else {
      [self cleanupItem:playerItemToRemove];
      [queuePlayer_ removeItem:playerItemToRemove];
    }
    [items_ removeObjectAtIndex:index];
    
    if ([self.delegate respondsToSelector:@selector(player:didRemoveItem:atIndex:)]) {
      [self.delegate player:self didRemoveItem:removedItem atIndex:index];
    }
    [self postPlayerEvent:EMPlayerWillRemoveItem withItem:removedItem atIndex:index];
  }
  
  return removedItem;
}

//
// NSObject overrides
//

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  BOOL handled = NO;
  if (object == queuePlayer_ && [keyPath isEqualToString:@"status"]) {
    
    if ([@(NSKeyValueChangeSetting) isEqual:[change objectForKey:NSKeyValueChangeNewKey]]) {
      [queuePlayer_ removeObserver:self forKeyPath:@"status" context:NULL];
      
      if (AVPlayerStatusReadyToPlay == queuePlayer_.status) {
        // hmm
        __block EMPlayer* blockSelf = self;
        timeObserver_ = [queuePlayer_ addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, 1)
                                                                   queue:dispatch_get_main_queue()
                                                              usingBlock:^(CMTime t) {
                                                                if (self.hasCurrentItem) {
                                                                  NSTimeInterval time = CMTimeGetSeconds(t);
                                                                  NSTimeInterval duration = CMTimeGetSeconds(blockSelf.currentPlayerItem.duration);
                                                                  if ([blockSelf.delegate respondsToSelector:@selector(player:didReachTime:forItem:duration:)]) {
                                                                    [blockSelf.delegate player:blockSelf didReachTime:time forItem:blockSelf.currentItem duration:duration];
                                                                  }
                                                                  [blockSelf postPlayerEvent:EMPlayerDidReachTime withItem:blockSelf.currentItem time:time duration:duration];
                                                                }
                                                              }];
        
        if ([self.delegate respondsToSelector:@selector(player:didInitalizeSuccessfully:)]) {
          [delegate_ player:self didInitalizeSuccessfully:YES];
        }
        [self postPlayerEvent:EMPlayerDidInitalizeSuccessfully];
        
        
      } else {
        if ([self.delegate respondsToSelector:@selector(player:didInitalizeSuccessfully:)]) {
          [delegate_ player:self didInitalizeSuccessfully:NO];
        }
        [self postPlayerEvent:EMPlayerFailedToInitialize];
      }
      
      handled = YES;
    }

  } else if ([object isKindOfClass:[AVPlayerItem class]] && [keyPath isEqualToString:@"status"]) {
    if ([@(NSKeyValueChangeSetting) isEqual:[change objectForKey:NSKeyValueChangeNewKey]]) {
      
      // TODO: yeah, I'm just not handling this yet...
     
      handled = YES;
    }
    
  } else if ([object isKindOfClass:[AVPlayerItem class]] && [keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
    if ([@(NSKeyValueChangeSetting) isEqual:[change objectForKey:NSKeyValueChangeNewKey]]) {
      // TODO: handle this as appropriate
      handled = YES;
    }
    
  }
  
  if (!handled) {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

//
// Helper methods and dynamic properties
//

- (BOOL) isItemsEmpty {
  return (nil == items_) || (0 == items_.count);
}

- (BOOL) hasCurrentItem {
  // NOTE: unclear what the second condition what checking...
  return !self.isItemsEmpty;
}

- (AVPlayerItem*) currentPlayerItem {
  if (self.hasCurrentItem) {
    return [queuePlayer_.items objectAtIndex:0];
  } else {
    return nil;
  }
}

- (AVPlayerItem*) nextPlayerItem {
  if (self.hasCurrentItem && (1 < items_.count && 1 < queuePlayer_.items.count)) {
    return [queuePlayer_.items objectAtIndex:1];
  } else {
    return nil;
  }
}

- (BOOL) validateQueueItems {
  if (!self.hasCurrentItem) {
    return 0 == queuePlayer_.items.count;
  } else if (queuePlayer_.items.count == items_.count) {
    __block BOOL sameUrls = YES;
    [queuePlayer_.items enumerateObjectsUsingBlock:^(id playerItem, NSUInteger idx, BOOL *stop) {
      if ([[playerItem asset] isKindOfClass:[AVURLAsset class]]) {
        if (![[[items_ objectAtIndex:idx] url] isEqual:[(AVURLAsset*)[playerItem asset] URL]]) {
          sameUrls = NO;
          *stop = YES;
        }
      }
    }];
    return sameUrls;
  } else {
    return NO;
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

- (void) cleanupItem:(AVPlayerItem*)playerItem {
  
  [playerItem removeObserver:self forKeyPath:@"status" context:NULL];
  [playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:NULL];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:playerItem];
}

- (void) advanceToNextItem {
  if (self.hasCurrentItem) {
    [queuePlayer_ pause];
    [self cleanupItem:self.currentPlayerItem];
    
    EMMediaItem* oldItem = self.currentItem;
    EMMediaItem* newItem = self.nextItem;
    
    if ([self.delegate respondsToSelector:@selector(player:willAdvanceFromItem:toItem:)]) {
      [self.delegate player:self willAdvanceFromItem:oldItem toItem:newItem];
    }
    [self postPlayerEvent:EMPlayerWillAdvance withOldItem:oldItem withNewItem:newItem];
    
    [queuePlayer_ advanceToNextItem];
    [items_ removeObjectAtIndex:0];
    
    if ([self.delegate respondsToSelector:@selector(player:didAdvanceFromItem:toItem:)]) {
      [self.delegate player:self didAdvanceFromItem:oldItem toItem:newItem];
    }
    [self postPlayerEvent:EMPlayerDidAdvance withOldItem:oldItem withNewItem:newItem];
    
  }
}

- (void) itemCompleted:(NSNotification*)notification {
  
  if ([self.delegate respondsToSelector:@selector(player:didCompleteItem:)]) {
    [self.delegate player:self didCompleteItem:self.currentItem];
  }
  
  [self advanceToNextItem];
  
  // anything else?
  
}

- (void) itemFailedToComplete:(NSNotification*)notification {
  // uhhh....???
}

- (void) cancelSeekTime {
  [seekTimer_ invalidate];
  seekTimer_ = nil;
}

- (void) seekOnTimer:(NSTimer*)timer {
  NSTimeInterval timeDelta = [[timer.userInfo objectForKey:@"timeDelta"] doubleValue];
  NSTimeInterval duration = [[timer.userInfo objectForKey:@"duration"] doubleValue];
  
  [self cancelSeekTime];
  
  if (0 < timeDelta) {
    // forward
    NSTimeInterval currentTime = CMTimeGetSeconds(queuePlayer_.currentTime);
    NSTimeInterval itemDuration = CMTimeGetSeconds(self.currentPlayerItem.duration);
    if (timeDelta < (itemDuration - currentTime)) {
      [queuePlayer_ seekToTime:CMTimeMakeWithSeconds(self.currentTime + timeDelta, 1.0)];
      [self seekTimeDelta:timeDelta afterDuration:duration];
    } else {
      // TODO: whatever 'end of track' actions would normally be performed - stop playing, advance, etc
    }
  } else {
    // backward
    if (timeDelta < self.currentTime) {
      [queuePlayer_ seekToTime:CMTimeMakeWithSeconds(self.currentTime + timeDelta, 1.0)];
      [self seekTimeDelta:timeDelta afterDuration:duration];
    } else {
      [queuePlayer_ seekToTime:CMTimeMakeWithSeconds(0.0, 1.0)];
      // TODO: whatever 'endSeek' actions are here - start playing again, who knows
    }
  }
  
}

- (void) seekTimeDelta:(NSTimeInterval)timeDelta afterDuration:(NSTimeInterval)duration {
  [self cancelSeekTime];
  seekTimer_ = [NSTimer scheduledTimerWithTimeInterval:duration
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

- (void) postPlayerEvent:(NSString*)eventName withOldItem:(EMMediaItem*)oldItem withNewItem:(EMMediaItem*)newItem {
  [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:self userInfo:(nil != newItem) ? @{ EMOldItemKey : oldItem, EMNewItemKey : newItem } : @{ EMOldItemKey : oldItem }];
}

- (void) postPlayerEvent:(NSString*)eventName withItem:(EMMediaItem*)item atIndex:(NSUInteger)index {
  [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:self userInfo:@{ EMMediaItemKey : item, EMIndexKey : @(index) }];
}

@end
