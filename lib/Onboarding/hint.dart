import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';


void displayHint(String message, String videoPath, BuildContext context, bool video) {
  var alert = new Dialog(
    child: Container(
      decoration: BoxDecoration(color: Colors.black),
      child: new Container(
        margin: const EdgeInsets.all(5.0),
        //width: 300.0,
        //height: 175.0,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFFD1603D),
                Color(0xFF463E68),],
                begin: FractionalOffset.topLeft,
                end: FractionalOffset.bottomRight,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
            color: Color(0xFFD1603D),
            borderRadius: new BorderRadius.circular(15.0)),
        child: new Padding(
          padding: EdgeInsets.all(8.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: buildChildren(message: message, resourcePath: videoPath, context: context, video: video),
          ),
        ),
      ),
    ),
  );
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      });
}

/// Returns the list of element in the Dialog
/// - A text
/// - Either a video or an image, depending on bool video
/// - A floating action button
List<Widget> buildChildren({String message, String resourcePath, BuildContext context, bool video}){
  List<Widget> children = List<Widget>();

  children.add(new Text(
    message,
    textAlign: TextAlign.center,
    style: TextStyle(fontFamily: 'AA', fontSize: 15.0, color: Colors.indigo[100]),
  ));

  if (video)
    children.add(VideoPlayerCustom(assetPath: resourcePath+".mp4",));
  else
    children.add(Image.asset(resourcePath+".png"));

  children.add(FloatingActionButton(
      onPressed: () {
        //Remove alert box
        Navigator.of(context).pop();
      },
      backgroundColor: Color(0xFFF06343),
      child: Text("OK!", style: TextStyle(fontFamily: 'AA'))),);

  return children;

}

class VideoPlayerCustom extends StatefulWidget {
  final String assetPath;

  VideoPlayerCustom({this.assetPath});

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayerCustom> {
  VideoPlayerController _controller;
  bool _isPlaying = false;
  VoidCallback listener;

  @override
  void initState() {
    super.initState();
    listener = () {
      final bool isPlaying = _controller.value.isPlaying;
      if (isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = isPlaying;
        });
      }
    };
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..addListener(listener)
      ..initialize().then((_) {
        _controller.setVolume(0.0);
        _controller.setLooping(true);
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          _controller.play();
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //width: 300.0,
      //height: 300.0,
      child: Center(
        child: _controller.value.initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Container(),
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    _controller.setVolume(0.0);
    _controller.removeListener(listener);
    _controller.dispose();
  }
}
