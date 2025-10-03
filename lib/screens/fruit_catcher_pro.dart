import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:kidsplazone/main.dart';
import 'package:kidsplazone/models/item.dart';

class FruitCatcherPro extends StatefulWidget {
  const FruitCatcherPro({super.key});

  @override
  State<FruitCatcherPro> createState() => _FruitCatcherProState();
}

class _FruitCatcherProState extends State<FruitCatcherPro> {
  double basketX = 0;
  int score = 0;
  int timeLeft = 60;
  int level = 1;
  int speed = 5;
  Timer? gameTimer;
  Timer? fruitTimer;
  List<Item> items = [];

  // Audio players
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    startGame();
    playBackgroundMusic();
  }

  void playBackgroundMusic() async {
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    //  await _musicPlayer.play(AssetSource("sounds/music.mp3"));
  }

  void startGame() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;

        if (timeLeft % 15 == 0 && speed < 15) {
          level++;
          speed += 2;
        }

        if (timeLeft <= 0) {
          timer.cancel();
          endGame();
        }
      });
    });

    fruitTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      addItem();
    });
  }

  void addItem() {
    final random = Random();
    final itemTypes = [
      {"emoji": "🍎", "points": 10, "isBomb": false},
      {"emoji": "🍌", "points": 15, "isBomb": false},
      {"emoji": "🍊", "points": 20, "isBomb": false},
      {"emoji": "🍇", "points": 25, "isBomb": false},
      {"emoji": "💣", "points": -20, "isBomb": true},
    ];

    final item = itemTypes[random.nextInt(itemTypes.length)];
    items.add(
      Item(
        x: random.nextDouble() * 300 - 150,
        y: -50,
        emoji: item["emoji"] as String,
        points: item["points"] as int,
        isBomb: item["isBomb"] as bool,
      ),
    );
    setState(() {});
  }

  void moveBasket(bool right) {
    setState(() {
      basketX += right ? 30 : -30;
      if (basketX < -160) basketX = -160;
      if (basketX > 160) basketX = 160;
    });
  }

  void updateItems() {
    for (int i = items.length - 1; i >= 0; i--) {
      items[i].y += speed;
      if (items[i].y > 500) {
        items.removeAt(i);
      } else if ((items[i].y > 400) && (items[i].x - basketX).abs() < 60) {
        // Catch event
        score += items[i].points;
        playEffect(items[i].isBomb);
        showEffect(items[i].emoji, items[i].points);
        items.removeAt(i);
      }
    }
    setState(() {});
  }

  void playEffect(bool isBomb) async {
    if (isBomb) {
      await _effectPlayer.play(AssetSource("sounds/bomb.mp3"));
    } else {
      await _effectPlayer.play(AssetSource("sounds/catch.mp3"));
    }
  }

  void endGame() {
    fruitTimer?.cancel();
    _musicPlayer.stop(); // stop music

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("🎮 Game Over!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Your Score: $score",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              score > 200
                  ? "🏆 Champion! Amazing reflexes!"
                  : score > 100
                  ? "⭐ Great job!"
                  : "👍 Keep practicing!",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Exit"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                score = 0;
                timeLeft = 60;
                level = 1;
                speed = 5;
                items.clear();
                startGame();
                playBackgroundMusic();
              });
            },
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
  }

  void showEffect(String emoji, int points) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 300,
        left: MediaQuery.of(context).size.width / 2 - 30,
        child: Text(
          points > 0 ? "+$points $emoji" : "$points $emoji",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: points > 0 ? Colors.green : Colors.red,
            shadows: const [
              Shadow(color: Colors.black, blurRadius: 5, offset: Offset(2, 2)),
            ],
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 1), () => entry.remove());
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    fruitTimer?.cancel();
    _musicPlayer.dispose();
    _effectPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 30), () => updateItems());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Score / Timer / Level
            Positioned(
              top: 40,
              left: 20,
              child: Text(
                "🎯 Score: $score",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: Text(
                "⏱️ $timeLeft s",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              top: 80,
              child: Text(
                "🔥 Level $level",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),

            // Items
            for (var item in items)
              Positioned(
                top: item.y.toDouble(),
                left: item.x + MediaQuery.of(context).size.width / 2 - 20,
                child: Text(
                  item.emoji,
                  style: const TextStyle(
                    fontSize: 40,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black26,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),

            // Basket
            Positioned(
              bottom: 40,
              left: MediaQuery.of(context).size.width / 2 + basketX - 50,
              child: const Text("🧺", style: TextStyle(fontSize: 80)),
            ),

            // Controls
            Positioned(
              bottom: 10,
              left: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed: () => moveBasket(false),
                child: const Icon(Icons.arrow_left, size: 30),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed: () => moveBasket(true),
                child: const Icon(Icons.arrow_right, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
