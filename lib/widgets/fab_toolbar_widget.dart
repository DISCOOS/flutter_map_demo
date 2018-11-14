import 'package:flutter/material.dart';

class FabToolbar extends StatefulWidget {
  final Function() onPressed;
  final String tooltip;
  final IconData icon;
  final List<Widget> buttons;
  final List<Widget> toggled;

  FabToolbar({
    this.onPressed,
    this.tooltip,
    this.icon,
    this.buttons = const <Widget>[],
    this.toggled = const <Widget>[],
  });

  @override
  _FabToolbarState createState() => _FabToolbarState();

}

class _FabToolbarState extends State<FabToolbar>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;
  double _fabPadding = 12.0;
  double _fabScaleMini = 2.0;
  double _fabOffset;
  double _fabSpacing;

  @override
  initState() {

    _fabSpacing = _fabHeight + (_fabPadding * 2.0) / _fabScaleMini;
    _fabOffset =  _fabSpacing;
    for(final widget in widget.buttons) {
      _fabOffset += _fabSpacing / getFabScale(widget);
    }
    _animationController =
      AnimationController(vsync: this, duration: Duration(milliseconds: 180))
        ..addListener(() {
          setState(() {});
        });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        1.0,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: () => {
          animate(): widget.onPressed
        },
        tooltip: 'Toggle',
        mini: true,
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  Widget modal(BuildContext context) {
    return ScaleTransition(
        scale: CurvedAnimation(
          parent: this._animationController,
          curve: Interval(1.0, 1.0, curve: Curves.linear),
        ),
        alignment: FractionalOffset.center,
        child: GestureDetector(
            onTap: animate,
            child: Container(
              color: Colors.white54,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            )));
  }

  Widget createToggleItem(int index, Widget button) {
    return Transform(
      transform: Matrix4.translationValues(
        0.0,
        _translateButton.value * index.toDouble() - _fabOffset,
        0.0,
      ),
      child: ScaleTransition(
          scale: CurvedAnimation(
            parent: this._animationController,
            curve:
            Interval(0.2, 1.0, curve: Curves.linear),
          ),
          alignment: FractionalOffset.center,
          child: button
      ),
    );
  }

  Column createToggleColumn() {
    int i = 0;
    List<Widget> children = List.from(widget.toggled.map(
            (button) => createToggleItem(++i, button)
    ));
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: children,
    );
  }

  Column createButtonColumn() {
    List<Widget> children = <Widget>[];
    widget.buttons.forEach((widget)
      => children.addAll([widget, createPadding(widget),]));

    children.add(toggle());

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: children
    );
  }

  double getFabScale(Widget widget) {
    return (widget is FloatingActionButton
        ? (widget.mini ? _fabScaleMini : 1.0) : 1.0);
  }

  SizedBox createPadding(Widget widget) {
    return SizedBox(height: _fabPadding / getFabScale(widget));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.topCenter,
        overflow: Overflow.visible,
        children: [
          createToggleColumn(),
          createButtonColumn(),
        ],
      );
  }

}