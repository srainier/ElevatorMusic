//
// AppDelegate.m
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

#import "AppDelegate.h"
#import "EMBackgroundController.h"
#import "SamplePlayController.h"
#import "EMPlayer.h"

@interface AppDelegate ()

@property (nonatomic, retain) EMBackgroundController* backgroundController;
@property (nonatomic, retain) SamplePlayController* samplePlayController;
@property (nonatomic, retain) EMPlayer* player;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize backgroundController = backgroundController_;
@synthesize samplePlayController = samplePlayController_;
@synthesize player = player_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  player_ = [[EMPlayer alloc] init];
  backgroundController_ = [[EMBackgroundController alloc] init];
  backgroundController_.player = player_;
  
  samplePlayController_ = [[SamplePlayController alloc] initWithNibName:nil bundle:nil];
  samplePlayController_.player = player_;
  [backgroundController_.view addSubview:samplePlayController_.view];
  
  [backgroundController_ becomeActiveAudioController];
  
  self.window.rootViewController = backgroundController_;
  self.window.backgroundColor = [UIColor whiteColor];
  [self.window makeKeyAndVisible];
  return YES;
}

@end
