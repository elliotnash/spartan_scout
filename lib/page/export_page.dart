import 'dart:convert';
import 'dart:ui';

import 'package:custom_qr_generator/custom_qr_generator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spartan_scout/const.dart';
import 'package:spartan_scout/model/template.dart';
import 'package:spartan_scout/provider/database_provider.dart';
import 'package:spartan_scout/provider/scouting_data_provider.dart';
import 'package:spartan_scout/provider/settings_provider.dart';
import 'package:spartan_scout/widgets/cupertino_section.dart';
import 'package:spartan_scout/widgets/fading_navbar.dart';
import 'package:spartan_scout/widgets/qr.dart';

class ExportPage extends StatefulHookConsumerWidget {
  static CupertinoPageRoute route({required ScoutingData data}) {
    return CupertinoPageRoute(builder: (BuildContext context) {
      return ExportPage(data: data);
    });
  }

  final ScoutingData data;

  const ExportPage({
    required this.data,
    super.key,
  });

  @override
  ConsumerState<ExportPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<ExportPage> {
  final ScrollController _scroll = ScrollController();
  // Scroll bar breaks if 0... :)
  double _navOpacity = 0.01;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final opacity =
          clampDouble(_scroll.offset / kNavBarShowLargeTitleThreshold, 0.01, 1);
      if (opacity != _navOpacity) {
        setState(() => _navOpacity = opacity);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoFadingNavigationBar(
          context: context,
          opacity: _navOpacity,
          backgroundColor: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGroupedBackground, context),
          leading: CupertinoNavigationBarBackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          middle: const Text('Export Match'),
        ),
        backgroundColor: CupertinoDynamicColor.resolve(
            CupertinoColors.systemGroupedBackground, context),
        // TODO my problem later
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: const Alignment(0, 0.15),
                  child: CustomPaint(
                    painter: QrPainter(
                        data: jsonEncode(widget.data.toJsonSimple()),
                        //data: "Welcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome to FlutterWelcomeWelcome to FlutterWelcome Welcome to FlutterWelcome to FlutterWelcome Welcome to FlutterWelcome to FlutterWelcome Welcome to FlutterWelcome to FlutterWelcome Welcome to FlutterWelcome to FlutterWelcome Welcome to FlutterWelcome to FlutterWelcome Welcome to FlutterWelcome to hi hi hi hi hi hi",
                        options: QrOptions(
                          shapes: const QrShapes(
                              darkPixel: CirclePixelShape(
                                  connectX: true,
                                  connectY: false,
                                  fillet: true,
                                  size: 0.9
                              ),
                              frame: QrFrameShapeRoundCorners(cornerFraction: .25),
                              ball: QrBallShapeRoundCorners(cornerFraction: .25)),
                          colors: QrColors(
                            dark: QrColorSolid(CupertinoDynamicColor.resolve(CupertinoColors.label, context)),
                            background: const QrColorSolid(Color(0x00000000)),
                          ),
                        )),
                    size: const Size(350, 350),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 50),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        color: CupertinoDynamicColor.resolve(CupertinoColors.systemGrey, context),
                        child: const Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(left: 10)),
                    Expanded(
                      child: CupertinoButton.filled(
                        child: const Text("Done"),
                        onPressed: () {
                          ref.read(scoutingDataListProvider(widget.data.type).notifier).put(widget.data.copyWith(exported: true));
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}
