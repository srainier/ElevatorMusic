//
//  EMBackgroundControllerProxy.h
//  Puddy
//
//  Created by Shane Arney on 11/11/12.
//  Copyright (c) 2012 srainier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "EMPlaybackControl.h"

@interface EMBackgroundControllerProxy : NSObject<AVAudioSessionDelegate>

@property (nonatomic, weak) id<EMPlaybackControl> player;
@property (nonatomic, weak) UIResponder* proxyResponder;

- (void) becomeActiveAudioController;
- (void) resignActiveAudioController;

- (BOOL) handleRemoteControlReceivedEvent:(UIEvent *)event;

@end
