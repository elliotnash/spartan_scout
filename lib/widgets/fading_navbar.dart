import 'package:flutter/cupertino.dart';
import 'package:spartan_scout/const.dart';

CupertinoNavigationBar CupertinoFadingNavigationBar({
  required BuildContext context,
  required double opacity,
  Widget? leading,
  Widget? middle,
  Widget? trailing,
  Color? backgroundColor,
}) {
  final background = backgroundColor ?? CupertinoDynamicColor.resolve(CupertinoColors.systemBackground, context);
  final tween = ColorTween(
    begin: background,
    end: CupertinoTheme.of(context).barBackgroundColor.withAlpha(kDefaultNavBarBackgroundAlpha),
  );
  final borderAlpha = (kDefaultNavBarBorderColor.alpha * opacity).round();
  return CupertinoNavigationBar(
    backgroundColor: tween.transform(opacity),
    border: Border(
      bottom: BorderSide(
        width: 0.0,
        color: kDefaultNavBarBorderColor.withAlpha(borderAlpha),
      ),
    ),
    leading: leading == null ? null : MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: leading,
    ),
    middle: middle == null ? null : MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: middle,
    ),
    trailing: trailing == null ? null : MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: trailing,
    ),
  );
}