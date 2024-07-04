import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef IndexCallback = void Function(int index);

class SideMenu extends StatelessWidget {
  const SideMenu({
    super.key,
    required this.onNavButtonPressed,
  });
  final IndexCallback onNavButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: 150,
                  height: 110,
                  child: kDebugMode
                      ? Image.asset('/images/microcosm.png')
                      : Image.asset('assets/images/microcosm.png'),
                ),
                SizedBox(
                  width: 100,
                  height: 15,
                  child: kDebugMode
                      ? Image.asset('/images/stroke_microcosm.png')
                      : Image.asset('assets/images/stroke_microcosm.png'),
                ),
              ],
            ),
          ),
          DrawerListTile(
            title: 'Dashboard',
            svgSrc: kDebugMode
                ? '/icons/menu_dashboard.svg'
                : 'assets/icons/menu_dashboard.svg',
            press: () => onNavButtonPressed(0),
          ),
          DrawerListTile(
            title: 'Profile',
            svgSrc: kDebugMode
                ? '/icons/menu_profile.svg'
                : 'assets/icons/menu_profile.svg',
            press: () => onNavButtonPressed(1),
          ),
          DrawerListTile(
            title: 'Medyc-AId LLM',
            svgSrc: '/icons/menu_setting.svg',
            press: () => onNavButtonPressed(3),
          ),
          DrawerListTile(
            title: 'Dataset Explorer',
            svgSrc: kDebugMode
                ? '/icons/menu_setting.svg'
                : 'assets/icons/menu_setting.svg',
            press: () => onNavButtonPressed(4),
          ),
          DrawerListTile(
            title: 'Settings',
            svgSrc: kDebugMode
                ? '/icons/menu_setting.svg'
                : 'assets/icons/menu_setting.svg',
            press: () => onNavButtonPressed(9),
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  });

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        height: 16,
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white54),
      ),
    );
  }
}
