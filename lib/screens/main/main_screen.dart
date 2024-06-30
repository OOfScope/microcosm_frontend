import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../controllers/menu_app_controller.dart';
import '../../responsive.dart';
import '../dashboard/new_roadmap_screen.dart';
import '../dashboard/roadmap_screen.dart';
import '../games/drag_and_drop/drag_and_drop.dart';
import '../games/memory/memory_screen.dart';
import '../games/quiz/quiz.dart';
import '../games/select_the_area/select_the_area_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import 'components/leaderboard.dart';
import 'components/others.dart';
import 'components/side_menu.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedPage = 0;
  final GlobalKey<LeaderboardState> _childKey = GlobalKey<LeaderboardState>();

  void upNavBarId(int index) {
    setState(() {
      _selectedPage = index;
    });
  }

  void updateLeaderboardState() {
    setState(() {
      _childKey.currentState!.updateLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_selectedPage) {
      case 0:
      page = Roadmap();
        // page = RoadmapScreen(onNavButtonPressed: upNavBarId);
        break;
      case 1:
        page = ProfileScreen(onTestButtonPressed: updateLeaderboardState);
        break;
      case 2:
        page = const SettingsScreen();
        break;
      case 3:
        page = DragAndDropGame(onNavButtonPressed: upNavBarId);
        break;
      case 4:
        page = const MemoryGame();
        break;
      case 5:
        page = const QuizGame();
        break;
      case 6:
        page = const SelectTheAreaGame();
        break;

      case 10:
        page = const SelectTheAreaGame();
        break;

      default:
        throw UnimplementedError('no widget for $_selectedPage');
    }

    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(onNavButtonPressed: upNavBarId),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (Responsive.isDesktop(context))
              Expanded(
                child: SideMenu(onNavButtonPressed: upNavBarId),
              ),
            Expanded(
              flex: 4,
              child: page,
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 2 * defaultPadding),
                  Leaderboard(key: _childKey),
                  const SizedBox(height: defaultPadding),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
