//
// EMMediaItem.m
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

#import "EMMediaItem.h"

@implementation EMMediaItem

@synthesize url = url_;
@synthesize userInfo = userInfo_;

- (id) initWithUrl:(NSURL*)url {
  return [self initWithUrl:url userInfo:nil];
}

- (id) initWithUrl:(NSURL*)url userInfo:(id)userInfo {
  self = [super init];
  if (nil != self) {
    url_ = url;
    userInfo_ = userInfo;
  }
  return self;
}

+ (id) itemWithUrl:(NSURL*)url {
  return [EMMediaItem itemWithUrl:url userInfo:nil];
}

+ (id) itemWithUrl:(NSURL*)url userInfo:(id)userInfo {
  return [[EMMediaItem alloc] initWithUrl:url userInfo:userInfo];
}

@end
