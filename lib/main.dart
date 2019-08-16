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
  bool _isClipScaling = false;
  bool _isAnimating = false;
  bool _isDynamic = true;
  final ImageFilter blurFilter = ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0);
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 5),
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

  Widget wrapBackground(Widget background) {
    if (_isBgBlurred) {
      background = Stack(
        fit: StackFit.expand,
        children: <Widget>[
          background,
          BackdropFilter(
            filter: blurFilter,
            isDynamic: _isDynamic,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ],
      );
    }
    return background;
  }

  Widget wrapChild(Widget child, double pad) {
    if (_isChildBlurred) {
      child = BackdropFilter(
        filter: blurFilter,
        isDynamic: _isDynamic,
        child: child,
      );
    }
    if (pad > 0) {
      child = Container(
        padding: EdgeInsets.all(pad),
        child: child,
      );
    }
    if (_isChildClipped) {
      child = _isClipOval ? ClipOval(child: child) : ClipRect(child: child);
    }
    return child;
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
    AnimatedBuilder _floater = AnimatedBuilder(
      builder: (context, child) {
        double pad = 0;
        if (_isChildClipped && _isClipScaling) {
          pad = (10 - _controller.value * 20).abs();
        }
        return Positioned(
          top:  175 - 100 * _controller.value - pad,
          left:  70 + 100 * _controller.value - pad,
          child: wrapChild(child, pad),
        );
      },
      animation: _controller,
      child: Text('text',
        style: TextStyle(color: Colors.purple, fontSize: 80),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          wrapBackground(
            Text('backdrop'*20,
              style: TextStyle(color: Colors.blue, fontSize: 50),
            ),
          ),
          _floater,
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
                        (b) => setState(() => _isBgBlurred = b)),
                _makeCheckboxItem('Text child', _isChildBlurred,
                        (b) => setState(() => _isChildBlurred = b)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('Options:'),
                _makeCheckboxItem('Dynamic', _isDynamic,
                        (b) => setState(() => _isDynamic = b)),
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
                _makeCheckboxItem('Resizing', _isClipScaling,
                        (b) => setState(() => _isClipScaling = b)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
