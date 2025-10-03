import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
