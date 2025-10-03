import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
