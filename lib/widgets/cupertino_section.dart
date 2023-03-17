import 'package:flutter/cupertino.dart';

class CupertinoSection extends StatelessWidget {
  final String? heading;
  final List<Widget> children;
  const CupertinoSection({
    this.heading,
    required this.children,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 18,
        ),
        if (heading != null)
          ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Text(
                  heading!.toUpperCase(),
                  style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    fontSize: CupertinoTheme.of(context).textTheme.textStyle.fontSize! * 0.9,
                    color: CupertinoDynamicColor.resolve(CupertinoColors.secondaryLabel, context),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
          ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: CupertinoDynamicColor.resolve(CupertinoColors.secondarySystemGroupedBackground, context),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                for (int i=0; i<children.length; i++)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: (i<children.length-1) ? BorderSide(
                          width: 0.0,
                          color: CupertinoDynamicColor.resolve(CupertinoColors.separator, context),
                        ) : BorderSide.none,
                      ),
                    ),
                    child: children[i],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}