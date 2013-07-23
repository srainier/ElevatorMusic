ElevatorMusic
=============

A set of classes for managing background audio on iOS

How many people don't have their own ideas for how a music or podcast client
should work? About as many as want to write the boilerplate audio playback code
for their client. **ElevatorMusic** is just that project - a set of classes
that take care of audio playback while you work on the client's user
experience.

## Adding ElevatorMusic to Your App

### Requirements

* Your app must target iOS 5 or greater
* The AVFoundation and CoreMedia frameworks must be added to your project
* All ElevatorMusic .h and .m source files should be added to your project

### Project Setup

Your root view controller must implement the following methods:

```objective-c
- (BOOL) canBecomeFirstResponder {
  return YES;
}

- (void) remoteControlReceivedWithEvent:(UIEvent *)event {
  BOOL handled = NO;
  // Handle with EMPlayerSession or your own code.
  handled = [_playerSession remoteControlReceivedWithEvent:event withPlayer:_player];
  if (!handled) {
    [super remoteControlReceivedWithEvent:event];
  }
}
```

You will also need to add ```audio``` to the ```UIBackgroundModes``` array
in your app's info.plist.

### Player setup

With your project setup for background audio playback you can create
an ```EMPlayer``` object and start audio playback.

```objective-c
@interface Controller (EMPlayerDelegate) {
  EMPlayer *_player;
  EMPlayerSession *_playerSession;
}
// ...
- (void) someMethod {

  // Create the player.
  _player = [[EMPlayer alloc] init];
  _player.delegate = self;

  // Add an item to the player.
  EMMediaItem *mediaItem = [EMMediaItem itemWithUrl:[NSURL URLWithString:@"http://example.com/path/to.mp3"]];
  [_player addItem:mediaItem];
  
  // Create the player session and make the app the primary audio playback app.
  _playerSession = [[EMPlayerSession alloc] init];
  [_playerSession startAudioSession];
  [self becomeFirstResponder];
  [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
  
  // Play the audio.
  [_player play]; 
}
```

### Lockscreen Playback Information

Audio playback apps should show the user information about what's playing on
the lock screen. ElevatorMusic provides the **EMNowPlayingManager** to aid in
this task.

To use this functionality a ```EMNowPlayingManager``` instance needs to be
created.

```objective-c
@interface Controller (EMPlayerDelegate) {
  EMNowPlayingManager *_nowPlayingManager;
  // Other player object declarations follow...
}
// ...
- (void) someMethod {
  _nowPlayingManager = [[EMNowPlayingManager alloc] init];
  [_nowPlayingManager start];
  // Player setup code follows...
}
```

The ```EMNowPlayingManager``` object will listen for the ```EMPlayerDidPlay```
and ```EMPlayerDidComplete``` notifications posted by the ```EMPlayer```. The
```EMPlayerDidPlay``` notification will contain the ```EMMediaItem``` for the
notification. If any of the title/artist/album/artwork properties are set for
the ```EMMediaItem``` the ```EMNowPlayingManager``` will display that data on
the lock screen.

```objective-c
- (void) someMethod {
  // ...
  mediaItem.title = @"Sample Title";
  mediaItem.artist = @"Sample Artist";
  mediaItem.album = @"Sample Album";
  UIImage *albumArtwork = [UIImage imageFromSomewhere];
  mediaItem.artwork = UIImageJPEGRepresentation(albumArtwork, 1.0);
  // ...
}
```

### Sample Project

A SamplePlayer project is included to demonstrate all of this in action.

## Credits and Contact

ElevatorMusic was created by [Shane Arney](http://github.com/srainier) to
scratch a side-project itch. You can find him on twitter at
[@srainier](https://twitter.com/srainier).
