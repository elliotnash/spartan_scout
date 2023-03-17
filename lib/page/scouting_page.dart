import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spartan_scout/const.dart';
import 'package:spartan_scout/model/template.dart';
import 'package:spartan_scout/page/scouting_entry_page.dart';
import 'package:spartan_scout/provider/scouting_data_provider.dart';
import 'package:spartan_scout/provider/template_provider.dart';
import 'package:spartan_scout/widgets/cupertino_section.dart';
import 'package:spartan_scout/widgets/safearea_refresh_indicator.dart';

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
                      ScoutingDataWidget(record)
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

class ScoutingDataWidget extends StatelessWidget {
  final ScoutingData entry;
  const ScoutingDataWidget(this.entry, {super.key});

  @override
  Widget build(BuildContext context) {
    //TODO make work
    // final teamNumber = entry.data.where((e) => e.name == "team_number" && e is TextEntry).toList();
    // final natNumber = entry.data.where((e) => e.name == "team_number" && e is TextEntry).toList();
    // return Text(teamNumber.isNotEmpty ? (teamNumber[0] as TextEntry).value ?? "BAD" : "NOO");
    return SwipeActionCell(
      key: ObjectKey(entry),
      backgroundColor: Colors.transparent,
      trailingActions: [
        SwipeAction(
          title: "delete",
          widthSpace: 84,
          performsFirstActionWithFullSwipe: true,
          onTap: (CompletionHandler handler) async {
            await handler(true);
          },
          color: CupertinoDynamicColor.resolve(CupertinoColors.destructiveRed, context),
        )
      ],
      child: SizedBox(
        width: double.infinity,
        height: kSettingsEntryHeight,
        child: Row(
          children: [
            Container(
              width: 4,
              color: entry.storedAt == null
                ? CupertinoDynamicColor.resolve(CupertinoColors.destructiveRed, context)
                : CupertinoDynamicColor.resolve(CupertinoColors.activeGreen, context),
            ),
            Expanded(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text((entry.data.get("team_number") as TextEntry).value ?? ""),
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
