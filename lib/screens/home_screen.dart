import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kidsplazone/app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<List<Color>> gradients = [
    [Color(0xFF42A5F5), Color(0xFF7E57C2)],
    [Color(0xFF667EEA), Color(0xFF764BA2)],
    [Color(0xFF43CEA2), Color(0xFF185A9D)],
    [Color(0xFFFF6FD8), Color(0xFF3813C2)],
    [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
  ];

  int currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      setState(() {
        currentIndex = (currentIndex + 1) % gradients.length;
      });
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
      appBar: const GradientAppBar(title: "🎮 KidsPlay Zone"),
      body: AnimatedContainer(
        duration: const Duration(seconds: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradients[currentIndex],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(18),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: .90,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: games.length,
          itemBuilder: (context, i) {
            final g = games[i];
            return GameCard(
              title: g.title,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => g.builder()),
              ),
            );
          },
        ),
      ),
    );
  }
}
