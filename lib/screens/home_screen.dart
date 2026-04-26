import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';
import '../models/game_logic.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _floatController;
  GameMode _selectedMode = GameMode.twoPlayer;
  Difficulty _selectedDiff = Difficulty.hard;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _startGame() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a1, a2) => GameScreen(
          mode: _selectedMode,
          difficulty: _selectedDiff,
        ),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
                  .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) {
              final t = _bgController.value;
              return CustomPaint(
                painter: _BackgroundPainter(t),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Floating X O symbols
                    AnimatedBuilder(
                      animation: _floatController,
                      builder: (_, __) {
                        final offset = (_floatController.value - 0.5) * 12;
                        return Transform.translate(
                          offset: Offset(0, offset),
                          child: _buildTitleSection(),
                        );
                      },
                    ),

                    const SizedBox(height: 48),

                    // Game Board Preview
                    _buildBoardPreview()
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 600.ms)
                        .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),

                    const SizedBox(height: 40),

                    // Mode Selection
                    _buildModeSelection()
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 500.ms)
                        .slideY(begin: 0.3, curve: Curves.easeOut),

                    const SizedBox(height: 24),

                    // Difficulty (only for AI mode)
                    if (_selectedMode == GameMode.vsAI)
                      _buildDifficultySelection()
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.2),

                    const SizedBox(height: 32),

                    // Start Button
                    _buildStartButton()
                        .animate()
                        .fadeIn(delay: 700.ms, duration: 500.ms)
                        .slideY(begin: 0.3, curve: Curves.easeOut),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => AppColors.titleGradient.createShader(bounds),
          child: Text(
            'TIC TAC TOE',
            style: GoogleFonts.orbitron(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 6,
              color: Colors.white,
            ),
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.3),
        const SizedBox(height: 8),
        Text(
          'CYBER  EDITION',
          style: GoogleFonts.orbitron(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            letterSpacing: 8,
            color: AppColors.muted,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildBoardPreview() {
    const preview = ['X', '', 'O', '', 'X', '', 'O', '', 'X'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: AppColors.xColor.withOpacity(0.08), blurRadius: 30),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 9,
        itemBuilder: (_, i) {
          final val = preview[i];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.cell,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: val == 'X'
                    ? AppColors.xColor.withOpacity(0.6)
                    : val == 'O'
                        ? AppColors.oColor.withOpacity(0.6)
                        : AppColors.border,
              ),
              boxShadow: val == 'X'
                  ? [BoxShadow(color: AppColors.xColor.withOpacity(0.2), blurRadius: 10)]
                  : val == 'O'
                      ? [BoxShadow(color: AppColors.oColor.withOpacity(0.2), blurRadius: 10)]
                      : [],
            ),
            child: Center(
              child: Text(
                val,
                style: GoogleFonts.orbitron(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: val == 'X' ? AppColors.xColor : AppColors.oColor,
                  shadows: val == 'X'
                      ? [Shadow(color: AppColors.xColor, blurRadius: 12)]
                      : val == 'O'
                          ? [Shadow(color: AppColors.oColor, blurRadius: 12)]
                          : [],
                ),
              ),
            ),
          )
              .animate(delay: Duration(milliseconds: 100 * i))
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut);
        },
      ),
    );
  }

  Widget _buildModeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'GAME MODE',
            style: GoogleFonts.orbitron(
              fontSize: 11,
              letterSpacing: 4,
              color: AppColors.muted,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _ModeCard(
                icon: '⚔️',
                label: '2 PLAYER',
                subtitle: 'Local Multiplayer',
                isSelected: _selectedMode == GameMode.twoPlayer,
                color: AppColors.xColor,
                onTap: () => setState(() => _selectedMode = GameMode.twoPlayer),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModeCard(
                icon: '🤖',
                label: 'VS AI',
                subtitle: 'Challenge CPU',
                isSelected: _selectedMode == GameMode.vsAI,
                color: AppColors.oColor,
                onTap: () => setState(() => _selectedMode = GameMode.vsAI),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'AI DIFFICULTY',
            style: GoogleFonts.orbitron(
              fontSize: 11,
              letterSpacing: 4,
              color: AppColors.muted,
            ),
          ),
        ),
        Row(
          children: Difficulty.values.map((d) {
            final isSelected = _selectedDiff == d;
            final colors = {
              Difficulty.easy: Colors.greenAccent,
              Difficulty.medium: Colors.orangeAccent,
              Difficulty.hard: AppColors.oColor,
            };
            final labels = {
              Difficulty.easy: 'EASY',
              Difficulty.medium: 'MEDIUM',
              Difficulty.hard: 'HARD',
            };
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDiff = d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? colors[d]!.withOpacity(0.15) : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? colors[d]! : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: colors[d]!.withOpacity(0.3), blurRadius: 12)]
                        : [],
                  ),
                  child: Text(
                    labels[d]!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: isSelected ? colors[d] : AppColors.muted,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _startGame,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppColors.xGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: AppColors.xColor.withOpacity(0.4), blurRadius: 20, spreadRadius: 2),
          ],
        ),
        child: Center(
          child: Text(
            'START GAME',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatefulWidget {
  final String icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward().then((_) => _controller.reverse());
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) => Transform.scale(
          scale: 1.0 - _controller.value * 0.04,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isSelected ? widget.color.withOpacity(0.12) : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected ? widget.color : AppColors.border,
              width: widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: widget.isSelected
                ? [BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: 16)]
                : [],
          ),
          child: Column(
            children: [
              Text(widget.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: widget.isSelected ? widget.color : AppColors.muted,
                ),
              ),
              Text(
                widget.subtitle,
                style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double t;
  _BackgroundPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paintX = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.04 + t * 0.02)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.2), 200, paintX);

    final paintO = Paint()
      ..color = const Color(0xFFFF4081).withOpacity(0.04 + (1 - t) * 0.02)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.8), 200, paintO);
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) => old.t != t;
}
