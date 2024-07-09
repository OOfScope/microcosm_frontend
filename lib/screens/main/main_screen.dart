import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../controllers/menu_app_controller.dart';
import '../../responsive.dart';
import '../../utils.dart';
import '../dashboard/components/level_button.dart';
import '../dashboard/new_roadmap_screen.dart';
import '../dataset_explorer/dataset_explorer.dart';
import '../games/game_screen.dart';
import '../llmchat/llmchat.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import 'components/chatbox.dart';
import 'components/leaderboard.dart';
import 'components/side_menu.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedPage = 0;
  int _difficulty = 0;
  int _level = 0;
  final GlobalKey<LeaderboardState> _childKey = GlobalKey<LeaderboardState>();

  void upNavBarId(int index) {
    setState(() {
      _selectedPage = index;
    });
  }

  void loadGame(int level, int difficulty) {
    setState(() {
      _selectedPage = 10;
      _difficulty = difficulty;
      _level = level;
    });
  }

  void updateLevelScore(int index, int score) {
    final List<LevelButton> levelButtons =
        LevelButtonManager.instance.levelButtons;
    index -= 1;
    setState(() {
      // print(
      //     'LevelStats: ${levelButtons[index].stars} ${levelButtons[index].status} ${levelButtons[index].isActive} ${levelButtons[index].levelScore} ${levelButtons[index].levelNumber}');

      if (levelButtons[index].stars < 3) {
        if (index >= 0 && index < levelButtons.length) {
          if (score != wrongAnswerScore) {
            levelButtons[index].stars += 1;

            if (levelButtons[index].stars == 3) {
              levelButtons[index].status = LevelStatus.completed;
              return;
            }

            // print(
            //     'LevelStats: ${levelButtons[index].stars} ${levelButtons[index].status} ${levelButtons[index].isActive} ${levelButtons[index].levelScore} ${levelButtons[index].levelNumber}');

            UserManager.instance.user.addScore(score);
            levelButtons[index].addLevelScore(score);

            if ((index + 1) % 5 == 0) {
              if (GameInfoManager.instance.getHighestFrequencyGame() == null) {
                levelButtons[index + 1].status = LevelStatus.completed;
                levelButtons[index + 1].status = LevelStatus.inProgress;
                // if there is no game in GameInfoManager, then unlock the next level
              } else {
                Future.delayed(const Duration(seconds: 4), () {
                  GameInfoManager.instance.removeHighestFrequencyGame();
                  if (GameInfoManager.instance.getHighestFrequencyGame() ==
                      null) {
                    levelButtons[index].status = LevelStatus.completed;
                    levelButtons[index + 1].status = LevelStatus.inProgress;
                  }
                });
              }
            } else {
              levelButtons[index + 1].status = LevelStatus.inProgress;
            }

            levelButtons[index + 1].isActive = true;

            updateLeaderboardState();
          } else {
            // Add index and difficulty to the gameInfo for spaced Repetition
            if (index % 5 + 1 != 0) {
              GameInfoManager.instance.update(index, _difficulty);
            }
          }
        }
      }
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
        page = Roadmap(onLevelButtonPressed: loadGame);
        // page = RoadmapScreen(onNavButtonPressed: upNavBarId);
        break;
      case 1:
        page =
            ProfileScreen(onDebugAddScoreButtonPressed: updateLeaderboardState);
        break;
      case 9:
        page = const SettingsScreen();
        break;
      case 3:
        page = const LLMChatApp();
        break;
      case 4:
        page = const DatasetExplorer();
        break;
      case 10:
        page = GameScreen(
          level: _level,
          difficulty: _difficulty,
          onGameEnd: upNavBarId,
          scoreUpdate: updateLevelScore,
        );
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
              Column(children: [
                Expanded(
                  child: SideMenu(onNavButtonPressed: upNavBarId),
                ),
                Leaderboard(key: _childKey),
              ]),
            Expanded(
              flex: 4,
              child: page,
            ),
            const Expanded(child: ChatBox())
          ],
        ),
      ),
    );
  }
}
