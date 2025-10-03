import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
