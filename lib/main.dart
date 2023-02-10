import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inkblob_navigation_bar/inkblob_navigation_bar.dart';
import 'package:spartan_scout/provider/template_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MediaQuery.fromWindow(
        child: const CupertinoApp(
          useInheritedMediaQuery: true,
          title: 'Flutter Demo',
          home: MyHomePage(title: "test"),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PageController _pageController;
  bool _animatingPage = false;
  int _selectedIndex = 0;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _animatingPage = true;
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
      if (_animatingPage == false || _previousIndex != _selectedIndex) {
        _pageController
            .animateToPage(
          index,
          duration: const Duration(milliseconds: 270),
          curve: Curves.easeInOutExpo,
        ).then((value) {
          _animatingPage = false;
          _previousIndex = _selectedIndex;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoTabView(
        builder: (BuildContext context) {
          return PageView(
            controller: _pageController,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Text('Drag me up', textAlign: TextAlign.center),
                  CupertinoButton.filled(
                    onPressed: () {
                      // Navigator.push(context, CupertinoPageRoute<Widget>(
                      //     builder: (BuildContext context) {
                      //       return const NextPage();
                      //     }));
                    },
                    child: Consumer(
                      builder: (context, ref, child) {
                        final test = ref.watch(templatesProvider);
                        return Text("test");
                      },
                    )
                  ),
                ],
              ),
            ],
          );
        },
      ),
      appBar: CupertinoNavigationBar(
        middle: const Text('Spartan Scout'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.gear,
            // color: CupertinoColors.label,
          ),
          onPressed: () {
            _pageController.nextPage(duration: Duration(milliseconds: 200), curve: Curves.bounceIn);
            print('test');
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkblobNavigationBar(
            showElevation: false,
            backgroundColor: CupertinoTheme.of(context).barBackgroundColor.withAlpha(236),
            selectedIndex: _selectedIndex,
            previousIndex: _previousIndex,
            onItemSelected: _onItemTapped,
            items: <InkblobBarItem>[
              InkblobBarItem(
                title: Text(
                  'Pit',
                  style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontSize: 15),
                ),
                filledIcon: const Icon(CupertinoIcons.wrench_fill),
                emptyIcon: const Icon(CupertinoIcons.wrench),
                color: CupertinoTheme.of(context).textTheme.textStyle.color!
              ),
              InkblobBarItem(
                  title: Text(
                    'Match',
                    style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontSize: 15),
                  ),
                filledIcon: const Icon(CupertinoIcons.game_controller_solid),
                emptyIcon: const Icon(CupertinoIcons.game_controller),
                color: CupertinoTheme.of(context).textTheme.textStyle.color!
              ),
              InkblobBarItem(
                title: Text(
                  'Export',
                  style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontSize: 15),
                ),
                filledIcon: const Icon(CupertinoIcons.share_solid),
                emptyIcon: const Icon(CupertinoIcons.share),
                color: CupertinoTheme.of(context).textTheme.textStyle.color!
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
