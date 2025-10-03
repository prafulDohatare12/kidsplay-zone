import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
