import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spartan_scout/const.dart';
import 'package:spartan_scout/model/template.dart';
import 'package:spartan_scout/provider/scouting_data_provider.dart';
import 'package:spartan_scout/util/util.dart';
import 'package:spartan_scout/widgets/cupertino_section.dart';
import 'package:spartan_scout/widgets/fading_navbar.dart';

class ScoutingEntryPage extends StatefulHookConsumerWidget {
  final ScoutingData data;
  const ScoutingEntryPage({required this.data, super.key});

  @override
  ConsumerState<ScoutingEntryPage> createState() => _ScoutingEntryPageState();
}

class _ScoutingEntryPageState extends ConsumerState<ScoutingEntryPage> {
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
    // Structure data into sections.
    List<List<TemplateEntry>> sections = [];
    int i = -1;
    for (final entry in widget.data.data) {
      if (entry is SectionEntry || entry is SpacerEntry) {
        sections.add([entry]);
        i++;
      } else {
        sections[i].add(entry);
      }
    }

    return WillPopScope(
      onWillPop: () async {
        return await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text("Exit?"),
            content: const Text("Record data will be discarded!"),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("No"),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text("Yes"),
              ),
            ],
          ),
        );
      },
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoDynamicColor.resolve(
            CupertinoColors.systemGroupedBackground, context),
        navigationBar: CupertinoFadingNavigationBar(
          context: context,
          opacity: _navOpacity,
          backgroundColor: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGroupedBackground, context),
          leading: CupertinoNavigationBarBackButton(
            onPressed: () {
              Navigator.maybePop(context);
            },
          ),
          middle: Text('New ${widget.data.type.name.capitalizeWords()} Record'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              // print(JSON5.stringify(widget.data.toJsonSimple()));
              widget.data.updated = DateTime.now();
              ref.read(scoutingDataListProvider(widget.data.type).notifier)
                  .put(widget.data);
              Navigator.of(context).pop();
            },
            child: const Icon(
              CupertinoIcons.check_mark,
            ),
          ),
        ),
        child: widget.data.data.isNotEmpty
            ? CupertinoScrollbar(
                controller: _scroll,
                child: ListView(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    for (final entries in sections)
                      _buildTemplateEntrySection(entries),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              )
            : const CupertinoActivityIndicator(),
      ),
    );
  }

  Widget _buildTemplateEntrySection(List<TemplateEntry> entries) {
    if (entries.isEmpty) {
      return Container();
    }

    String? heading;
    List<TemplateEntry> content;
    if (entries.first is SectionEntry) {
      heading = (entries.first as SectionEntry).prompt;
      content = entries.sublist(1);
    } else if (entries.first is SpacerEntry) {
      content = entries.sublist(1);
    } else {
      content = entries;
    }

    return CupertinoSection(
      heading: heading,
      children: [
        for (final entry in content)
          _buildTemplateEntry(entry)
      ],
    );
  }

  Widget _buildTemplateEntry(TemplateEntry entry) {
    if (entry is TextEntry) {
      return TextWidget(entry);
    } else if (entry is CheckboxEntry) {
      return CheckboxWidget(
        entry: entry,
        onChange: (selected) {
          setState(() {
            if (entry.excludes.isNotEmpty && entry.value) {
              for (final e in widget.data.data.where((e) =>
                  e is CheckboxEntry && entry.excludes.contains(e.name))) {
                (e as CheckboxEntry).value = false;
              }
            }
          });
        },
      );
    } else if (entry is CounterEntry) {
      return CounterWidget(entry);
    }
    return Text(entry.name ?? "No name");
  }
}

class CheckboxWidget extends StatefulWidget {
  final CheckboxEntry entry;
  final ValueChanged<bool>? onChange;
  const CheckboxWidget({
    required this.entry,
    this.onChange,
    super.key,
  });

  @override
  State<CheckboxWidget> createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: kSettingsEntryPadding, top: 3, bottom: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(widget.entry.prompt),
            ),
          ),
          CupertinoSwitch(
              value: widget.entry.value,
              onChanged: (state) {
                setState(() {
                  widget.entry.value = state;
                  widget.onChange?.call(state);
                });
              }),
        ],
      ),
    );
  }
}

class CounterWidget extends StatefulWidget {
  final CounterEntry entry;
  const CounterWidget(this.entry, {super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  @override
  void initState() {
    super.initState();
    widget.entry.value ??= 0;
  }

  @override
  Widget build(BuildContext context) {
    final maxValue = widget.entry.maxValue ?? 9999;
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 6, top: 2, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(widget.entry.prompt),
          ),
          Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: widget.entry.value == 0
                    ? null
                    : () {
                        if (widget.entry.value! > 0) {
                          setState(() {
                            widget.entry.value = widget.entry.value! - 1;
                          });
                        }
                      },
                child: const Icon(CupertinoIcons.minus_circled),
              ),
              SizedBox(
                width: 42,
                child: Center(child: Text(widget.entry.value.toString())),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: widget.entry.value == maxValue
                    ? null
                    : () {
                        if (widget.entry.value! < maxValue) {
                          setState(() {
                            widget.entry.value = widget.entry.value! + 1;
                          });
                        }
                      },
                child: const Icon(
                  CupertinoIcons.add_circled,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class TextWidget extends StatefulWidget {
  final TextEntry entry;
  const TextWidget(this.entry, {super.key});

  @override
  State<TextWidget> createState() => _TextWidgetState();
}

class _TextWidgetState extends State<TextWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    widget.entry.value ??= "";
    _controller = TextEditingController();
    _controller.text = widget.entry.value!;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entry.multiline) {
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: kSettingsEntryPadding, top: 10, bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 5),
                child: Text(widget.entry.prompt),
              ),
            ),
            CupertinoTextField(
              controller: _controller,
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(CupertinoColors.tertiarySystemGroupedBackground, context),
                border: kDefaultRoundedBorder,
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              ),
              keyboardType: widget.entry.numeric
                  ? !kIsWeb && Platform.isIOS
                      ? const TextInputType.numberWithOptions(signed: true)
                      : TextInputType.number
                  : null,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                if (widget.entry.numeric)
                  FilteringTextInputFormatter.digitsOnly,
              ],
              maxLength: widget.entry.length,
              maxLines: null,
              onChanged: (text) {
                widget.entry.value = text;
              },
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 20, right: kSettingsEntryPadding, top: 10, bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(widget.entry.prompt),
            ),
            SizedBox(
              width: 120,
              child: CupertinoTextField(
                controller: _controller,
                decoration: BoxDecoration(
                  color: CupertinoDynamicColor.resolve(CupertinoColors.tertiarySystemGroupedBackground, context),
                  border: kDefaultRoundedBorder,
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                ),
                keyboardType: widget.entry.numeric
                    ? !kIsWeb && Platform.isIOS
                        ? const TextInputType.numberWithOptions(signed: true)
                        : TextInputType.number
                    : null,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  if (widget.entry.numeric)
                    FilteringTextInputFormatter.digitsOnly,
                ],
                maxLength: widget.entry.length,
                textAlign: TextAlign.center,
                onChanged: (text) {
                  widget.entry.value = text;
                },
              ),
            ),
          ],
        ),
      );
    }
  }
}
