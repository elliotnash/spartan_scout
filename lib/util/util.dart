import 'package:flutter/cupertino.dart';

extension Capitalize on String {
  String capitalizeWords() {
    var result = this[0].toUpperCase();
    for (int i = 1; i < length; i++) {
      if (this[i - 1] == " ") {
        result = result + this[i].toUpperCase();
      } else {
        result = result + this[i];
      }
    }
    return result;
  }
}

DateTime dateTimeFromEpoch(int int) => DateTime.fromMillisecondsSinceEpoch(int);
int dateTimeToEpoch(DateTime time) => time.millisecondsSinceEpoch;

class OutlineBoxShadow extends BoxShadow {
  const OutlineBoxShadow({
    Color color = const Color(0xFF000000),
    Offset offset = Offset.zero,
    double blurRadius = 0.0,
  }) : super(color: color, offset: offset, blurRadius: blurRadius);

  @override
  Paint toPaint() {
    final Paint result = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, blurSigma);
    assert(() {
      if (debugDisableShadows) {
        result.maskFilter = null;
      }
      return true;
    }());
    return result;
  }
}
