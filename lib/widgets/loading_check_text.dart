import 'package:flutter/material.dart';

abstract class LoadingCheckAction extends AnimatedWidget {
  /// Constructor AnimatedWidget have animation for
  /// listenable.
  ///
  /// But have a problem is every [LoadingCheckBox] widget have different animation because
  /// one by one widget change to check.But if every widget have same animation so All widget [LoadingCheckAction]
  /// same time will be check.
  LoadingCheckAction({
    Key? key,
    required this.animation,
    this.id,
  }) : super(key: key, listenable: animation);

  /// Animation is usefull for checkbox change null to have a check icon with color.
  ///
  /// Every Widget have different time animaton duration.
  final Animation<double> animation;

  /// Every widget must be different. So we need id of everywidget.
  final int? id;

  /// Widget animation change to checkControl widget.
  Widget _animatedWidget() {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation
              .drive(Tween(begin: 0.0, end: 1.0)
                  .chain(CurveTween(curve: Curves.elasticOut)))
              .value,
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 20.0,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.0, vertical: 4.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              border: Border.all(
                width: 0.5,
                color: animation
                    .drive(ColorTween(begin: Colors.black, end: Colors.blue)
                        .chain(CurveTween(curve: Curves.elasticOut)))
                    .value!,
              ),
              color: animation
                  .drive(ColorTween(begin: Colors.white, end: Colors.blue)
                      .chain(CurveTween(curve: Curves.elasticOut)))
                  .value,
              shape: BoxShape.circle,
            ),
            child: _animatedWidget(),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Container(
              child: buildAction(context),
            ),
          ),
        ],
      ),
    );
  }

  @protected
  Widget buildAction(BuildContext context);
}

/// Action CheckBox will be use in LoadingIndicator chil.
///
/// Can not be null.
class LoadingCheckBox extends LoadingCheckAction {
  LoadingCheckBox({
    Key? key,
    required this.animation,
    required this.text,
    this.color,
    this.id,
  }) : super(key: key, animation: animation, id: id);

  final Animation<double> animation;

  /// This text is our checkBox text.
  ///
  /// What is ready point.
  final String text;

  /// This [id] will be make difference between widgets.
  ///
  /// maybe can work same key.
  final int? id;

  /// TextStyle Color
  final Color? color;

  @override
  Widget buildAction(BuildContext context) => Text(
        text,
        style: TextStyle(
          color: color ?? Colors.black,
          fontSize: 20.0,
        ),
        overflow: TextOverflow.clip,
      );
}
