//
//  EMNowPlayingManager.m
//  Puddy
//
//  Created by Shane Arney on 9/7/12.
//  Copyright (c) 2012 srainier. All rights reserved.
//

#import "EMNowPlayingManager.h"
#import "EMMediaItem.h"
#import "EMPlayerEvents.h"
#import <MediaPlayer/MediaPlayer.h>

@interface EMNowPlayingManager ()

- (void) playerDidPlay:(NSNotification*)notification;

@end

@implementation EMNowPlayingManager

- (void) start {
  NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self selector:@selector(playerDidPlay:) name:EMPlayerDidPlay object:nil];
}

- (void) stop {
  NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
  [nc removeObserver:self name:EMPlayerDidPlay object:nil];
}

//
// Notification handlers
//

- (void) playerDidPlay:(NSNotification*)notification {
  EMMediaItem* item = [notification.userInfo objectForKey:EMMediaItemKey];

  NSMutableDictionary* nowPlayingInfo = [NSMutableDictionary dictionary];
  if (nil != item.title) {
    [nowPlayingInfo setObject:item.title
                       forKey:MPMediaItemPropertyTitle];
  }
  if (nil != item.artist) {
    [nowPlayingInfo setObject:item.artist
                       forKey:MPMediaItemPropertyArtist];
  }
  if (nil != item.album) {
    [nowPlayingInfo setObject:item.album
                       forKey:MPMediaItemPropertyAlbumTitle];
  }
  if (nil != item.artwork) {
    UIImage* artworkImage = [UIImage imageWithData:item.artwork];

    if (nil != artworkImage) {
      [nowPlayingInfo setObject:[[MPMediaItemArtwork alloc] initWithImage:artworkImage]
                         forKey:MPMediaItemPropertyArtwork];
    }
  }

  [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlayingInfo];
}


@end
