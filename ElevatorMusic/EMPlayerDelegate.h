//
// EMPlayerDelegate.h
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
@class EMMediaItem;
@class EMPlayer;

@protocol EMPlayerDelegate <NSObject>

@optional

- (void) playerDidInitialize:(EMPlayer*)player;
- (void) playerFailedToInitialize:(EMPlayer*)player;

- (void) player:(EMPlayer*)player willInitalizeMediaItem:(EMMediaItem*)item;
- (void) player:(EMPlayer*)player didInitalizeMediaItem:(EMMediaItem*)item;
- (void) player:(EMPlayer*)player failedToInitalizeMediaItem:(EMMediaItem*)item;
- (void) player:(EMPlayer*)player willRemoveCurrentMediaItem:(EMMediaItem*)item;
- (void) player:(EMPlayer*)player didRemoveCurrentMediaItem:(EMMediaItem*)item;

- (void) player:(EMPlayer*)player didPlayItem:(EMMediaItem*)item;
- (void) player:(EMPlayer*)player didPauseItem:(EMMediaItem*)item;
- (void) player:(EMPlayer*)player didReachTime:(NSTimeInterval)time forItem:(EMMediaItem*)item duration:(NSTimeInterval)duration;
- (void) player:(EMPlayer*)player didCompleteItem:(EMMediaItem*)item;

- (void) player:(EMPlayer*)player didStartSeekingItem:(EMMediaItem*)item forward:(BOOL)forward;
- (void) player:(EMPlayer*)player didEndSeekingItem:(EMMediaItem*)item;

@end
