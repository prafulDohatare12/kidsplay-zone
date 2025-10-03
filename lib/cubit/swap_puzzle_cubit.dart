import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsplazone/models/swap_puzzle_state.dart';
import 'dart:math';

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
