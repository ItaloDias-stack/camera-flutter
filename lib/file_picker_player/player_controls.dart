import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';

class FeedPlayerPortraitControls extends StatelessWidget {
  FeedPlayerPortraitControls({Key? key, this.flickManager}) : super(key: key);

  final FlickManager? flickManager;

  bool isMute = true;
  toggleMute() {
    flickManager?.flickControlManager?.toggleMute();
    isMute = flickManager?.flickControlManager?.isMute ?? false;
    if (isMute) {
      flickManager!.flickControlManager?.mute();
    } else {
      flickManager!.flickControlManager?.unmute();
    }
  }

  @override
  Widget build(BuildContext context) {
    //FlickDisplayManager displayManager =
    //    Provider.of<FlickDisplayManager>(context);
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          FlickAutoHideChild(
            showIfVideoNotInitialized: false,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const FlickLeftDuration(),
              ),
            ),
          ),
          Expanded(
            child: FlickToggleSoundAction(
              toggleMute: () {
                toggleMute();
                //displayManager.handleShowPlayerControls();
              },
              child: const FlickSeekVideoAction(
                child: Center(child: FlickVideoBuffer()),
              ),
            ),
          ),
          FlickAutoHideChild(
            autoHide: true,
            showIfVideoNotInitialized: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: FlickSoundToggle(
                    toggleMute: () => toggleMute(),
                    color: Colors.white,
                  ),
                ),
                // FlickFullScreenToggle(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
