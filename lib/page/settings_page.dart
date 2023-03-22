import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spartan_scout/const.dart';
import 'package:spartan_scout/model/template.dart';
import 'package:spartan_scout/provider/database_provider.dart';
import 'package:spartan_scout/provider/scouting_data_provider.dart';
import 'package:spartan_scout/provider/settings_provider.dart';
import 'package:spartan_scout/widgets/cupertino_section.dart';
import 'package:spartan_scout/widgets/fading_navbar.dart';
import 'package:spartan_scout/widgets/snackbar.dart';

class SettingsPage extends StatefulHookConsumerWidget {
  static CupertinoPageRoute route() {
    return CupertinoPageRoute(builder: (BuildContext context) {
      return const SettingsPage();
    });
  }

  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
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
    final settings = ref.watch(settingsProvider);

    if (settings.hasValue) {
      final bool offlineMode = settings.value!["offline_mode"] ?? false;

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
            middle: const Text('Settings'),
          ),
          backgroundColor: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGroupedBackground, context),
          // TODO my problem later
          child: CupertinoScrollbar(
            controller: _scroll,
            child: ListView(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                CupertinoSection(
                  heading: "General",
                  children: [
                    SettingsSwitchEntry(
                      text: "Offline Mode",
                      value: offlineMode,
                      onChanged: (value) {
                        ref
                            .read(settingsProvider.notifier)
                            .put("offline_mode", value);
                      },
                    ),
                  ],
                ),
                CupertinoSection(
                  heading: "Export",
                  children: [
                    SettingsButtonEntry(
                        text: "Export pit scouting CSV",
                        onPressed: () async {
                          await _saveCsv(
                            (await ref.read(scoutingDataListProvider(ScoutingType.pit).future)).toCsv(),
                            "pit.csv"
                          );
                        }
                    ),
                    SettingsButtonEntry(
                      text: "Export match scouting CSV",
                      onPressed: () async {
                        await _saveCsv(
                          (await ref.read(scoutingDataListProvider(ScoutingType.match).future)).toCsv(),
                          "matches.csv"
                        );
                      }
                    ),
                  ]
                ),
                CupertinoSection(
                  heading: "Advanced",
                  children: [
                    SettingsButtonEntry(
                      text: "Reset Database",
                      color: CupertinoDynamicColor.resolve(CupertinoColors.destructiveRed, context),
                      onPressed: () async {
                        final delete = await showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: const Text("Reset Database?"),
                            content: const Text("All scouting data will be lost!"),
                            actions: [
                              CupertinoDialogAction(
                                isDefaultAction: true,
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text("Cancel"),
                              ),
                              CupertinoDialogAction(
                                isDestructiveAction: true,
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );
                        if (delete) {
                          await ref.read(scoutingDatabaseProvider.notifier).delete();
                          ref.refresh(scoutingDataListProvider(ScoutingType.pit));
                          ref.refresh(scoutingDataListProvider(ScoutingType.match));
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ));
    }
    return const Center(
      child: CupertinoActivityIndicator(),
    );
  }

  Future<void> _saveCsv(String csv, String fileName) async {
    if (!kIsWeb && Platform.isIOS) {
      Directory dir = await getApplicationDocumentsDirectory();
      if (!(await dir.exists())) {
        await dir.create(recursive: true);
      }
      final file = File("${dir.path}/$fileName");
      file.writeAsBytes(ascii.encode(csv));
      showSnackbar(const Text("File saved to Documents directory!"));
    } else {
      final path = await getSavePath(suggestedName: fileName);
      if (path == null) {
        return;
      }
      final file = XFile.fromData(
          ascii.encode(csv),
          mimeType: 'text/csv',
          name: fileName
      );
      await file.saveTo(path);
    }
  }
}

class SettingsButtonEntry extends HookConsumerWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  const SettingsButtonEntry({
    required this.text,
    required this.onPressed,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: kSettingsEntryHeight,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Text(
          text,
          style: color == null
              ? null
              : DefaultTextStyle.of(context).style.copyWith(color: color),
        ),
      ),
    );
  }
}

class SettingsSwitchEntry extends HookConsumerWidget {
  final String text;
  final bool value;
  final Function(bool) onChanged;
  const SettingsSwitchEntry({
    required this.text,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 20, right: kSettingsEntryPadding, top: 2, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(text),
          ),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
