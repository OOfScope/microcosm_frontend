import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



import '../../../constants.dart';
import '../../../controllers/menu_app_controller.dart';
import '../../../models/user_data.dart';
import '../../../responsive.dart';
import '../../../utils.dart';


class Header extends StatelessWidget {
  const Header({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: context.read<MenuAppController>().controlMenu,
          ),
        if (!Responsive.isMobile(context))
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        const ProfileCard()
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {


  const ProfileCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(left: defaultPadding),
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: (defaultPadding / 2) - 3,
      ),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white10),
      ),
      child: const AccountEntry(),
    );
  }
}

class AccountEntry extends StatelessWidget {

  const AccountEntry({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final User user = UserManager.instance.user;

    return Row(
      children: <Widget>[
        user.smallCircleAvatar,
        if (!Responsive.isMobile(context))
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            child: Text(user.nickname),
          ),
      ],
    );
  }
}
