import 'package:flutter/cupertino.dart';

const double _kActivityIndicatorRadius = 14.0;
const double _kActivityIndicatorMargin = 20.0;

Widget buildSafeAreaRefreshIndicator(
    BuildContext context,
    RefreshIndicatorMode refreshState,
    double pulledExtent,
    double refreshTriggerPullDistance,
    double refreshIndicatorExtent,
    ) {
  final double percentageComplete = (pulledExtent / refreshTriggerPullDistance).clamp(0.0, 1.0);
  // use the padding from SafeArea
  final topPadding = MediaQuery.of(context).padding.top;
  // Place the indicator at the top of the sliver that opens up. Note that we're using
  // a Stack/Positioned widget because the CupertinoActivityIndicator does some internal
  // translations based on the current size (which grows as the user drags) that makes
  // Padding calculations difficult. Rather than be reliant on the internal implementation
  // of the activity indicator, the Positioned widget allows us to be explicit where the
  // widget gets placed. Also note that the indicator should appear over the top of the
  // dragged widget, hence the use of Overflow.visible.
  return Center(
    child: Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          top: _kActivityIndicatorMargin+topPadding,
          left: 0.0,
          right: 0.0,
          child: _buildIndicatorForRefreshState(refreshState, _kActivityIndicatorRadius, percentageComplete),
        ),
      ],
    ),
  );
}

Widget _buildIndicatorForRefreshState(RefreshIndicatorMode refreshState, double radius, double percentageComplete) {
  switch (refreshState) {
    case RefreshIndicatorMode.drag:
    // While we're dragging, we draw individual ticks of the spinner while simultaneously
    // easing the opacity in. Note that the opacity curve values here were derived using
    // Xcode through inspecting a native app running on iOS 13.5.
      const Curve opacityCurve = Interval(0.0, 0.35, curve: Curves.easeInOut);
      return Opacity(
        opacity: opacityCurve.transform(percentageComplete),
        child: CupertinoActivityIndicator.partiallyRevealed(radius: radius, progress: percentageComplete),
      );
    case RefreshIndicatorMode.armed:
    case RefreshIndicatorMode.refresh:
    // Once we're armed or performing the refresh, we just show the normal spinner.
      return CupertinoActivityIndicator(radius: radius);
    case RefreshIndicatorMode.done:
    // When the user lets go, the standard transition is to shrink the spinner.
      return CupertinoActivityIndicator(radius: radius * percentageComplete);
    case RefreshIndicatorMode.inactive:
    // Anything else doesn't show anything.
      return Container();
  }
}