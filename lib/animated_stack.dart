library animated_stack;

import 'package:flutter/material.dart';

class AnimatedStack extends StatefulWidget {
  final double scaleWidth;
  final double scaleHeight;
  final Widget foregroundWidget;
  final Widget columnWidget;
  final Widget bottomWidget;
  final Color fabBackgroundColor;
  final Color fabIconColor;
  final Color backgroundColor;
  final Duration buttonAnimationDuration;
  final Duration slideAnimationDuration;
  final Curve openAnimationCurve;
  final Curve closeAnimationCurve;
  final IconData buttonIcon;
  final bool animateButton;

  const AnimatedStack({
    Key key,
    this.scaleWidth = 60,
    this.scaleHeight = 60,
    this.fabBackgroundColor,
    this.backgroundColor,
    @required this.columnWidget,
    @required this.bottomWidget,
    @required this.foregroundWidget,
    this.slideAnimationDuration = const Duration(milliseconds: 800),
    this.buttonAnimationDuration = const Duration(milliseconds: 240),
    this.openAnimationCurve = const ElasticOutCurve(0.9),
    this.closeAnimationCurve = const ElasticInCurve(0.9),
    this.buttonIcon = Icons.add,
    this.animateButton = true,
    this.fabIconColor,
  })  : assert(scaleHeight >= 40),
        super(key: key);

  @override
  _AnimatedStackState createState() => _AnimatedStackState();
}

class _AnimatedStackState extends State<AnimatedStack> {
  bool opened = false;

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;
    final double _height = MediaQuery.of(context).size.height;
    final double _fabPosition = 16;
    final double _fabSize = 56;

    final double _xScale =
        (widget.scaleWidth + _fabPosition * 2) * 100 / _width;
    final double _yScale =
        (widget.scaleHeight + _fabPosition * 2) * 100 / _height;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: RotateAnimation(
          opened: widget.animateButton ? opened : false,
          child: Icon(widget.buttonIcon,color: widget.fabIconColor,),
          duration: widget.buttonAnimationDuration,
        ),
        backgroundColor: widget.fabBackgroundColor,
        onPressed: () => setState(() => opened = !opened),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            color: widget.backgroundColor,
            child: Stack(
              children: <Widget>[
                Positioned(
                  bottom: _fabSize + _fabPosition * 2,
                  right: _fabPosition,
                  // width is used as max width to prevent overlap
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: widget.scaleWidth),
                    child: widget.columnWidget,
                  ),
                ),
                Positioned(
                  right: widget.scaleWidth + _fabPosition * 2,
                  bottom: _fabPosition * 1.5,
                  // height is used as max height to prevent overlap
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: widget.scaleHeight - _fabPosition,
                    ),
                    child: widget.bottomWidget,
                  ),
                ),
              ],
            ),
          ),
          SlideAnimation(
            opened: opened,
            xScale: _xScale,
            yScale: _yScale,
            duration: widget.slideAnimationDuration,
            child: widget.foregroundWidget,
          ),
        ],
      ),
    );
  }
}

class SlideAnimation extends StatefulWidget {
  final Widget child;
  final bool opened;
  final double xScale;
  final double yScale;
  final Duration duration;
  final Curve openAnimationCurve;
  final Curve closeAnimationCurve;

  const SlideAnimation({
    Key key,
    this.child,
    this.opened = false,
    this.xScale,
    this.yScale,
    this.duration,
    this.openAnimationCurve = const ElasticOutCurve(0.9),
    this.closeAnimationCurve = const ElasticInCurve(0.9),
  }) : super(key: key);

  @override
  _SlideState createState() => _SlideState();
}

class _SlideState extends State<SlideAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Offset> offset;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    offset = Tween<Offset>(
      begin: Offset(0.0, 0.0),
      end: Offset(-widget.xScale * 0.01, -widget.yScale * 0.01),
    ).animate(
      CurvedAnimation(
        curve: Interval(
          0,
          1,
          curve: widget.openAnimationCurve,
        ),
        reverseCurve: Interval(
          0,
          1,
          curve: widget.closeAnimationCurve,
        ),
        parent: _animationController,
      ),
    );

    super.initState();
  }

  @override
  void didUpdateWidget(SlideAnimation oldWidget) {
    widget.opened
        ? _animationController.forward()
        : _animationController.reverse();

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: offset,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class RotateAnimation extends StatefulWidget {
  final Widget child;
  final bool opened;
  final Duration duration;

  const RotateAnimation({
    Key key,
    this.child,
    this.opened = false,
    this.duration,
  }) : super(key: key);

  @override
  _RotateState createState() => _RotateState();
}

class _RotateState extends State<RotateAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> rotate;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    rotate = Tween(
      begin: 0.0,
      end: 0.12,
    ).animate(
      CurvedAnimation(
        curve: Interval(
          0,
          1,
          curve: Curves.easeIn,
        ),
        reverseCurve: Interval(
          0,
          1,
          curve: Curves.easeIn.flipped,
        ),
        parent: _animationController,
      ),
    );

    super.initState();
  }

  @override
  void didUpdateWidget(RotateAnimation oldWidget) {
    widget.opened
        ? _animationController.forward()
        : _animationController.reverse();

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: rotate,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}