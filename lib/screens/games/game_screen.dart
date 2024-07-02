import 'dart:async';
import 'package:flutter/material.dart';
import '../main/components/header.dart';
import 'wrapper/game_wrapper.dart';

class GameScreen extends StatefulWidget {
  final int difficulty;
  final int level;
  final void Function(int) onGameEnd;

  const GameScreen({
    super.key,
    required this.difficulty,
    required this.level,
    required this.onGameEnd,
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double _progress = 1.0; // Progress for the timer (1.0 means 100%)
  int _score = 0; // Initial score
  int _timeLeft = 20; // Time left in seconds
  Timer? _timer;
  bool _gameOver = false; // Tracks if the game is over
  bool _isStarted = false; // Tracks if the timer is started

  @override
  void initState() {
    super.initState();
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
                _gameOver = true;
              });
            }
            _triggerGameEnd();
          } else {
            if (mounted) {
              setState(() {
                _timeLeft -= 1;
                _progress =
                    _timeLeft / 20; // Decrease progress based on total time
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
        _score += points;
      });
    }
  }

  void onGameLoaded() {
    if (mounted) {
      setState(() {
        startTimer();
      });
    }
  }

  void _triggerGameEnd() {
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        widget.onGameEnd(0);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Header(title: 'Quiz Game'),
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
                          'Score: $_score',
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
                child: GameWrapper(
                  onLoaded: onGameLoaded,
                  onScoreUpdate: updateScore,
                ),
              ),
            ],
          ),
          if (_gameOver)
            Positioned.fill(
              child: Container(
                color: Colors.grey.withOpacity(0.7),
                child: const Center(
                  child: Text(
                    'Game Over!',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
