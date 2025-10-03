import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsplazone/screens/swaptitle_screens.dart';
import 'package:kidsplazone/widegets/swap_tile.dart';

class SwapPuzzleView extends StatelessWidget {
  const SwapPuzzleView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwapPuzzleCubit, SwapPuzzleState>(
      builder: (context, state) {
        if (state.tiles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            const SizedBox(height: 12),
            _buildStatsAndControls(context, state),
            const SizedBox(height: 12),
            _buildPuzzleGrid(state),
            if (state.solved) _buildCompletionMessage(state),
          ],
        );
      },
    );
  }

  Widget _buildStatsAndControls(BuildContext context, SwapPuzzleState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Chip(label: Text('🔄 Moves: ${state.moves}')),
        FilledButton(
          onPressed: () => context.read<SwapPuzzleCubit>().newGame(state.size),
          child: const Text('New Puzzle'),
        ),
      ],
    );
  }

  Widget _buildPuzzleGrid(SwapPuzzleState state) {
    return Expanded(
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: state.size,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: state.tiles.length,
              itemBuilder: (context, index) {
                final value = state.tiles[index];
                return SwapTile(
                  value: value,
                  index: index,
                  onSwapWith: (otherIndex) =>
                      context.read<SwapPuzzleCubit>().swap(index, otherIndex),
                  size: state.size,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionMessage(SwapPuzzleState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        '🎉 Puzzle Completed in ${state.moves} moves!',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
