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

NSString* const EMMediaItemKey = @"com.ElevatorMusic.EMMediaItemKey";
NSString* const EMTimeKey = @"com.ElevatorMusic.EMTimeKey";
NSString* const EMDurationKey = @"com.ElevatorMusic.EMDurationKey";
NSString* const EMSeekForwardKey = @"com.ElevatorMusic.EMSeekForwardKey";
NSString* const EMOldItemKey = @"com.ElevatorMusic.EMOldItemKey";
NSString* const EMNewItemKey = @"com.ElevatorMusic.EMNewItemKey";
NSString* const EMIndexKey = @"com.ElevatorMusic.EMIndexKey";
NSString* const EMPlayerDidInitalizeSuccessfully = @"com.ElevatorMusic.EMPlayerDidInitalizeSuccessfully";
NSString* const EMPlayerFailedToInitialize = @"com.ElevatorMusic.EMPlayerFailedToInitialize";
NSString* const EMPlayerDidInitalizeMediaItemSuccessfully = @"com.ElevatorMusic.EMPlayerDidInitalizeMediaItemSuccessfully";
NSString* const EMPlayerFailedToInitializeMediaItem = @"com.ElevatorMusic.EMPlayerFailedToInitializeMediaItem";
NSString* const EMPlayerDidStart = @"com.ElevatorMusic.EMPlayerDidStart";
NSString* const EMPlayerDidPlay = @"com.ElevatorMusic.EMPlayerDidPlay";
NSString* const EMPlayerDidPause = @"com.ElevatorMusic.EMPlayerDidPause";
NSString* const EMPlayerDidReachTime = @"com.ElevatorMusic.EMPlayerDidReachTime";
NSString* const EMPlayerDidComplete = @"com.ElevatorMusic.EMPlayerDidComplete";
NSString* const EMPlayerDidStartSeeking = @"com.ElevatorMusic.EMPlayerDidStartSeeking";
NSString* const EMPlayerDidEndSeeking = @"com.ElevatorMusic.EMPlayerDidEndSeeking";
NSString* const EMPlayerWillAdvance = @"com.ElevatorMusic.EMPlayerWillAdvance";
NSString* const EMPlayerDidAdvance = @"com.ElevatorMusic.EMPlayerDidAdvance";
NSString* const EMPlayerWillAddItem = @"com.ElevatorMusic.EMPlayerWillAddItem";
NSString* const EMPlayerDidAddItem = @"com.ElevatorMusic.EMPlayerDidAddItem";
NSString* const EMPlayerWillRemoveItem = @"com.ElevatorMusic.EMPlayerWillRemoveItem";
NSString* const EMPlayerDidRemoveItem = @"com.ElevatorMusic.EMPlayerDidRemoveItem";
