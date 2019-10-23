import 'dart:ui';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BackdropFilter Cache Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'BackdropFilter Cache Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  bool _isBgBlurred = false;
  bool _isChildBlurred = false;
  bool _isChildClipped = false;
  bool _isClipOval = false;
  bool _isBlurScaling = false;
  bool _isAnimating = false;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    );
  }

  void setAnimation(bool isAnimating) {
    setState(() => _isAnimating = isAnimating);
    if (isAnimating) {
      _controller.repeat().orCancel;
    } else {
      _controller.stop(canceled: false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static double cycle101(double val) => (val * 2.0 - 1.0).abs();
  static double cycle010(double val) => 1.0 - cycle101(val);
  static double cycle10101(double val) => cycle101(cycle010(val));

  ImageFilter makeBlur() {
    double sigma = _isBlurScaling
        ? 5.0 + 4.0 * cycle10101(_controller.value)
        : 5.0;
    return ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
  }

  Widget wrapBackground(Widget background) {
    if (_isBgBlurred) {
      background = Stack(
        fit: StackFit.expand,
        children: <Widget>[
          RepaintBoundary(child: background),
          BackdropFilter(
            filter: makeBlur(),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ],
      );
    }
    return background;
  }

  Widget wrapChild(Widget child) {
    if (_isChildBlurred) {
      child = BackdropFilter(
        filter: makeBlur(),
        child: child,
      );
    }
    if (_isChildClipped) {
      child = _isClipOval ? ClipOval(child: child) : ClipRect(child: child);
    }
    return child;
  }

  Widget makeFloater() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double v = cycle010(_controller.value);
        return Positioned(
          top:  185 - 100 * v,
          left:  60 + 100 * v,
          child: wrapChild(child),
        );
      },
      child: Text('text',
        style: TextStyle(
          color: Colors.purple,
          fontSize: 80,
        ),
      ),
    );
  }

  Widget makeAlternators() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        bool isUp = _controller.value < 0.5;
        return Center(
          child: Text(isUp ? 'up' : 'down',
            style: TextStyle(
              color: isUp ? Colors.green : Colors.red,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _makeCheckboxItem(String label, bool curValue, void function(bool)) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label),
        Checkbox(
          value: curValue,
          onChanged: function,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          wrapBackground(
            Stack(
              children: <Widget>[
                Text('backdrop'*20,
                  style: TextStyle(color: Colors.blue, fontSize: 50),
                ),
                makeAlternators(),
              ],
            ),
          ),
          makeFloater(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('Blur on:'),
                _makeCheckboxItem('Background', _isBgBlurred,
                        (b) => setState(() { _isBgBlurred = b; })),
                _makeCheckboxItem('Text child', _isChildBlurred,
                        (b) => setState(() { _isChildBlurred = b; })),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('Options:'),
                _makeCheckboxItem('Clipped', _isChildClipped,
                        (b) => setState(() => _isChildClipped = b)),
                _makeCheckboxItem('Animated', _isAnimating,
                        (b) => setAnimation(b)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('Clip:'),
                _makeCheckboxItem('Oval', _isClipOval,
                        (b) => setState(() => _isClipOval = b)),
                _makeCheckboxItem('Resizing', _isBlurScaling,
                        (b) => setState(() => _isBlurScaling = b)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
