import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsplazone/models/item.dart';
import 'package:kidsplazone/screens/about_screen.dart';
import 'package:kidsplazone/app_bar.dart';
import 'package:kidsplazone/screens/aphabetQuegePage.dart';
import 'package:kidsplazone/screens/balloon_pop_page_view.dart';
import 'package:kidsplazone/screens/car_rally_view_screens.dart';
import 'package:kidsplazone/screens/coloring_page_view.dart';
import 'package:kidsplazone/screens/fruit_catcher_pro.dart';
import 'package:kidsplazone/screens/math_adventure_screen.dart';
import 'package:kidsplazone/screens/memory_matched_page_screen.dart';
import 'package:kidsplazone/screens/profile_screen.dart';
import 'package:kidsplazone/screens/swaptitle_screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(BlocProvider(create: (_) => ThemeCubit(), child: const KidsPlayApp()));
}

class KidsPlayApp extends StatelessWidget {
  const KidsPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          title: 'KidsPlay Zone',
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: themeMode, // 👈 Cubit se aaya hua mode
          home: const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final _screens = const [HomeScreen(), AboutScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "About"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  void toggleTheme() {
    emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
}

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
  Timer? _timer; // ✅ store timer

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return; // ✅ mounted check
      setState(() {
        currentIndex = (currentIndex + 1) % gradients.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ✅ stop timer when screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final games = <_GameCardData>[
      _GameCardData('🎈 Balloon Pop', () => const BalloonPopPage()),
      _GameCardData('🧠 Memory Match', () => const MemoryMatchPage()),
      _GameCardData('🧩 Jigsaw Puzzle', () => const SwapPuzzlePage()),
      _GameCardData('🎨 Coloring Board', () => const ColoringPage()),
      _GameCardData('🔢 Math Adventure', () => const MathAdventurePage()),
      _GameCardData('🔤 Alphabet Quest', () => const AlphabetQuestPage()),
      _GameCardData('🏎️ Car Rally', () => const CarRallyLearnPage()),
      _GameCardData('🍎 Fruit Cacther', () => const FruitCatcherPro()),
    ];

    return Scaffold(
      // Gradient AppBar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const SafeArea(
            child: Center(
              child: Text(
                "🎮 KidsPlay Zone",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                ),
              ),
            ),
          ),
        ),
      ),

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
            return _GameCard(
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

class _GameCardData {
  final String title;
  final Widget Function() builder;
  _GameCardData(this.title, this.builder);
}

class _GameCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _GameCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF8F9FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.1),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title.split(' ').first,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF444444),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Tap to Play",
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
