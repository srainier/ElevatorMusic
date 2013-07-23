//
// SamplePlayController.m
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

#import "SamplePlayController.h"
#import "EMMediaItem.h"
#import "EMPlayerSession.h"
#import "EMNowPlayingManager.h"
#import <MediaPlayer/MediaPlayer.h>

@interface SamplePlayController () {
  BOOL _isUpdatingTable;
  BOOL _isDraggingSlider;
  EMPlayerSession *_playerSession;
  EMNowPlayingManager *_nowPlayingManager;
}

@property (nonatomic, retain) IBOutlet UITextField* urlField;
@property (nonatomic, retain) IBOutlet UISlider* timeSlider;
@property (nonatomic, retain) IBOutlet UITableView* playlistTable;
@property (nonatomic, retain) IBOutlet UIButton* playButton;
@property (nonatomic, retain) IBOutlet UIButton* backwardButton;
@property (nonatomic, retain) IBOutlet UIButton* forwardButton;
@property (nonatomic, retain) IBOutlet UIView* volumeViewContainer;

- (void) playButtonTapGesture:(UITapGestureRecognizer*)gesture;
- (void) forwardButtonTapGesture:(UITapGestureRecognizer*)gesture;
- (void) forwardButtonPressGesture:(UILongPressGestureRecognizer*)gesture;
- (void) backwardButtonTapGesture:(UITapGestureRecognizer*)gesture;
- (void) backwardButtonPressGesture:(UILongPressGestureRecognizer*)gesture;

@end

@interface SamplePlayController (PlayerDelegate) <EMPlayerDelegate>
@end

@interface SamplePlayController (UrlInput) <UITextFieldDelegate>
@end

@interface SamplePlayController (TimeSlider)

- (void) timeSliderTouchBegan:(UISlider*)slider;
- (void) timeSliderTouchEnded:(UISlider*)slider;
- (void) timeSliderValueChanged:(UISlider*)slider;

@end

@interface SamplePlayController (PlaylistTable) <UITableViewDelegate, UITableViewDataSource>
@end

@implementation SamplePlayController

// Public
@synthesize player = _player;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _isUpdatingTable = NO;
    _isDraggingSlider = NO;
    _playerSession = [[EMPlayerSession alloc] init];
    _nowPlayingManager = [[EMNowPlayingManager alloc] init];
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  // Url field
  self.urlField.delegate = self;
  
  // Time slider
  [self.timeSlider addTarget:self action:@selector(timeSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
  [self.timeSlider addTarget:self action:@selector(timeSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
  [self.timeSlider addTarget:self action:@selector(timeSliderTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
  [self.timeSlider addTarget:self action:@selector(timeSliderTouchEnded:) forControlEvents:UIControlEventTouchCancel];
  [self.timeSlider addTarget:self action:@selector(timeSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
  
  // Playlist table
  self.playlistTable.delegate = self;
  self.playlistTable.dataSource = self;
  
  // Playback controls
  [self.playButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playButtonTapGesture:)]];
  [self.forwardButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forwardButtonTapGesture:)]];
  [self.forwardButton addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(forwardButtonPressGesture:)]];
  [self.backwardButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backwardButtonTapGesture:)]];
  [self.backwardButton addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(backwardButtonPressGesture:)]];

  MPVolumeView* volumeView = [[MPVolumeView alloc] initWithFrame:self.volumeViewContainer.bounds];
  volumeView.backgroundColor = [UIColor clearColor];
  [self.volumeViewContainer addSubview:volumeView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) setPlayer:(EMPlayer *)player {
  if (nil != _player) {
    _player.delegate = nil;
    [_player cleanup];
  }

  _player = player;
  _player.delegate = self;
  [_player setup];
}

- (BOOL) canBecomeFirstResponder {
  return YES;
}

- (void) remoteControlReceivedWithEvent:(UIEvent *)event {
  if (![_playerSession handleRemoteControlReceivedEvent:event withPlayer:_player]) {
    [super remoteControlReceivedWithEvent:event];
  }
}

- (void) becomeActiveAudioController {
  
  [_playerSession startAudioSession];
  [self becomeFirstResponder];
  [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
  [_nowPlayingManager start];
  
}

- (void) playButtonTapGesture:(UITapGestureRecognizer*)gesture {
  if (_player.isPlaying) {
    [_player pause];
  } else {
    [_player play];
  }
}

- (void) forwardButtonTapGesture:(UITapGestureRecognizer*)gesture {
  BOOL gotoNextTrack = YES;
  if (gotoNextTrack) {
    [_player moveToNext];
  } else {
    [_player jumpByTime:30];
  }
}

- (void) forwardButtonPressGesture:(UILongPressGestureRecognizer*)gesture {
  if (UIGestureRecognizerStateBegan == gesture.state) {
    [_player beginSeekForward:YES];
  } else if(UIGestureRecognizerStateEnded == gesture.state ||
            UIGestureRecognizerStateCancelled == gesture.state ||
            UIGestureRecognizerStateFailed == gesture.state) {
    // could be cancel, end, etc.
    [_player endSeek];
  }
}

- (void) backwardButtonTapGesture:(UITapGestureRecognizer*)gesture {
  BOOL gotoPreviousTrack = NO;
  if (gotoPreviousTrack) {

  } else {
    [_player jumpByTime:-30];
  }
}

- (void) backwardButtonPressGesture:(UILongPressGestureRecognizer*)gesture {
  if (UIGestureRecognizerStateBegan == gesture.state) {
    [_player beginSeekForward:NO];
  } else {
    // could be cancel, end, etc.
    [_player endSeek];
  }
}

@end

@implementation SamplePlayController (PlayerDelegate)

- (void) player:(EMPlayer*)player didPlayItem:(EMMediaItem*)item {
  [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
}

- (void) player:(EMPlayer*)player didPauseItem:(EMMediaItem*)item {
  [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
}

- (void) player:(EMPlayer*)player didReachTime:(NSTimeInterval)time forItem:(EMMediaItem*)item duration:(NSTimeInterval)duration {
  if (!_isDraggingSlider) {
    self.timeSlider.minimumValue = 0.0;
    self.timeSlider.maximumValue = duration;
    self.timeSlider.value = time;
  }
}

- (void) player:(EMPlayer*)player didCompleteItem:(EMMediaItem*)item {
  [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
}

@end

@implementation SamplePlayController (UrlInput)

- (BOOL)textFieldShouldClear:(UITextField *)textField {
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];

  NSError* error = nil;
  NSURL* itemUrl = [NSURL URLWithString:textField.text];
  if (nil != itemUrl) {
    
    EMMediaItem* mediaItem = [[EMMediaItem alloc] initWithUrl:itemUrl];
    mediaItem.title = @"Sample Title";
    mediaItem.artist = @"Sample Artist";
    mediaItem.album = @"Sample Album";
    [_player addItem:mediaItem];
    
  } else {
    error = [NSError errorWithDomain:@"SamplePlay" code:0 userInfo:nil];
  }

  return YES;
}

@end

@implementation SamplePlayController (TimeSlider)

- (void) timeSliderTouchBegan:(UISlider*)slider {
  _isDraggingSlider = YES;
}

- (void) timeSliderTouchEnded:(UISlider*)slider {
  _isDraggingSlider = NO;
}

- (void) timeSliderValueChanged:(UISlider*)slider {
  [_player jumpToTime:slider.value];
}

@end

@implementation SamplePlayController (PlaylistTable)

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _player.currentItem != nil ? 1 : 0;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"sample-cell"];
  
  cell.textLabel.text = _player.currentItem.url.relativeString;
  
  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
