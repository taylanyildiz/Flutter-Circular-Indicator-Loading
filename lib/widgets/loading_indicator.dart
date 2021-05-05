import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_circular_indicator_loading/widgets/loading_check_text.dart';

/// InheritedWidget Parent of [_LoadingIndicatorState]
///
/// Every one checkBox will be ready returns different Color
// ignore: unused_element
class _LoadingScope extends InheritedWidget {
  _LoadingScope({
    Key? key,
    required Widget child,
    required this.state,
    required this.color,
  }) : super(key: key, child: child);

  final _LoadingIndicatorState state;

  final Color color;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
      (oldWidget as _LoadingScope).color != color;
}

class LoadingIndicator extends StatefulWidget {
  /// Constructor [LoadingIndicator]
  ///

  LoadingIndicator({
    Key? key,
    required List<String> readyText,
    IconData? iconData,
    Color? checkColor,
    Color? readyColor,
    Color? textColor,
    Function? setCheck,
  }) : this.builder(
          key: key,
          readyText: readyText,
          iconData: iconData,
          checkColor: checkColor,
          readyColor: readyColor,
          textColor: textColor,
          setCheck: setCheck,
        );

  const LoadingIndicator.builder({
    Key? key,
    required this.readyText,
    this.iconData,
    this.checkColor,
    this.readyColor,
    this.textColor,
    this.setCheck,
  })  : assert(readyText.length > 0),
        super(key: key);

  /// CheckBox text.
  final List<String> readyText;

  /// CheckBox Text style Color.
  final Color? textColor;

  /// CheckBox not ready Color.
  final Color? checkColor;

  /// CheckBox ready Color.
  final Color? readyColor;

  /// CheckBox IconsData
  final IconData? iconData;

  /// Finished checkAction
  ///
  /// whatever you want to do afterwards write here
  final Function? setCheck;

  ///
  static _LoadingIndicatorState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_LoadingScope>()!.state;

  @override
  _LoadingIndicatorState createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with TickerProviderStateMixin {
  /// Controller checkBox animation.
  AnimationController? _controllerCheckBox;

  /// Controller indicator animaion.
  AnimationController? _controllerIndicator;

  /// How many checkBox widget are there. We have same count animation
  ///
  /// different Interval value.
  final _checkAnimation = <Animation<double>>[];

  /// Animation Indiactor value
  Animation<double>? _indicatorAnimation;

  @override
  void initState() {
    super.initState();

    _controllerCheckBox = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: widget.readyText.length,
      ),
    );

    _controllerIndicator = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _controllerCheckBox!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setIndicatorVisibilty();
      }
    });

    _controllerIndicator!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.setCheck!.call();
      }
    });

    _indicatorAnimation = CurvedAnimation(
      parent: _controllerIndicator!,
      curve: Interval(0.0, 1.0),
    );

    for (var i = 0; i < widget.readyText.length; i++) {
      _checkAnimation.add(CurvedAnimation(
          parent: _controllerCheckBox!,
          curve: Interval((1 / widget.readyText.length) * (i + 0.7),
              (1 / widget.readyText.length) * (i + 1))));
    }
  }

  bool visibleIndicator = true;
  void setIndicatorVisibilty() async {
    await Future.delayed(
        Duration(seconds: 2), () => _controllerIndicator!.forward());
    visibleIndicator = false;
  }

  @override
  void dispose() {
    super.dispose();
    _controllerCheckBox!.dispose();
    _controllerIndicator!.dispose();
  }

  /// Indicator Color.
  Color color = Colors.blue;

  // void setColor(Color colors) {
  //   setState(() {
  //     color = colors;
  //   });
  // }

  /// Action Started.
  setCheck() {
    _controllerCheckBox!.forward();
  }

  Widget _checkBoxWidget() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _indicatorAnimation!,
          builder: (context, child) {
            setCheck();
            return Stack(
              children: [
                Visibility(
                  visible: visibleIndicator,
                  child: CircularProgressIndicator(
                    valueColor:
                        _indicatorAnimation!.drive(ColorTween(begin: color)),
                  ),
                ),
                Transform.scale(
                  scale: _indicatorAnimation!
                      .drive(
                          Tween<double>(begin: 0.0, end: 2.5).chain(CurveTween(
                        curve: Curves.elasticOut,
                      )))
                      .value,
                  child: Container(
                    padding: EdgeInsets.all(3.0),
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                    child: Icon(
                      widget.iconData ?? Icons.check,
                      color: Colors.white,
                      size: 40.0,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: 50.0),
        Container(
          width: 400.0,
          height: 200.0,
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.readyText.length,
            itemBuilder: (context, index) => LoadingCheckBox(
              animation: _checkAnimation[index],
              text: widget.readyText[index],
              color: widget.textColor,
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _LoadingScope(
      child: _checkBoxWidget(),
      state: this,
      color: color,
    );
  }
}
