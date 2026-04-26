import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ScoreCard extends StatelessWidget {
  final String label;
  final String name;
  final int score;
  final Color color;
  final bool isActive;
  final AnimationController pulseController;

  const ScoreCard({
    super.key,
    required this.label,
    required this.name,
    required this.score,
    required this.color,
    required this.isActive,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? color : AppColors.border,
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: isActive
            ? [BoxShadow(color: color.withOpacity(0.35), blurRadius: 16)]
            : [],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: isActive ? color : AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$score',
            style: GoogleFonts.orbitron(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: color,
              shadows: isActive ? [Shadow(color: color, blurRadius: 10)] : [],
            ),
          ),
          Text(
            name,
            style: GoogleFonts.rajdhani(
              fontSize: 11,
              color: AppColors.muted,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );

    if (isActive) {
      return AnimatedBuilder(
        animation: pulseController,
        builder: (_, child) => Transform.scale(
          scale: 1.0 + pulseController.value * 0.03,
          child: child,
        ),
        child: card,
      );
    }

    return card;
  }
}
