import 'package:admin/constants.dart';
import 'package:admin/controllers/MenuAppController.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/roadmap_screen.dart';
import 'package:admin/screens/games/select_the_area/select_the_area_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/screens/settings/settings_screen.dart';
import 'package:admin/screens/profile/profile_screen.dart';
import 'package:admin/screens/main/components/leaderboard.dart';
import 'package:admin/screens/main/components/others.dart';
import 'package:admin/screens/dashboard/roadmap_test.dart';
import 'components/side_menu.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var _selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_selectedPage) {
      case 0:
        page = RoadmapScreen();
        break;
      case 1:
        page = Owly();
        break;
      case 2:
        page = SettingsScreen();
        break;
      case 3:
        page = MapVerticalExample();
        break;
      default:
        // If you ever add a new destination to the navigation rail
        // and forget to update this code, the program crashes in development
        throw UnimplementedError('no widget for $_selectedPage');
    }

    void upNavBarId(int index) {
      setState(() {
        _selectedPage = index;
      });
    }

    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(onNavButtonPressed: upNavBarId),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Expanded(
              // It takes 1/6 part of the screen
              flex: 1,
              child: Column(
                children: [
                  SizedBox(height: defaultPadding),
                  Leaderboard(),
                  SizedBox(height: defaultPadding),
                  Flexible(child: Other()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
