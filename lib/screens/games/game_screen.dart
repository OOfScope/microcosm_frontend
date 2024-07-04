import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../utils.dart';
import 'wrapper/game_wrapper.dart';

class GameScreen extends StatefulWidget {
  const GameScreen(
      {super.key,
      required this.difficulty,
      required this.level,
      required this.onGameEnd,
      required this.scoreUpdate});

  final int difficulty;
  final int level;
  final void Function(int) onGameEnd;
  final void Function(int, int) scoreUpdate;

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  double _progress = 1.0; // Progress for the timer (1.0 means 100%)
  int _timeLeft = 20; // Time left in seconds
  final int _totalTime = 20; // Total time in seconds
  Timer? _timer;
  bool _isGameOver = false; // Tracks if the game is over
  bool _isStarted = false; // Tracks if the timer is started
  int score = 0;

  @override
  void initState() {
    super.initState();
    score =
        LevelButtonManager.instance.levelButtons[widget.level - 1].levelScore;
  }

  void startTimer() {
    if (!_isStarted) {
      _isStarted = true;
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (Timer timer) {
          if (_progress <= 0 || _timeLeft <= 0) {
            timer.cancel();
            if (mounted) {
              setState(() {
                _isGameOver = true;
                widget.scoreUpdate(widget.level, wrongAnswerScore);
              });
            }
            _triggerGameEnd();
          } else {
            if (mounted) {
              setState(() {
                _timeLeft -= 1;
                _progress = _timeLeft /
                    _totalTime; // Decrease progress based on total time
              });
            }
          }
        },
      );
    }
  }

  void updateScore(int points) {
    if (mounted) {
      setState(() {
        widget.scoreUpdate(widget.level, points);
        updateInternalScore();
      });
    }
  }

  void updateInternalScore() {
    if (mounted) {
      setState(() {
        score = LevelButtonManager
            .instance.levelButtons[widget.level - 1].levelScore;
      });
    }
  }

  void gameLoaded() {
    if (mounted) {
      setState(() {
        startTimer();
      });
    }
  }

  void _triggerGameEnd() {
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        widget.onGameEnd(0);
      }
    });
  }

  void nextLevel() {
    if (mounted) {
      widget.onGameEnd(0);
    }
  }

  void gameCompleted() {
    if (mounted) {
      setState(() {
        _timer?.cancel();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GameWrapper game = GameWrapper(
      index: widget.level,
      onGameLoaded: gameLoaded,
      onScoreUpdate: updateScore,
      onGameCompleted: gameCompleted,
      onNextLevel: nextLevel,
    );
    return Scaffold(
      appBar: AppBar(
        // Rendere le variabili bold
        title: GameScreenHeader(widget: widget),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700, // Dark blue background
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: const Offset(0, 2), // Shadow position
                            ),
                          ],
                        ),
                        height: 30, // Make the progress bar thicker
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(begin: 1.0, end: _progress),
                            duration: const Duration(milliseconds: 500),
                            builder: (BuildContext context, double value,
                                Widget? child) {
                              return LinearProgressIndicator(
                                value: value,
                                backgroundColor: Colors.grey[300],
                                color: Colors.blue,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'Score: $score',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Time Left: $_timeLeft s',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: game,
              ),
            ],
          ),
          if (_isGameOver)
            Positioned.fill(
              child: Container(
                color: Colors.grey.withOpacity(0.7),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Game Over!\n',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Complete the game to continue',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key, required this.title});
  final Widget title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: title,
    );
  }
}

class GameScreenHeader extends StatelessWidget {
  const GameScreenHeader({
    super.key,
    required this.widget,
  });

  final GameScreen widget;

  @override
  Widget build(BuildContext context) {
    return Header(
      title: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              const TextSpan(text: 'Level: '),
              TextSpan(
                text: '${widget.level}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' - Difficulty: '),
              TextSpan(
                text: widget.difficulty == 0
                    ? 'Easy'
                    : widget.difficulty == 1
                        ? 'Medium'
                        : 'Hard',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' - Game: '),
              TextSpan(
                text: '${gameTitles[widget.level % 5]}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          style: const TextStyle(fontSize: 30, color: Colors.white)),
    );
  }
}
