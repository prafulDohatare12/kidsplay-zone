import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final int size;
  final List<int> tiles;
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
