import 'dart:ui';

import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/cupertino.dart';

void showSnackbar(Widget child) {
  showToast(
    animationDuration: const Duration(milliseconds: 250),
    /// Animate the toast to show up from the bottom
    animationBuilder: (context, animation, child) {
      return AnimatedBuilder(
        animation: animation,
        builder: (context, __) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: animation.value*8,
                  sigmaY: animation.value*8,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  color: CupertinoDynamicColor.resolve(CupertinoColors.tertiarySystemFill, ToastProvider.context).withAlpha((animation.value*150).toInt()),
                  child: Opacity(
                    opacity: animation.value,
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
    child: child,
    alignment: const Alignment(0, 0.74),
    // margin: EdgeInsets.only(bottom: 100),
    context: ToastProvider.context,
    // contentPadding: EdgeInsets.zero,
  );
}
