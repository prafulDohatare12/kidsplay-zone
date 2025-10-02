import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsplazone/app_bar.dart';

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

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text("👤 Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 20),
            const Text("Welcome, Kid!", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.brightness_6),
              label: const Text("Toggle Dark/Light Mode"),
              onPressed: () => themeCubit.toggleTheme(),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ℹ️ About")),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "KidsPlay Zone is the safest platform for kids to learn and play fun games.\n\n"
            "✨ Educational\n✨ Safe & Fun\n✨ Free to Play",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
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

/// MEMORY MATCH (Cubit)
class MemoryMatchPage extends StatelessWidget {
  const MemoryMatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MemoryCubit()..start(GameDifficulty.easy),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🧠 Memory Match'),
          actions: [
            PopupMenuButton<GameDifficulty>(
              onSelected: (d) => context.read<MemoryCubit>().start(d),
              itemBuilder: (c) => const [
                PopupMenuItem(
                  value: GameDifficulty.easy,
                  child: Text('Easy 4x4'),
                ),
                PopupMenuItem(
                  value: GameDifficulty.medium,
                  child: Text('Medium 6x4'),
                ),
                PopupMenuItem(
                  value: GameDifficulty.hard,
                  child: Text('Hard 6x6'),
                ),
              ],
            ),
          ],
        ),
        body: const _MemoryBoard(),
      ),
    );
  }
}

enum GameDifficulty { easy, medium, hard }

class MemoryState {
  final int cols;
  final int rows;
  final List<String> cards; // emojis duplicated + shuffled
  final Set<int> matched;
  final List<int> flipped; // indices currently face up (max 2)
  final int moves;
  final int score;
  final Duration elapsed;
  final bool finished;

  const MemoryState({
    required this.cols,
    required this.rows,
    required this.cards,
    required this.matched,
    required this.flipped,
    required this.moves,
    required this.score,
    required this.elapsed,
    required this.finished,
  });

  MemoryState copyWith({
    int? cols,
    int? rows,
    List<String>? cards,
    Set<int>? matched,
    List<int>? flipped,
    int? moves,
    int? score,
    Duration? elapsed,
    bool? finished,
  }) => MemoryState(
    cols: cols ?? this.cols,
    rows: rows ?? this.rows,
    cards: cards ?? this.cards,
    matched: matched ?? this.matched,
    flipped: flipped ?? this.flipped,
    moves: moves ?? this.moves,
    score: score ?? this.score,
    elapsed: elapsed ?? this.elapsed,
    finished: finished ?? this.finished,
  );
}

class MemoryCubit extends Cubit<MemoryState> {
  MemoryCubit()
    : super(
        const MemoryState(
          cols: 0,
          rows: 0,
          cards: [],
          matched: {},
          flipped: [],
          moves: 0,
          score: 0,
          elapsed: Duration.zero,
          finished: false,
        ),
      );

  Timer? _timer;
  DateTime? _start;

  static const _emojis = [
    '🐶',
    '🐱',
    '🐭',
    '🐹',
    '🐰',
    '🦊',
    '🐻',
    '🐼',
    '🐨',
    '🐯',
    '🦁',
    '🐸',
    '🐵',
    '🦋',
    '🌺',
    '🍎',
    '⚽',
    '🚗',
    '✈️',
    '🎵',
    '🎨',
    '📚',
    '🏆',
    '💎',
    '🌟',
    '🎁',
    '🍕',
    '🎸',
  ];

  void start(GameDifficulty d) {
    _timer?.cancel();
    final grid = switch (d) {
      GameDifficulty.easy => (cols: 4, rows: 4),
      GameDifficulty.medium => (cols: 6, rows: 4),
      GameDifficulty.hard => (cols: 6, rows: 6),
    };

    final pairs = (grid.cols * grid.rows) ~/ 2;
    final pool = _emojis.take(pairs).toList();
    final cards = [...pool, ...pool]..shuffle();

    emit(
      MemoryState(
        cols: grid.cols,
        rows: grid.rows,
        cards: cards,
        matched: {},
        flipped: [],
        moves: 0,
        score: 0,
        elapsed: Duration.zero,
        finished: false,
      ),
    );

    _start = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final start = _start;
      if (start == null) return;
      final elapsed = DateTime.now().difference(start);
      emit(state.copyWith(elapsed: elapsed));
    });
  }

  void flip(int index) {
    if (state.finished) return;
    if (state.matched.contains(index)) return;
    if (state.flipped.contains(index)) return;

    final flipped = [...state.flipped, index];
    if (flipped.length < 2) {
      emit(state.copyWith(flipped: flipped));
      return;
    }

    // Two cards flipped: check match
    final a = flipped[0];
    final b = flipped[1];
    final isMatch = state.cards[a] == state.cards[b];

    if (isMatch) {
      final matched = {...state.matched, a, b};
      final score = state.score + 100;
      final allMatched = matched.length == state.cards.length;
      emit(
        state.copyWith(
          matched: matched,
          flipped: [],
          moves: state.moves + 1,
          score: score,
          finished: allMatched,
        ),
      );
      if (allMatched) _timer?.cancel();
    } else {
      // Temporarily show both, then hide
      emit(state.copyWith(flipped: flipped, moves: state.moves + 1));
      Future.delayed(const Duration(milliseconds: 700), () {
        emit(state.copyWith(flipped: []));
      });
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

class _MemoryBoard extends StatelessWidget {
  const _MemoryBoard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoryCubit, MemoryState>(
      builder: (context, s) {
        if (s.cards.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _chip('🎯 Score', s.score.toString()),
                  _chip('🔄 Moves', s.moves.toString()),
                  _chip('⏱️ Time', _fmt(s.elapsed)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: s.cols,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: s.cards.length,
                  itemBuilder: (context, i) {
                    final faceUp =
                        s.flipped.contains(i) || s.matched.contains(i);
                    return GestureDetector(
                      onTap: () => context.read<MemoryCubit>().flip(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: faceUp
                              ? const Color(0xFFE3F2FD)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: s.matched.contains(i)
                                ? Colors.green
                                : const Color(0xFF2196F3),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            faceUp ? s.cards[i] : '❓',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (s.finished)
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: () =>
                      context.read<MemoryCubit>().start(GameDifficulty.easy),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Play Again'),
                ),
              ),
          ],
        );
      },
    );
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _chip(String label, String value) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFF667EEA)),
    );
  }
}

/// BALLOON POP (Cubit)
class BalloonPopPage extends StatelessWidget {
  const BalloonPopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BalloonCubit()..start(),
      child: Scaffold(
        appBar: AppBar(title: const Text('🎈 Balloon Pop')),
        body: const _BalloonGameView(),
      ),
    );
  }
}

class BalloonState {
  final List<Balloon> balloons;
  final int score;
  final int timeLeft; // seconds
  final bool running;
  const BalloonState({
    required this.balloons,
    required this.score,
    required this.timeLeft,
    required this.running,
  });

  BalloonState copyWith({
    List<Balloon>? balloons,
    int? score,
    int? timeLeft,
    bool? running,
  }) => BalloonState(
    balloons: balloons ?? this.balloons,
    score: score ?? this.score,
    timeLeft: timeLeft ?? this.timeLeft,
    running: running ?? this.running,
  );
}

class Balloon {
  Offset pos; // pixels
  double vy; // upward speed (pixels per tick)
  final Color color;
  final int points;
  final double radius;
  Balloon({
    required this.pos,
    required this.vy,
    required this.color,
    required this.points,
    required this.radius,
  });
}

class BalloonCubit extends Cubit<BalloonState> {
  BalloonCubit()
    : super(
        const BalloonState(
          balloons: [],
          score: 0,
          timeLeft: 60,
          running: false,
        ),
      );

  final _rand = Random();
  Timer? _tick;
  Timer? _spawner;

  void start() {
    _tick?.cancel();
    _spawner?.cancel();
    emit(
      const BalloonState(balloons: [], score: 0, timeLeft: 60, running: true),
    );

    // Game tick ~60 FPS
    _tick = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!state.running) return;
      final updated = <Balloon>[];
      for (final b in state.balloons) {
        final next = Balloon(
          pos: Offset(b.pos.dx, b.pos.dy - b.vy),
          vy: b.vy,
          color: b.color,
          points: b.points,
          radius: b.radius,
        );
        if (next.pos.dy + next.radius > -20) {
          updated.add(next);
        }
      }
      emit(state.copyWith(balloons: updated));
    });

    // Spawn balloons
    _spawner = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (!state.running) return;
      final w = _viewportWidth; // updated by view via setter
      final x = _rand.nextDouble() * (w - 60) + 30;
      final speed = 1.8 + _rand.nextDouble() * 2.4;
      final radius = 22 + _rand.nextDouble() * 16;
      final color = [
        Colors.redAccent,
        Colors.blueAccent,
        Colors.amber,
        Colors.pinkAccent,
        Colors.teal,
        Colors.purpleAccent,
      ][_rand.nextInt(6)];
      final points = color == Colors.amber
          ? 25
          : (color == Colors.blueAccent ? 15 : 10);

      final newBalloon = Balloon(
        pos: Offset(x, _viewportHeight + radius + 10),
        vy: speed,
        color: color,
        points: points,
        radius: radius,
      );
      emit(state.copyWith(balloons: [...state.balloons, newBalloon]));
    });

    // Countdown timer
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!state.running) return t.cancel();
      final left = state.timeLeft - 1;
      if (left <= 0) {
        emit(state.copyWith(timeLeft: 0, running: false));
        _tick?.cancel();
        _spawner?.cancel();
        t.cancel();
      } else {
        emit(state.copyWith(timeLeft: left));
      }
    });
  }

  // Touch pop
  void popAt(Offset p) {
    if (!state.running) return;
    final list = [...state.balloons];
    for (int i = list.length - 1; i >= 0; i--) {
      final b = list[i];
      if ((b.pos - p).distance <= b.radius + 6) {
        list.removeAt(i);
        emit(state.copyWith(balloons: list, score: state.score + b.points));
        break;
      }
    }
  }

  // viewport gets updated from UI on layout
  double _viewportWidth = 360;
  double _viewportHeight = 640;
  void setViewport(Size size) {
    _viewportWidth = size.width;
    _viewportHeight = size.height;
  }

  @override
  Future<void> close() {
    _tick?.cancel();
    _spawner?.cancel();
    return super.close();
  }
}

class _BalloonGameView extends StatelessWidget {
  const _BalloonGameView();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        context.read<BalloonCubit>().setViewport(Size(c.maxWidth, c.maxHeight));
        return GestureDetector(
          onTapDown: (d) => context.read<BalloonCubit>().popAt(d.localPosition),
          child: Stack(
            children: [
              // Background gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF87CEEB), Color(0xFF98FB98)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Score + Timer bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: BlocBuilder<BalloonCubit, BalloonState>(
                    builder: (context, s) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _pill('🎯 Score', s.score.toString()),
                          _pill('⏱️ Time', '${s.timeLeft}s'),
                        ],
                      );
                    },
                  ),
                ),
              ),
              // Balloons layer
              BlocBuilder<BalloonCubit, BalloonState>(
                builder: (context, s) {
                  return CustomPaint(
                    painter: _BalloonPainter(s.balloons),
                    child: const SizedBox.expand(),
                  );
                },
              ),
              // Game Over overlay
              BlocBuilder<BalloonCubit, BalloonState>(
                builder: (context, s) {
                  if (s.running) return const SizedBox.shrink();
                  return Center(
                    child: Card(
                      elevation: 16,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '🎉 Game Over!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Final Score: ${context.read<BalloonCubit>().state.score}',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: () =>
                                  context.read<BalloonCubit>().start(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Play Again'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _pill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFF667EEA)),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _BalloonPainter extends CustomPainter {
  final List<Balloon> balloons;
  _BalloonPainter(this.balloons);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final b in balloons) {
      paint.color = b.color.withOpacity(.12);
      canvas.drawOval(
        Rect.fromCircle(
          center: b.pos,
          radius: b.radius,
        ).inflate(6).translate(0, -6),
        paint,
      );
      paint.color = b.color;
      canvas.drawCircle(b.pos, b.radius, paint);
      // string
      paint.color = Colors.black26;
      canvas.drawLine(
        b.pos + Offset(0, b.radius),
        b.pos + Offset(0, b.radius + 18),
        paint..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BalloonPainter oldDelegate) => true;
}

/// SWAP PUZZLE (simple 3x3)
class SwapPuzzlePage extends StatelessWidget {
  const SwapPuzzlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SwapPuzzleCubit()..newGame(3),
      child: Scaffold(
        appBar: AppBar(title: const Text('🧩 Jigsaw Puzzle')),
        body: const _SwapPuzzleView(),
      ),
    );
  }
}

class SwapPuzzleState {
  final int size; // e.g., 3 => 3x3
  final List<int> tiles; // 0..n-1 order; solved = index == value
  final int moves;
  final bool solved;
  const SwapPuzzleState({
    required this.size,
    required this.tiles,
    required this.moves,
    required this.solved,
  });

  SwapPuzzleState copyWith({
    int? size,
    List<int>? tiles,
    int? moves,
    bool? solved,
  }) => SwapPuzzleState(
    size: size ?? this.size,
    tiles: tiles ?? this.tiles,
    moves: moves ?? this.moves,
    solved: solved ?? this.solved,
  );
}

class SwapPuzzleCubit extends Cubit<SwapPuzzleState> {
  SwapPuzzleCubit()
    : super(const SwapPuzzleState(size: 0, tiles: [], moves: 0, solved: false));
  final _rand = Random();

  void newGame(int size) {
    final tiles = List<int>.generate(size * size, (i) => i);
    tiles.shuffle(_rand);
    emit(
      SwapPuzzleState(
        size: size,
        tiles: tiles,
        moves: 0,
        solved: _isSolved(tiles),
      ),
    );
  }

  void swap(int a, int b) {
    final list = [...state.tiles];
    final tmp = list[a];
    list[a] = list[b];
    list[b] = tmp;
    emit(
      state.copyWith(
        tiles: list,
        moves: state.moves + 1,
        solved: _isSolved(list),
      ),
    );
  }

  static bool _isSolved(List<int> t) {
    for (int i = 0; i < t.length; i++) {
      if (t[i] != i) return false;
    }
    return true;
  }
}

class _SwapPuzzleView extends StatelessWidget {
  const _SwapPuzzleView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwapPuzzleCubit, SwapPuzzleState>(
      builder: (context, s) {
        if (s.tiles.isEmpty)
          return const Center(child: CircularProgressIndicator());
        return Column(
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Chip(label: Text('🔄 Moves: ${s.moves}')),
                FilledButton(
                  onPressed: () =>
                      context.read<SwapPuzzleCubit>().newGame(s.size),
                  child: const Text('New Puzzle'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: s.size,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: s.tiles.length,
                      itemBuilder: (context, i) {
                        final value = s.tiles[i];
                        return _SwapTile(
                          value: value,
                          onSwapWith: (j) =>
                              context.read<SwapPuzzleCubit>().swap(i, j),
                          size: s.size,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            if (s.solved)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '🎉 Puzzle Completed in ${s.moves} moves!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SwapTile extends StatefulWidget {
  final int value;
  final void Function(int withIndex) onSwapWith;
  final int size;
  const _SwapTile({
    required this.value,
    required this.onSwapWith,
    required this.size,
  });

  @override
  State<_SwapTile> createState() => _SwapTileState();
}

class _SwapTileState extends State<_SwapTile> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    // Visual piece uses gradient and number; index not shown here, swap by tap twice
    return Builder(
      builder: (context) {
        return _TapSwap(
          onPair: (a, b) {
            widget.onSwapWith(b);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${widget.value + 1}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TapSwap extends StatefulWidget {
  final Widget child;
  final void Function(int a, int b) onPair;
  const _TapSwap({required this.child, required this.onPair});

  @override
  State<_TapSwap> createState() => _TapSwapState();
}

class _TapSwapState extends State<_TapSwap> {
  static int? _firstIndex;

  @override
  Widget build(BuildContext context) {
    // Use IndexedSemantics to know index from GridView build
    final element = context as Element;
    final parent = element
        .findAncestorRenderObjectOfType<RenderIndexedSemantics>();
    final index = parent?.index ?? 0;

    return GestureDetector(
      onTap: () {
        if (_firstIndex == null) {
          setState(() => _firstIndex = index);
        } else {
          final a = _firstIndex!;
          final b = index;
          _firstIndex = null;
          if (a != b) widget.onPair(a, b);
        }
      },
      child: AnimatedScale(
        scale: (_firstIndex == index) ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: widget.child,
      ),
    );
  }
}

/// COLORING BOARD (pixel coloring)
class ColoringPage extends StatelessWidget {
  const ColoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ColoringCubit()..init(16),
      child: Scaffold(
        appBar: AppBar(title: const Text('🎨 Coloring Board')),
        body: const _ColoringView(),
      ),
    );
  }
}

class ColoringState {
  final int n; // n x n grid
  final List<Color> cells;
  final Color current;
  ColoringState({required this.n, required this.cells, required this.current});

  ColoringState copyWith({int? n, List<Color>? cells, Color? current}) =>
      ColoringState(
        n: n ?? this.n,
        cells: cells ?? this.cells,
        current: current ?? this.current,
      );
}

class ColoringCubit extends Cubit<ColoringState> {
  ColoringCubit()
    : super(ColoringState(n: 0, cells: const [], current: Colors.redAccent));

  void init(int n) {
    emit(
      ColoringState(
        n: n,
        cells: List<Color>.filled(n * n, Colors.white),
        current: Colors.redAccent,
      ),
    );
  }

  void setColor(Color c) => emit(state.copyWith(current: c));

  void paintCell(int i) {
    final list = [...state.cells];
    list[i] = state.current;
    emit(state.copyWith(cells: list));
  }

  void clear() {
    emit(
      state.copyWith(
        cells: List<Color>.filled(state.n * state.n, Colors.white),
      ),
    );
  }
}

class _ColoringView extends StatelessWidget {
  const _ColoringView();

  @override
  Widget build(BuildContext context) {
    final palette = [
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.amber,
      Colors.yellow,
      Colors.green,
      Colors.teal,
      Colors.lightBlue,
      Colors.blueAccent,
      Colors.purpleAccent,
      Colors.pinkAccent,
      Colors.brown,
      Colors.black,
    ];

    return BlocBuilder<ColoringCubit, ColoringState>(
      builder: (context, s) {
        if (s.n == 0) return const Center(child: CircularProgressIndicator());
        return Column(
          children: [
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final c in palette)
                  GestureDetector(
                    onTap: () => context.read<ColoringCubit>().setColor(c),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: c == s.current ? Colors.black : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => context.read<ColoringCubit>().clear(),
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: s.n,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                    itemCount: s.n * s.n,
                    itemBuilder: (context, i) {
                      return GestureDetector(
                        onTap: () => context.read<ColoringCubit>().paintCell(i),
                        child: Container(color: s.cells[i]),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// MATH ADVENTURE (quiz)
class MathAdventurePage extends StatelessWidget {
  const MathAdventurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MathCubit()..start('easy'),
      child: Scaffold(
        appBar: AppBar(title: const Text('🔢 Math Adventure')),
        body: const _MathView(),
      ),
    );
  }
}

class MathState {
  final String difficulty;
  final String question;
  final int answer;
  final List<int> options;
  final int score;
  final int level;
  final int lives;
  final int solved;
  final bool gameOver;

  MathState({
    required this.difficulty,
    required this.question,
    required this.answer,
    required this.options,
    required this.score,
    required this.level,
    required this.lives,
    required this.solved,
    required this.gameOver,
  });

  MathState copyWith({
    String? difficulty,
    String? question,
    int? answer,
    List<int>? options,
    int? score,
    int? level,
    int? lives,
    int? solved,
    bool? gameOver,
  }) => MathState(
    difficulty: difficulty ?? this.difficulty,
    question: question ?? this.question,
    answer: answer ?? this.answer,
    options: options ?? this.options,
    score: score ?? this.score,
    level: level ?? this.level,
    lives: lives ?? this.lives,
    solved: solved ?? this.solved,
    gameOver: gameOver ?? this.gameOver,
  );
}

class MathCubit extends Cubit<MathState> {
  MathCubit()
    : super(
        MathState(
          difficulty: 'easy',
          question: '',
          answer: 0,
          options: const [],
          score: 0,
          level: 1,
          lives: 3,
          solved: 0,
          gameOver: false,
        ),
      );
  final _rand = Random();

  void start(String diff) {
    emit(
      MathState(
        difficulty: diff,
        question: '',
        answer: 0,
        options: const [],
        score: 0,
        level: 1,
        lives: 3,
        solved: 0,
        gameOver: false,
      ),
    );
    next();
  }

  void next() {
    if (state.gameOver) return;
    final d = state.difficulty;
    int range;
    List<String> ops;
    if (d == 'easy') {
      range = 10;
      ops = ['+', '-'];
    } else if (d == 'medium') {
      range = 50;
      ops = ['+', '-', '×'];
    } else {
      range = 100;
      ops = ['+', '-', '×', '÷'];
    }

    final op = ops[_rand.nextInt(ops.length)];
    int a, b, ans;
    String q;
    switch (op) {
      case '+':
        a = _rand.nextInt(range) + 1;
        b = _rand.nextInt(range) + 1;
        ans = a + b;
        q = '$a + $b = ?';
        break;
      case '-':
        a = _rand.nextInt(range) + 1;
        b = _rand.nextInt(a) + 1;
        ans = a - b;
        q = '$a - $b = ?';
        break;
      case '×':
        a = _rand.nextInt(12) + 1;
        b = _rand.nextInt(12) + 1;
        ans = a * b;
        q = '$a × $b = ?';
        break;
      case '÷':
        b = _rand.nextInt(12) + 1;
        ans = _rand.nextInt(12) + 1;
        a = b * ans;
        q = '$a ÷ $b = ?';
        break;
      default:
        a = 1;
        b = 1;
        ans = 2;
        q = '1 + 1 = ?';
    }

    final choices = <int>{ans};
    while (choices.length < 4) {
      final w = ans + _rand.nextInt(21) - 10;
      if (w > 0) choices.add(w);
    }
    final opts = choices.toList()..shuffle();

    emit(state.copyWith(question: q, answer: ans, options: opts));
  }

  void check(int pick) {
    if (state.gameOver) return;
    if (pick == state.answer) {
      var score = state.score + state.level * 10;
      var solved = state.solved + 1;
      var level = state.level;
      if (solved % 5 == 0) level++;
      emit(state.copyWith(score: score, solved: solved, level: level));
      next();
    } else {
      var lives = state.lives - 1;
      var over = lives <= 0;
      emit(state.copyWith(lives: lives, gameOver: over));
    }
  }
}

class _MathView extends StatelessWidget {
  const _MathView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MathCubit, MathState>(
      builder: (context, s) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                Chip(label: Text('🎯 Score: ${s.score}')),
                Chip(label: Text('🏆 Level: ${s.level}')),
                Chip(label: Text('❤️ Lives: ${s.lives}')),
                PopupMenuButton<String>(
                  onSelected: (d) => context.read<MathCubit>().start(d),
                  itemBuilder: (c) => const [
                    PopupMenuItem(value: 'easy', child: Text('Easy')),
                    PopupMenuItem(value: 'medium', child: Text('Medium')),
                    PopupMenuItem(value: 'hard', child: Text('Hard')),
                  ],
                  child: const Chip(label: Text('Change Difficulty')),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (s.gameOver)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🎮 Game Over!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Final Score: ${s.score}'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () =>
                            context.read<MathCubit>().start(s.difficulty),
                        child: const Text('Play Again'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      width: 340,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            s.question,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 2.7,
                                ),
                            itemCount: s.options.length,
                            itemBuilder: (context, i) {
                              final val = s.options[i];
                              return FilledButton(
                                onPressed: () =>
                                    context.read<MathCubit>().check(val),
                                child: Text(
                                  '$val',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text('Pick the correct answer'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// ALPHABET QUEST (learn + simple match)
class AlphabetQuestPage extends StatelessWidget {
  const AlphabetQuestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AlphabetCubit()..setMode('learn'),
      child: Scaffold(
        appBar: AppBar(title: const Text('🔤 Alphabet Quest')),
        body: const _AlphabetView(),
      ),
    );
  }
}

class AlphabetState {
  final String mode; // learn or match
  final int index; // current letter index
  final List<String> matchGrid; // for match mode
  final Set<int> matched; // matched pairs indices
  final List<int> flipped; // two at most
  final int score;

  const AlphabetState({
    required this.mode,
    required this.index,
    required this.matchGrid,
    required this.matched,
    required this.flipped,
    required this.score,
  });

  AlphabetState copyWith({
    String? mode,
    int? index,
    List<String>? matchGrid,
    Set<int>? matched,
    List<int>? flipped,
    int? score,
  }) => AlphabetState(
    mode: mode ?? this.mode,
    index: index ?? this.index,
    matchGrid: matchGrid ?? this.matchGrid,
    matched: matched ?? this.matched,
    flipped: flipped ?? this.flipped,
    score: score ?? this.score,
  );
}

class AlphabetCubit extends Cubit<AlphabetState> {
  AlphabetCubit()
    : super(
        const AlphabetState(
          mode: 'learn',
          index: 0,
          matchGrid: [],
          matched: {},
          flipped: [],
          score: 0,
        ),
      );

  final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
  final sounds = const {
    'A': 'Apple 🍎',
    'B': 'Ball ⚽',
    'C': 'Cat 🐱',
    'D': 'Dog 🐶',
    'E': 'Elephant 🐘',
    'F': 'Fish 🐠',
    'G': 'Giraffe 🦒',
    'H': 'House 🏠',
    'I': 'Ice cream 🍦',
    'J': 'Juice 🧃',
    'K': 'Kite 🪁',
    'L': 'Lion 🦁',
    'M': 'Mouse 🐭',
    'N': 'Nest 🪺',
    'O': 'Orange 🍊',
    'P': 'Penguin 🐧',
    'Q': 'Queen 👑',
    'R': 'Robot 🤖',
    'S': 'Sun ☀️',
    'T': 'Tiger 🐅',
    'U': 'Umbrella ☂️',
    'V': 'Violin 🎻',
    'W': 'Whale 🐳',
    'X': 'Xylophone 🎹',
    'Y': 'Yacht ⛵',
    'Z': 'Zebra 🦓',
  };

  void setMode(String mode) {
    if (mode == 'learn') {
      emit(state.copyWith(mode: 'learn', index: 0));
    } else {
      final gridLetters = letters.take(8).toList();
      final grid = [...gridLetters, ...gridLetters]..shuffle();
      emit(
        state.copyWith(
          mode: 'match',
          matchGrid: grid,
          matched: {},
          flipped: [],
          score: 0,
        ),
      );
    }
  }

  void nextLetter() {
    emit(state.copyWith(index: (state.index + 1) % letters.length));
  }

  void prevLetter() {
    emit(
      state.copyWith(
        index: (state.index - 1 + letters.length) % letters.length,
      ),
    );
  }

  void jumpTo(int i) {
    emit(state.copyWith(index: i));
  }

  void flip(int i) {
    if (state.mode != 'match') return;
    if (state.matched.contains(i)) return;
    if (state.flipped.contains(i)) return;
    final flipped = [...state.flipped, i];
    if (flipped.length < 2) {
      emit(state.copyWith(flipped: flipped));
      return;
    }
    final a = flipped[0];
    final b = flipped[1];
    final isMatch = state.matchGrid[a] == state.matchGrid[b];
    if (isMatch) {
      final matched = {...state.matched, a, b};
      emit(
        state.copyWith(matched: matched, flipped: [], score: state.score + 50),
      );
    } else {
      emit(state.copyWith(flipped: flipped));
      Future.delayed(const Duration(milliseconds: 700), () {
        emit(state.copyWith(flipped: []));
      });
    }
  }
}

class _AlphabetView extends StatelessWidget {
  const _AlphabetView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlphabetCubit, AlphabetState>(
      builder: (context, s) {
        final cubit = context.read<AlphabetCubit>();
        if (s.mode == 'learn') {
          final letter = cubit.letters[s.index];
          return Column(
            children: [
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton(
                    onPressed: () => cubit.setMode('learn'),
                    child: const Text('📚 Learn'),
                  ),
                  FilledButton(
                    onPressed: () => cubit.setMode('match'),
                    child: const Text('🎯 Match'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        width: 360,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              letter,
                              style: const TextStyle(
                                fontSize: 120,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              cubit.sounds[letter] ?? '',
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: cubit.prevLetter,
                                  icon: const Icon(
                                    Icons.chevron_left,
                                    size: 36,
                                  ),
                                ),
                                IconButton(
                                  onPressed: cubit.nextLetter,
                                  icon: const Icon(
                                    Icons.chevron_right,
                                    size: 36,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              alignment: WrapAlignment.center,
                              children: [
                                for (int i = 0; i < cubit.letters.length; i++)
                                  ElevatedButton(
                                    onPressed: () => cubit.jumpTo(i),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: i == s.index
                                          ? Colors.green
                                          : null,
                                    ),
                                    child: Text(cubit.letters[i]),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          // match mode
          return Column(
            children: [
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text('⭐ Score: ${s.score}')),
                  FilledButton(
                    onPressed: () => cubit.setMode('learn'),
                    child: const Text('Back to Learn'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: s.matchGrid.length,
                        itemBuilder: (context, i) {
                          final ch = s.matchGrid[i];
                          final faceUp =
                              s.flipped.contains(i) || s.matched.contains(i);
                          return GestureDetector(
                            onTap: () => cubit.flip(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: faceUp
                                    ? const Color(0xFFE3F2FD)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.deepPurple,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  faceUp ? ch : '❓',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

// =================== ALPHABET CAR RALLY ===================
class CarRallyLearnPage extends StatelessWidget {
  const CarRallyLearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CarRallyCubit()..start(),
      child: const Scaffold(
        appBar: GradientAppBar(title: '🏎️ Alphabet Car Rally'),
        body: _CarRallyView(),
      ),
    );
  }
}

class CarRallyState {
  final int lane; // 0,1,2
  final List<_Tile> tiles;
  final String target;
  final int score;
  final int lives;
  final bool running;

  const CarRallyState({
    required this.lane,
    required this.tiles,
    required this.target,
    required this.score,
    required this.lives,
    required this.running,
  });

  CarRallyState copyWith({
    int? lane,
    List<_Tile>? tiles,
    String? target,
    int? score,
    int? lives,
    bool? running,
  }) {
    return CarRallyState(
      lane: lane ?? this.lane,
      tiles: tiles ?? this.tiles,
      target: target ?? this.target,
      score: score ?? this.score,
      lives: lives ?? this.lives,
      running: running ?? this.running,
    );
  }
}

class _Tile {
  final int lane;
  double y;
  final String letter;
  _Tile({required this.lane, required this.y, required this.letter});
}

class CarRallyCubit extends Cubit<CarRallyState> {
  CarRallyCubit()
    : super(
        const CarRallyState(
          lane: 1,
          tiles: [],
          target: 'A',
          score: 0,
          lives: 3,
          running: false,
        ),
      );

  final _rand = Random();
  Timer? _tick;
  Timer? _spawn;
  double _height = 640;

  void setSize(Size s) => _height = s.height;

  void start() {
    _tick?.cancel();
    _spawn?.cancel();
    emit(
      const CarRallyState(
        lane: 1,
        tiles: [],
        target: 'A',
        score: 0,
        lives: 3,
        running: true,
      ),
    );

    _tick = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!state.running) return;
      final updated = <_Tile>[];
      var score = state.score;
      var lives = state.lives;
      var target = state.target;
      var running = state.running;

      for (final t in state.tiles) {
        final ny = t.y + 4;
        if (ny < _height - 90) {
          updated.add(_Tile(lane: t.lane, y: ny, letter: t.letter));
        } else {
          if (t.lane == state.lane) {
            if (t.letter == target) {
              score += 10;
              target = _nextLetter(target);
            } else {
              lives -= 1;
              if (lives <= 0) running = false;
            }
          }
        }
      }

      emit(
        state.copyWith(
          tiles: updated,
          score: score,
          lives: lives,
          target: target,
          running: running,
        ),
      );
    });

    _spawn = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!state.running) return;
      final lane = _rand.nextInt(3);
      final letter = _rand.nextBool()
          ? state.target
          : _randomWrong(state.target);
      emit(
        state.copyWith(
          tiles: [
            ...state.tiles,
            _Tile(lane: lane, y: -40, letter: letter),
          ],
        ),
      );
    });
  }

  void moveLeft() => emit(state.copyWith(lane: max(0, state.lane - 1)));
  void moveRight() => emit(state.copyWith(lane: min(2, state.lane + 1)));
  void restart() => start();

  static String _nextLetter(String l) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final i = letters.indexOf(l);
    return letters[(i + 1) % letters.length];
  }

  static String _randomWrong(String target) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    String pick;
    do {
      pick = letters[Random().nextInt(letters.length)];
    } while (pick == target);
    return pick;
  }

  @override
  Future<void> close() {
    _tick?.cancel();
    _spawn?.cancel();
    return super.close();
  }
}

class _CarRallyView extends StatelessWidget {
  const _CarRallyView();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        context.read<CarRallyCubit>().setSize(Size(c.maxWidth, c.maxHeight));
        final laneWidth = c.maxWidth / 3;

        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4FC3F7), Color(0xFF8E24AA)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned.fill(child: CustomPaint(painter: _RoadPainter())),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: BlocBuilder<CarRallyCubit, CarRallyState>(
                  builder: (context, s) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _hud('🎯 Target', s.target),
                        _hud('⭐ Score', '${s.score}'),
                        _hud('❤️ Lives', '${s.lives}'),
                      ],
                    );
                  },
                ),
              ),
            ),
            BlocBuilder<CarRallyCubit, CarRallyState>(
              builder: (context, s) {
                return Stack(
                  children: [
                    for (final t in s.tiles)
                      Positioned(
                        left: t.lane * laneWidth + laneWidth / 2 - 22,
                        top: t.y,
                        child: _tileWidget(t.letter),
                      ),
                  ],
                );
              },
            ),
            BlocBuilder<CarRallyCubit, CarRallyState>(
              builder: (context, s) {
                return Positioned(
                  bottom: 24,
                  left: s.lane * laneWidth + laneWidth / 2 - 24,
                  child: _carWidget(),
                );
              },
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _roundBtn(
                    Icons.arrow_left,
                    () => context.read<CarRallyCubit>().moveLeft(),
                  ),
                  _roundBtn(
                    Icons.arrow_right,
                    () => context.read<CarRallyCubit>().moveRight(),
                  ),
                ],
              ),
            ),
            BlocBuilder<CarRallyCubit, CarRallyState>(
              builder: (context, s) {
                if (s.running) return const SizedBox.shrink();
                return Center(
                  child: Card(
                    elevation: 16,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '🏁 Race Over!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Score: ${s.score}'),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () =>
                                context.read<CarRallyCubit>().restart(),
                            child: const Text('Restart'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _hud(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(40),
    ),
    child: Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _tileWidget(String letter) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.deepPurple, width: 2),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
      ],
    ),
    child: Center(
      child: Text(
        letter,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
  );

  Widget _carWidget() => Container(
    width: 48,
    height: 68,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFFF7043), Color(0xFFFFAB91)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
      ],
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: const Icon(Icons.directions_car, color: Colors.white, size: 36),
  );

  Widget _roundBtn(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFF6A1B9A)],
        ),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Icon(icon, color: Colors.white, size: 36),
    ),
  );
}

class _RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()..color = const Color(0xFF2E2E2E).withOpacity(.25);
    final lanePaint = Paint()
      ..color = Colors.white.withOpacity(.7)
      ..strokeWidth = 4;

    final roadRect = Rect.fromLTWH(16, 0, size.width - 32, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(roadRect, const Radius.circular(16)),
      road,
    );

    final laneWidth = roadRect.width / 3;
    for (int i = 1; i <= 2; i++) {
      final x = roadRect.left + i * laneWidth;
      double y = 12;
      while (y < size.height) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 16), lanePaint);
        y += 28;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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

class Item {
  double x;
  double y;
  String emoji;
  int points;
  bool isBomb;

  Item({
    required this.x,
    required this.y,
    required this.emoji,
    required this.points,
    required this.isBomb,
  });
}
