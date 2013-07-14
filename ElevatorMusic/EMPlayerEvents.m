//
// EMPlayerEvents.m
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

#import "EMPlayerEvents.h"

NSString* const EMMediaItemKey = @"com.ElevatorMusic.MediaItemKey";
NSString* const EMTimeKey = @"com.ElevatorMusic.TimeKey";
NSString* const EMDurationKey = @"com.ElevatorMusic.DurationKey";
NSString* const EMSeekForwardKey = @"com.ElevatorMusic.SeekForwardKey";

NSString* const EMPlayerDidInitalize = @"com.ElevatorMusic.PlayerDidInitalize";
NSString* const EMPlayerFailedToInitialize = @"com.ElevatorMusic.PlayerFailedToInitialize";
NSString* const EMPlayerWillInitalizeMediaItem = @"com.ElevatorMusic.PlayerWillInitalizeMediaItem";
NSString* const EMPlayerDidInitalizeMediaItem = @"com.ElevatorMusic.PlayerDidInitalizeMediaItem";
NSString* const EMPlayerFailedToInitializeMediaItem = @"com.ElevatorMusic.PlayerFailedToInitializeMediaItem";
NSString* const EMPlayerWillRemoveCurrentMediaItem = @"com.ElevatorMusic.PlayerWillRemoveCurrentMediaItem";
NSString* const EMPlayerDidRemoveCurrentMediaItem = @"com.ElevatorMusic.PlayerDidRemoveCurrentMediaItem";

NSString* const EMPlayerDidPlay = @"com.ElevatorMusic.PlayerDidPlay";
NSString* const EMPlayerDidPause = @"com.ElevatorMusic.PlayerDidPause";
NSString* const EMPlayerDidReachTime = @"com.ElevatorMusic.PlayerDidReachTime";
NSString* const EMPlayerDidComplete = @"com.ElevatorMusic.PlayerDidComplete";
NSString* const EMPlayerDidStartSeeking = @"com.ElevatorMusic.PlayerDidStartSeeking";
NSString* const EMPlayerDidEndSeeking = @"com.ElevatorMusic.PlayerDidEndSeeking";