import 'package:flutter/material.dart';

class TapSwapHandler extends StatefulWidget {
  final Widget child;
  final void Function(int a, int b) onPair;
  final int index;

  const TapSwapHandler({
    super.key,
    required this.child,
    required this.onPair,
    required this.index,
  });

  @override
  State<TapSwapHandler> createState() => _TapSwapHandlerState();
}

class _TapSwapHandlerState extends State<TapSwapHandler> {
  static int? _firstIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedScale(
        scale: (_firstIndex == widget.index) ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: widget.child,
      ),
    );
  }

  void _handleTap() {
    if (_firstIndex == null) {
      setState(() => _firstIndex = widget.index);
    } else {
      final a = _firstIndex!;
      final b = widget.index;
      _firstIndex = null;
      if (a != b) widget.onPair(a, b);
    }
  }
}
