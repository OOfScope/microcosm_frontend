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
            child: Image.asset('assets/images/microcosm.png'),
          ),
          DrawerListTile(
            title: 'Dashboard',
            svgSrc: 'assets/icons/menu_dashboard.svg',
            press: () => onNavButtonPressed(0),
          ),
          DrawerListTile(
            title: 'Profile',
            svgSrc: 'assets/icons/menu_profile.svg',
            press: () => onNavButtonPressed(1),
          ),
          DrawerListTile(
            title: 'Medyc-AId LLM',
            svgSrc: 'assets/icons/menu_setting.svg',
            press: () => onNavButtonPressed(3),
          ),
          DrawerListTile(
            title: 'Settings',
            svgSrc: 'assets/icons/menu_setting.svg',
            press: () => onNavButtonPressed(2),
          ),

          DrawerListTile(
            title: 'TestGame',
            svgSrc: 'assets/icons/menu_setting.svg',
            press: () => onNavButtonPressed(10),
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
