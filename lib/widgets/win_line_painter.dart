import 'package:flutter/material.dart';

class WinLinePainter extends CustomPainter {
  final List<int> winLine;
  final Color color;
  final double progress;

  WinLinePainter({
    required this.winLine,
    required this.color,
    this.progress = 1.0,
  });

  // Cell centers in a 3x3 grid, relative to container
  // Grid has 14px padding, 10px gaps, equal cells
  Offset _getCellCenter(int index, Size size) {
    final padding = 14.0;
    final gap = 10.0;
    final cellSize = (size.width - padding * 2 - gap * 2) / 3;

    final row = index ~/ 3;
    final col = index % 3;

    final x = padding + col * (cellSize + gap) + cellSize / 2;
    final y = padding + row * (cellSize + gap) + cellSize / 2;

    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final start = _getCellCenter(winLine.first, size);
    final end = _getCellCenter(winLine.last, size);

    final current = Offset.lerp(start, end, progress)!;

    final paint = Paint()
      ..color = color.withOpacity(0.85)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawLine(start, current, glowPaint);
    canvas.drawLine(start, current, paint);
  }

  @override
  bool shouldRepaint(WinLinePainter old) =>
      old.progress != progress || old.winLine != winLine;
}

class AnimatedWinLine extends StatefulWidget {
  final List<int> winLine;
  final Color color;

  const AnimatedWinLine({super.key, required this.winLine, required this.color});

  @override
  State<AnimatedWinLine> createState() => _AnimatedWinLineState();
}

class _AnimatedWinLineState extends State<AnimatedWinLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        painter: WinLinePainter(
          winLine: widget.winLine,
          color: widget.color,
          progress: _anim.value,
        ),
      ),
    );
  }
}
