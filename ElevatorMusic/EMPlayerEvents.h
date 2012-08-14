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
extern NSString* const EMOldItemKey; // EMMediaItem
extern NSString* const EMNewItemKey; // EMMediaItem
extern NSString* const EMIndexKey; // NSUInteger

extern NSString* const EMPlayerDidInitalizeSuccessfully;
extern NSString* const EMPlayerFailedToInitialize;

extern NSString* const EMPlayerDidInitalizeMediaItemSuccessfully;
extern NSString* const EMPlayerFailedToInitializeMediaItem;

extern NSString* const EMPlayerDidStart; //Item;
extern NSString* const EMPlayerDidPlay; //Item;
extern NSString* const EMPlayerDidPause; //tItem;
extern NSString* const EMPlayerDidReachTime; // time, item
extern NSString* const EMPlayerDidComplete; //Item;
extern NSString* const EMPlayerDidStartSeeking; //Item, forward
extern NSString* const EMPlayerDidEndSeeking; //Item, forward
extern NSString* const EMPlayerWillAdvance; // old item, new item, forward
extern NSString* const EMPlayerDidAdvance;  // old item, new item, forward
extern NSString* const EMPlayerWillAddItem; // item, index, total
extern NSString* const EMPlayerDidAddItem; // item, index, total
extern NSString* const EMPlayerWillRemoveItem; // item, index, total
extern NSString* const EMPlayerDidRemoveItem;
