import 'package:flutter/material.dart';
import 'package:kidsplazone/widegets/swap_handler.dart';

class SwapTile extends StatelessWidget {
  final int value;
  final int index;
  final void Function(int withIndex) onSwapWith;
  final int size;

  const SwapTile({
    super.key,
    required this.value,
    required this.index,
    required this.onSwapWith,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return TapSwapHandler(
      index: index,
      onPair: (from, to) => onSwapWith(to),
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
            '${value + 1}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
