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
