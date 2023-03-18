import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spartan_scout/const.dart';
import 'package:spartan_scout/model/template.dart';
import 'package:spartan_scout/page/export_page.dart';
import 'package:spartan_scout/page/scouting_entry_page.dart';
import 'package:spartan_scout/provider/scouting_data_provider.dart';
import 'package:spartan_scout/provider/template_provider.dart';
import 'package:spartan_scout/widgets/cupertino_section.dart';
import 'package:spartan_scout/widgets/safearea_refresh_indicator.dart';
import 'package:spartan_scout/widgets/snackbar.dart';

class ScoutingPage extends StatefulHookConsumerWidget {
  final ScoutingType type;
  const ScoutingPage({
    required this.type,
    super.key
  });

  @override
  ConsumerState<ScoutingPage> createState() => _ScoutingPageState();
}

class _ScoutingPageState extends ConsumerState<ScoutingPage> {
  @override
  Widget build(BuildContext context) {
    final template = ref.watch(templatesProvider);
    final data = ref.watch(scoutingDataListProvider(widget.type));

    if (template.hasValue && data.hasValue) {
      final dataList = data.requireValue;
      dataList.sort((a, b) => b.updated.compareTo(a.updated));

      return CupertinoScrollbar(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () async {
                for (final type in ScoutingType.values) {
                  ref.refresh(scoutingDataListProvider(type));
                }
              },
              builder: buildSafeAreaRefreshIndicator,
            ),
            SliverPadding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top)
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                CupertinoSection(
                  children: [
                    for (final record in dataList)
                      ScoutingDataWidget(
                        entry: record,
                        title: record.displayName(template.value!.values.where((e) => e.uuid == record.templateUuid && e.version == record.templateVersion).firstOrNull?.tab(widget.type)!.title ?? ""),
                      ),
                  ],
                ),
              ]),
            ),
            SliverPadding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom)
            ),
          ],
        ),
      );
    } else {
      if (template.hasError) {
        print(template.error);
      }
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }
  }
}

class ScoutingDataWidget extends HookConsumerWidget {
  final ScoutingData entry;
  final String title;
  const ScoutingDataWidget({
    required this.entry,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //TODO make work
    // final teamNumber = entry.data.where((e) => e.name == "team_number" && e is TextEntry).toList();
    // final natNumber = entry.data.where((e) => e.name == "team_number" && e is TextEntry).toList();
    // return Text(teamNumber.isNotEmpty ? (teamNumber[0] as TextEntry).value ?? "BAD" : "NOO");
    return SwipeActionCell(
      key: ObjectKey(entry),
      backgroundColor: Colors.transparent,
      leadingActions: [
        SwipeAction(
          title: "export",
          widthSpace: 86,
          performsFirstActionWithFullSwipe: true,
          onTap: (CompletionHandler handler) async {
            Navigator.of(context).push(ExportPage.route(data: entry));
            await handler(false);
          },
          color: CupertinoDynamicColor.resolve(CupertinoColors.systemBlue, context),
        ),
      ],
      trailingActions: [
        SwipeAction(
          title: "delete",
          widthSpace: 84,
          performsFirstActionWithFullSwipe: true,
          onTap: (CompletionHandler handler) async {
            final controller = TextEditingController();
            final delete = await showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text("Delete Entry?"),
                content: Column(
                  children: [
                    const Text("Enter admin password:"),
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                    ),
                    CupertinoTextField(
                      controller: controller,
                      obscureText: true,
                      autocorrect: false,
                    )
                  ],
                ),
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
            final password = controller.text;
            controller.dispose();

            if (delete) {
              if (password == "robotics") {
                await handler(true);
                if (!await ref.read(scoutingDataListProvider(entry.type).notifier).delete(entry.uuid)) {
                  ref.refresh(scoutingDataListProvider(entry.type));
                }
              } else {
                showSnackbar(const Text("Invalid admin password!"));
                await handler(false);
              }
            } else {
              await handler(false);
            }
          },
          color: CupertinoDynamicColor.resolve(CupertinoColors.destructiveRed, context),
        ),
      ],
      child: SizedBox(
        width: double.infinity,
        height: kSettingsEntryHeight,
        child: Row(
          children: [
            Container(
              width: 4,
              color: entry.isSynced()
                  ? CupertinoDynamicColor.resolve(CupertinoColors.activeGreen, context)
                  : entry.exported
                      ? CupertinoDynamicColor.resolve(CupertinoColors.systemGrey, context)
                      : CupertinoDynamicColor.resolve(CupertinoColors.destructiveRed, context),
            ),
            Expanded(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                //child: Text((entry.data.get("team_number") as TextEntry).value ?? ""),
                child: Text(title),
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (BuildContext context) {
                        return ScoutingEntryPage(data: entry);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
