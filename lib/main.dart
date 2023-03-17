import 'dart:ui';

import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inkblob_navigation_bar/inkblob_navigation_bar.dart';
import 'package:spartan_scout/model/template.dart';
import 'package:spartan_scout/page/scouting_entry_page.dart';
import 'package:spartan_scout/page/scouting_page.dart';
import 'package:spartan_scout/page/settings_page.dart';
import 'package:spartan_scout/provider/template_provider.dart';
import 'package:spartan_scout/widgets/fading_navbar.dart';
import 'package:spartan_scout/widgets/snackbar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarContrastEnforced: true,
    statusBarColor: Colors.transparent,
  ));
  runApp(const SpartanScout());
}

class SpartanScout extends StatelessWidget {
  const SpartanScout({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MediaQuery.fromWindow(
        child: const CupertinoApp(
          useInheritedMediaQuery: true,
          title: 'Spartan Scout',
          home: ToastProvider(
            child: Home(),
          ),
        ),
      ),
    );
  }
}

class Home extends StatefulHookConsumerWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> with TickerProviderStateMixin {
  static const _transitionDuration = Duration(milliseconds: 270);
  static const _transitionCurve = Curves.easeInOutExpo;

  late PageController _pageController;
  bool _animatingPage = false;
  int _selectedIndex = 0;
  int _previousIndex = 0;

  late AnimationController _trailingController;
  late CurvedAnimation _trailingAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _trailingController = AnimationController(
      duration: _transitionDuration,
      value: 1,
      vsync: this,
    );
    _trailingAnimation = CurvedAnimation(
      parent: _trailingController,
      curve: _transitionCurve,
    );
  }

  @override
  void dispose() {
    _trailingAnimation.dispose();
    _trailingController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _animatingPage = true;
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
      if (_animatingPage == false || _previousIndex != _selectedIndex) {
        bool previousShowTrailing = _previousIndex != 2;
        bool showTrailing = _selectedIndex != 2;
        if (previousShowTrailing != showTrailing) {
          _trailingController.animateTo(showTrailing ? 1 : 0);
        }
        _pageController
            .animateToPage(
          index,
          duration: _transitionDuration,
          curve: _transitionCurve,
        ).then((value) {
          _animatingPage = false;
          _previousIndex = _selectedIndex;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoDynamicColor.resolve(CupertinoColors.systemGroupedBackground, context),
      navigationBar: CupertinoFadingNavigationBar(
        context: context,
        // TODO fade navbar
        opacity: 1.0,
        middle: const Text('Spartan Scout'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.gear,
          ),
          onPressed: () {
            Navigator.of(context).push(SettingsPage.route());
          },
        ),
        trailing: FadeTransition(
          opacity: _trailingAnimation,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(
              CupertinoIcons.add,
              // color: CupertinoColors.label,
            ),
            onPressed: () async {
              if (_selectedIndex != 2) {
                final scoutingData = (await ref.read(templatesProvider.notifier).get()).newScoutingData(_selectedIndex == 0 ? ScoutingType.pit : ScoutingType.match);
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (BuildContext context) {
                      return ScoutingEntryPage(data: scoutingData);
                    },
                  ),
                );
              }
            },
          ),
        ),
      ),
      child: Stack(
        children: [
          _buildPageView(),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(padding: MediaQuery.of(context).padding + const EdgeInsets.only(bottom: 60, top: 44)),
      child: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: const [
          ScoutingPage(type: ScoutingType.pit),
          ScoutingPage(type: ScoutingType.match),
          Center(
            child: Text("page 3"),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    final itemStyle = CupertinoTheme.of(context)
        .textTheme
        .textStyle
        .copyWith(fontSize: 15);
    final itemColor = CupertinoTheme.of(context)
        .textTheme
        .textStyle
        .color!;

    return SafeArea(
      bottom: false,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  height: 0.2,
                  color: CupertinoDynamicColor.resolve(CupertinoColors.separator, context)
              ),
              InkblobNavigationBar(
                showElevation: false,
                backgroundColor: CupertinoTheme.of(context)
                    .barBackgroundColor
                    .withAlpha(236),
                selectedIndex: _selectedIndex,
                previousIndex: _previousIndex,
                onItemSelected: _onItemTapped,
                items: <InkblobBarItem>[
                  InkblobBarItem(
                    title: Text(
                      'Pit',
                      style: itemStyle,
                    ),
                    filledIcon: const Icon(CupertinoIcons.wrench_fill),
                    emptyIcon: const Icon(CupertinoIcons.wrench),
                    color: itemColor,
                  ),
                  InkblobBarItem(
                    title: Text(
                      'Match',
                      style: itemStyle,
                    ),
                    filledIcon: const Icon(
                        CupertinoIcons.game_controller_solid),
                    emptyIcon:
                    const Icon(CupertinoIcons.game_controller),
                    color: itemColor,
                  ),
                  InkblobBarItem(
                    title: Text(
                      'Export',
                      style: itemStyle,
                    ),
                    filledIcon: const Icon(CupertinoIcons.share_solid),
                    emptyIcon: const Icon(CupertinoIcons.share),
                    color: itemColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* Full match scouting -- both alliances
 *  What is scored, but not by who
 *
 * Alliance scouting -- single alliance
 *  Who is scoring stuff
 *
 * Individual team -- single team
 *  What they're scoring
 *  + Qualitative
 *
 * Pit scouting -- individual team
 */
