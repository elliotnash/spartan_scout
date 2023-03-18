
       // CustomPaint(
       //    painter: QrPainter(
       //        data: "HI",
       //        //data: "Welcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome Welcome to FlutterWelcome to FlutterWelcome Welcome to FlutterWelcome to FlutterWelcome Welcome to FlutterWelcome to FlutterWelcome Welcome to FlutterWelcome to FlutterWelcome Welcome to FlutterWelcome to FlutterWelcome Welcome to FlutterWelcome to hi hi hi hi hi hi",
       //        options: const QrOptions(
       //          shapes: QrShapes(
       //              darkPixel: CirclePixelShape(
       //                connectX: true,
       //                connectY: false,
       //                fillet: true,
       //                size: 0.9
       //              ),
       //              frame: QrFrameShapeRoundCorners(cornerFraction: .25),
       //              ball: QrBallShapeRoundCorners(cornerFraction: .25)),
       //          colors: QrColors(
       //              dark: QrColorLinearGradient(colors: [
       //                Color.fromARGB(255, 60, 60, 160),
       //                Color.fromARGB(255, 5, 40, 100),
       //              ], orientation: GradientOrientation.leftDiagonal),
       //              background: QrColorSolid(Color(0x00000000))),
       //        )),
       //    size: const Size(350, 350),
       //  ),

import 'dart:math';
import 'dart:ui';

import 'package:custom_qr_generator/custom_qr_generator.dart';

class DiamondPixelShape extends QrPixelShape {
  final bool connect;
  final bool fillet;
  const DiamondPixelShape({this.connect = false, bool fillet = false})
      : fillet = connect ? fillet : false;
  @override
  Path createPath(Offset offset, double size, Neighbors neighbors) {
    var path = Path()
      ..addPolygon([
        Offset(0, size / 2),
        Offset(size / 2, 0),
        Offset(size, size / 2),
        Offset(size / 2, size),
      ], true);
    if (neighbors.left) {
      path.addRect(Rect.fromLTRB(0, 0, size / 2, size));
    }
    if (neighbors.top) {
      path.addRect(Rect.fromLTRB(0, 0, size, size / 2));
    }
    if (neighbors.right) {
      path.addRect(Rect.fromLTRB(size / 2, 0, size, size));
    }
    if (neighbors.bottom) {
      path.addRect(Rect.fromLTRB(0, size / 2, size, size));
    }
    return path;
  }
}

class CirclePixelShape extends QrPixelShape {
  final bool connectX;
  final bool connectY;
  final bool connectDiagonal;
  final bool fillet;
  final double size;
  const CirclePixelShape({
    this.connectX = false,
    this.connectY = false,
    bool connectDiagonal = false,
    bool fillet = false,
    this.size = 1
  }) : fillet = connectX && connectY ? fillet : false,
        connectDiagonal = size == 1 && fillet ? connectDiagonal : false;

  @override
  Path createPath(Offset offset, double size, Neighbors neighbors) {
    double pixSize = size*this.size;
    Offset pixOffset = Offset((size-pixSize)/2, (size-pixSize)/2);

    var path = Path()..addOval(Rect.fromLTWH(pixOffset.dx, pixOffset.dy, pixSize, pixSize));

    if (connectX) {
      if (neighbors.left) {
        path.addRect(Rect.fromLTWH(0, pixOffset.dx, size/2, pixSize));
      }
      if (neighbors.right) {
        path.addRect(Rect.fromLTWH(size/2, pixOffset.dx, size/2, pixSize));
      }
    }

    if (connectY) {
      if (neighbors.top) {
        path.addRect(Rect.fromLTWH(pixOffset.dy, 0, pixSize, size / 2));
      }
      if (neighbors.bottom) {
        path.addRect(Rect.fromLTWH(pixOffset.dy, size / 2, pixSize, size));
      }
    }

    if (fillet) {
      if (neighbors.topLeft) {
        if (neighbors.top || connectDiagonal) {
          var triangle = Path()..addPolygon([
            Offset(pixOffset.dx-(pixSize/2), -pixOffset.dy),
            Offset(pixOffset.dx, -pixOffset.dy),
            Offset(pixOffset.dx, (-pixOffset.dy)+(pixSize/2))
          ], true);
          var arc = Path()
            ..addArc(Rect.fromLTWH(pixOffset.dx-(pixSize), -pixOffset.dy, pixSize, pixSize), -pi / 2, pi / 2);
          var fillet = Path.combine(PathOperation.difference, triangle, arc);
          path.addPath(fillet, Offset.zero);
        }
        if (neighbors.left || connectDiagonal) {
          var triangle = Path()..addPolygon([
            Offset(-pixOffset.dx, pixOffset.dy),
            Offset((-pixOffset.dx)+(pixSize/2), pixOffset.dy),
            Offset(-pixOffset.dx, pixOffset.dy-(pixSize/2)),
          ], true);
          var arc = Path()
            ..addArc(Rect.fromLTWH(-pixOffset.dx, pixOffset.dy-pixSize, pixSize, pixSize), pi / 2, pi / 2);
          var fillet = Path.combine(PathOperation.difference, triangle, arc);
          path.addPath(fillet, Offset.zero);
        }
      }

      if (neighbors.topRight) {
        if (neighbors.right || connectDiagonal) {
          var triangle = Path()..addPolygon([
            Offset(size+pixOffset.dx, pixOffset.dy),
            Offset(size+pixOffset.dx, pixOffset.dy-(pixSize/2)),
            Offset((size+pixOffset.dx)-(pixSize/2), pixOffset.dy),
          ], true);
          var arc = Path()
            ..addArc(Rect.fromLTWH((size+pixOffset.dx)-pixSize, pixOffset.dy-pixSize, pixSize, pixSize), 0, pi / 2);
          var fillet = Path.combine(PathOperation.difference, triangle, arc);
          path.addPath(fillet, Offset.zero);
        }
        if (neighbors.top || connectDiagonal) {
          var triangle = Path()..addPolygon([
            Offset(size-pixOffset.dx, -pixOffset.dy),
            Offset(size-pixOffset.dx, pixOffset.dy-(pixSize/2)),
            Offset((size-pixOffset.dx)+(pixSize/2), -pixOffset.dy),
          ], true);
          var arc = Path()
            ..addArc(Rect.fromLTWH(size-pixOffset.dx, pixOffset.dy-pixSize, pixSize, pixSize), pi, pi / 2);
          var fillet = Path.combine(PathOperation.difference, triangle, arc);
          path.addPath(fillet, Offset.zero);
        }
      }
    }

    return path;
  }
}
