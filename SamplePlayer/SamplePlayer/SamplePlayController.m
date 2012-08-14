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
#import <MediaPlayer/MediaPlayer.h>

@interface SamplePlayController () {
  BOOL isUpdatingTable_;
  BOOL isDraggingSlider_;
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
@synthesize player = player_;
// Internal interface
@synthesize urlField = urlField_;
@synthesize timeSlider = timeSlider_;
@synthesize playlistTable = playlistTable_;
@synthesize playButton = playButton_;
@synthesize backwardButton = backwardButton_;
@synthesize forwardButton = forwardButton_;
@synthesize volumeViewContainer = volumeViewContainer_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    isUpdatingTable_ = NO;
    isDraggingSlider_ = NO;
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
  if (nil != player_) {
    player_.delegate = nil;
    [player_ cleanup];
  }

  player_ = player;
  player_.delegate = self;
  [player_ setup];
}

- (void) playButtonTapGesture:(UITapGestureRecognizer*)gesture {
  if (player_.isPlaying) {
    [player_ pause];
  } else {
    [player_ play];
  }
}

- (void) forwardButtonTapGesture:(UITapGestureRecognizer*)gesture {
  BOOL gotoNextTrack = YES;
  if (gotoNextTrack) {
    [player_ moveToNext];
  } else {
    [player_ jumpByTime:30];
  }
}

- (void) forwardButtonPressGesture:(UILongPressGestureRecognizer*)gesture {
  if (UIGestureRecognizerStateBegan == gesture.state) {
    [player_ beginSeekForward:YES];
  } else if(UIGestureRecognizerStateEnded == gesture.state ||
            UIGestureRecognizerStateCancelled == gesture.state ||
            UIGestureRecognizerStateFailed == gesture.state) {
    // could be cancel, end, etc.
    [player_ endSeek];
  }
}

- (void) backwardButtonTapGesture:(UITapGestureRecognizer*)gesture {
  BOOL gotoPreviousTrack = NO;
  if (gotoPreviousTrack) {

  } else {
    [player_ jumpByTime:-30];
  }
}

- (void) backwardButtonPressGesture:(UILongPressGestureRecognizer*)gesture {
  if (UIGestureRecognizerStateBegan == gesture.state) {
    [player_ beginSeekForward:NO];
  } else {
    // could be cancel, end, etc.
    [player_ endSeek];
  }
}

@end

@implementation SamplePlayController (PlayerDelegate)

- (void) player:(EMPlayer*)player didInitalizeSuccessfully:(BOOL)success {
  // TODO
}

- (void) player:(EMPlayer*)player didInitalizeMediaItem:(EMMediaItem*)item success:(BOOL)success {
  // TODO: update table view cell
}

- (void) player:(EMPlayer*)player didStartItem:(EMMediaItem*)item {
  // TODO: update playing state
}

- (void) player:(EMPlayer*)player didPlayItem:(EMMediaItem*)item {
  // TODO: update play button state
}

- (void) player:(EMPlayer*)player didPauseItem:(EMMediaItem*)item {
  // TODO: update play button state
}

- (void) player:(EMPlayer*)player didReachTime:(NSTimeInterval)time forItem:(EMMediaItem*)item duration:(NSTimeInterval)duration {
  if (!isDraggingSlider_) {
    self.timeSlider.minimumValue = 0.0;
    self.timeSlider.maximumValue = duration;
    self.timeSlider.value = time;
  }
}

- (void) player:(EMPlayer*)player didCompleteItem:(EMMediaItem*)item {
  // TODO:
}

- (void) player:(EMPlayer*)player didStartSeekingItem:(EMMediaItem*)item forward:(BOOL)forward {
  
}

- (void) player:(EMPlayer*)player didEndSeekingItem:(EMMediaItem*)item {
  
}

- (void) player:(EMPlayer*)player willAdvanceFromItem:(EMMediaItem*)oldItem toItem:(EMMediaItem*)newItem {
  
}

- (void) player:(EMPlayer*)player didAdvanceFromItem:(EMMediaItem*)oldItem toItem:(EMMediaItem*)newItem {
  
}

- (void) player:(EMPlayer*)player willAddItem:(EMMediaItem*)item atIndex:(NSUInteger)index totalItems:(NSUInteger)totalItems {
  isUpdatingTable_ = YES;
}

- (void) player:(EMPlayer*)player didAddItem:(EMMediaItem*)item atIndex:(NSUInteger)index totalItems:(NSUInteger)totalItems {
  isUpdatingTable_ = NO;
  
  [self.playlistTable beginUpdates];
  [self.playlistTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                            withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.playlistTable endUpdates];
}

- (void) player:(EMPlayer*)player willRemoveItem:(EMMediaItem*)item atIndex:(NSUInteger)index totalItems:(NSUInteger)totalItems {
  isUpdatingTable_ = YES;
}

- (void) player:(EMPlayer*)player didRemoveItem:(EMMediaItem*)item atIndex:(NSUInteger)index totalItems:(NSUInteger)totalItems {
  isUpdatingTable_ = NO;

  [self.playlistTable beginUpdates];
  [self.playlistTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                            withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.playlistTable endUpdates];
}

@end

@implementation SamplePlayController (UrlInput)

- (BOOL)textFieldShouldClear:(UITextField *)textField {
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];

  BOOL addedItem = NO;
  NSError* error = nil;
  NSURL* itemUrl = [NSURL URLWithString:textField.text];
  if (nil != itemUrl) {
    
    EMMediaItem* mediaItem = [[EMMediaItem alloc] initWithUrl:itemUrl];
    if (!(addedItem = [player_ addItem:mediaItem error:&error])) {
      // something with the error
    }
    
  } else {
    error = [NSError errorWithDomain:@"SamplePlay" code:0 userInfo:nil];
  }
  
  if (!addedItem) {
    // TODO: display error message
  }
  
  return YES;
}

@end

@implementation SamplePlayController (TimeSlider)

- (void) timeSliderTouchBegan:(UISlider*)slider {
  isDraggingSlider_ = YES;
}

- (void) timeSliderTouchEnded:(UISlider*)slider {
  isDraggingSlider_ = NO;
}

- (void) timeSliderValueChanged:(UISlider*)slider {
  [player_ jumpToTime:slider.value];
}

@end

@implementation SamplePlayController (PlaylistTable)

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return player_.items.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"sample-cell"];
  
  if (nil == cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sample-cell"];
  }
  
  cell.textLabel.text = [[(EMMediaItem*)[player_.items objectAtIndex:indexPath.row] url] relativeString];
  
  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
