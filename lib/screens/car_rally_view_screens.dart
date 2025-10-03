// =================== ALPHABET CAR RALLY ===================
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsplazone/app_bar.dart';

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
