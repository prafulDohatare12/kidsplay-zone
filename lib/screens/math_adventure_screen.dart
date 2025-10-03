import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
