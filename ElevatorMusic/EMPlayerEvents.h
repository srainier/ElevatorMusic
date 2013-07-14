//
// EMPlayerEvents.h
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

#import <Foundation/Foundation.h>

// TODO: document what keys are with what notifications.

extern NSString* const EMMediaItemKey; // EMMediaItem
extern NSString* const EMTimeKey; // NSNumber (NSTimeInterval)
extern NSString* const EMDurationKey; // NSNumber (NSTimeInterval)
extern NSString* const EMSeekForwardKey; // bool

extern NSString* const EMPlayerDidInitalize;
extern NSString* const EMPlayerFailedToInitialize;

extern NSString* const EMPlayerWillInitalizeMediaItem;
extern NSString* const EMPlayerDidInitalizeMediaItem;
extern NSString* const EMPlayerFailedToInitializeMediaItem;
extern NSString* const EMPlayerWillRemoveCurrentMediaItem;
extern NSString* const EMPlayerDidRemoveCurrentMediaItem;

extern NSString* const EMPlayerDidPlay; //Item;
extern NSString* const EMPlayerDidPause; //tItem;
extern NSString* const EMPlayerDidReachTime; // time, item
extern NSString* const EMPlayerDidComplete; //Item;
extern NSString* const EMPlayerDidStartSeeking; //Item, forward
extern NSString* const EMPlayerDidEndSeeking; //Item, forward
