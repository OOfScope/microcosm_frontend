import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../controllers/menu_app_controller.dart';
import '../../responsive.dart';
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

  void upNavBarId(int index) {
    setState(() {
      _selectedPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_selectedPage) {
      case 0:
        page = RoadmapScreen(onNavButtonPressed: upNavBarId);
        break;
      case 1:
        page = ProfileScreen();
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
        // If you ever add a new destination to the navigation rail
        // and forget to update this code, the program crashes in development
        throw UnimplementedError('no widget for $_selectedPage');
    }

    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(onNavButtonPressed: upNavBarId),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(onNavButtonPressed: upNavBarId),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 4,
              child: page,
            ),
            const Expanded(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 2 * defaultPadding),
                  Leaderboard(),
                  SizedBox(height: defaultPadding),
                  //TO BE CHANGED WITH ChatApp
                  Flexible(child: Leaderboard()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
