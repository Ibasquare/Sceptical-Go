import 'package:flutter/material.dart';
import 'page1.dart';
import 'page2.dart';
import 'page3.dart';
import 'dots_indicator.dart';

const bool HINT_VIDEO = false;
// If set to false, the hint is an image,
// If set to true, the hint is a video.

class OnBoardingScreens extends StatefulWidget {
  @override
  _OnBoardingScreensState createState() => _OnBoardingScreensState();
}

class _OnBoardingScreensState extends State<OnBoardingScreens> {
  final _controller = new PageController();
  final List<Widget> _pages = [
    Page1(videoHint: HINT_VIDEO,),
    Page2(videoHint: HINT_VIDEO,),
    Page3(videoHint: HINT_VIDEO,),
  ];
  int page = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDone = (page == _pages.length - 1);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: PageView.builder(
              physics: new AlwaysScrollableScrollPhysics(),
              controller: _controller,
              itemCount: _pages.length,
              itemBuilder: (BuildContext context, int index) {
                return _pages[index % _pages.length];
              },
              onPageChanged: (int p) {
                setState(() {
                  page = p;
                });
              },
            ),
          ),
          // Title at the top (not moving with the pageview -> SafeArea)
          new Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: new SafeArea(
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                primary: false,
                title: Text(
                  'Sceptical Go',
                  style: TextStyle(
                      fontSize: 24.0, color: Colors.white, fontFamily: 'AA'),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      isDone ? 'DONE' : 'NEXT',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: isDone
                        ? () {
                            Navigator.pop(context);
                          }
                        : () {
                            _controller.animateToPage(page + 1,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeIn);
                          },
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 0.0,
            left: 0.0,
            child: SafeArea(
              child: new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new DotsIndicator(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageSelected: (int page) {
                    _controller.animateToPage(
                      page,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
