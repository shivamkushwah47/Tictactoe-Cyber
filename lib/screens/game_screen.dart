import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_logic.dart';
import '../theme/app_theme.dart';
import '../widgets/cell_widget.dart';
import '../widgets/score_card.dart';
import '../widgets/win_line_painter.dart';
import 'home_screen.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  final Difficulty difficulty;

  const GameScreen({super.key, required this.mode, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameState _state;
  late AnimationController _bgController;
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late ConfettiController _confettiController;
  late Animation<double> _shakeAnim;

  bool _aiThinking = false;
  Timer? _aiTimer;
  List<int> _animatingCells = [];
  bool _showWinOverlay = false;

  @override
  void initState() {
    super.initState();
    _state = GameState(mode: widget.mode, difficulty: widget.difficulty);

    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);

    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);

    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _bgController.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    _aiTimer?.cancel();
    super.dispose();
  }

  void _handleTap(int index) {
    if (_state.board[index] != Player.none ||
        _state.result != GameResult.ongoing ||
        _aiThinking) return;
    if (_state.mode == GameMode.vsAI && _state.currentPlayer == Player.o) return;

    _placeMove(index);
  }

  void _placeMove(int index) {
    final newBoard = List<Player>.from(_state.board);
    newBoard[index] = _state.currentPlayer;

    setState(() {
      _animatingCells = [index];
      _state = _state.copyWith(board: newBoard);
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      final result = GameLogic.checkResult(newBoard);
      final winLine = GameLogic.getWinLine(newBoard);

      setState(() {
        _animatingCells = [];
        if (result == GameResult.xWins) {
          _state = _state.copyWith(
            result: result,
            winLine: winLine,
            xScore: _state.xScore + 1,
            history: [..._state.history, 'X'],
          );
          _triggerWin(Player.x);
        } else if (result == GameResult.oWins) {
          _state = _state.copyWith(
            result: result,
            winLine: winLine,
            oScore: _state.oScore + 1,
            history: [..._state.history, 'O'],
          );
          _triggerWin(Player.o);
        } else if (result == GameResult.draw) {
          _state = _state.copyWith(
            result: result,
            draws: _state.draws + 1,
            history: [..._state.history, 'D'],
          );
          _triggerDraw();
        } else {
          _state = _state.copyWith(
            currentPlayer: _state.currentPlayer == Player.x ? Player.o : Player.x,
          );
          if (_state.mode == GameMode.vsAI && _state.currentPlayer == Player.o) {
            _scheduleAiMove();
          }
        }
      });
    });
  }

  void _scheduleAiMove() {
    setState(() => _aiThinking = true);
    final delay = 600 + Random().nextInt(600);
    _aiTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      final move = GameLogic.getAIMove(_state.board, _state.difficulty);
      setState(() => _aiThinking = false);
      if (move != null) _placeMove(move);
    });
  }

  void _triggerWin(Player player) {
    _confettiController.play();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showWinOverlay = true);
    });
  }

  void _triggerDraw() {
    _shakeController.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showWinOverlay = true);
    });
  }

  void _newRound() {
    _aiTimer?.cancel();
    _confettiController.stop();
    setState(() {
      _showWinOverlay = false;
      _aiThinking = false;
      _state = _state.copyWith(
        board: List.filled(9, Player.none),
        currentPlayer: Player.x,
        result: GameResult.ongoing,
        clearWinLine: true,
      );
    });
  }

  void _resetAll() {
    _aiTimer?.cancel();
    _confettiController.stop();
    setState(() {
      _showWinOverlay = false;
      _aiThinking = false;
      _state = GameState(mode: widget.mode, difficulty: widget.difficulty);
    });
  }

  void _goHome() {
    _aiTimer?.cancel();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  String get _statusText {
    if (_state.result == GameResult.xWins) return '🏆 X JEET GAYA!';
    if (_state.result == GameResult.oWins) {
      return _state.mode == GameMode.vsAI ? '🤖 AI JEET GAYA!' : '🏆 O JEET GAYA!';
    }
    if (_state.result == GameResult.draw) return '🤝 BARABAR!';
    if (_aiThinking) return '🤖 AI SOch Raha Hai...';
    return _state.currentPlayer == Player.x ? '⚡ X KA TURN' : '⚡ O KA TURN';
  }

  Color get _statusColor {
    if (_state.result == GameResult.xWins || _state.currentPlayer == Player.x) return AppColors.xColor;
    if (_state.result == GameResult.oWins || _state.currentPlayer == Player.o) return AppColors.oColor;
    if (_state.result == GameResult.draw) return AppColors.gold;
    return AppColors.muted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated BG
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) => CustomPaint(
              painter: _GameBgPainter(_bgController.value),
              size: MediaQuery.of(context).size,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                _buildScoreboard(),
                _buildStatus(),
                const SizedBox(height: 8),
                _buildGrid(),
                const SizedBox(height: 16),
                _buildHistoryDots(),
                const Spacer(),
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.xColor, AppColors.oColor, AppColors.gold,
                Colors.greenAccent, Colors.purpleAccent,
              ],
              numberOfParticles: 40,
              maxBlastForce: 30,
              minBlastForce: 10,
              gravity: 0.3,
            ),
          ),

          // Win Overlay
          if (_showWinOverlay) _buildWinOverlay(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: _goHome,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 16),
            ),
          ),
          const Spacer(),
          ShaderMask(
            shaderCallback: (bounds) => AppColors.titleGradient.createShader(bounds),
            child: Text(
              'TIC TAC TOE',
              style: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _state.mode == GameMode.vsAI
                  ? AppColors.oColor.withOpacity(0.15)
                  : AppColors.xColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _state.mode == GameMode.vsAI ? AppColors.oColor : AppColors.xColor,
                width: 0.8,
              ),
            ),
            child: Text(
              _state.mode == GameMode.vsAI ? '🤖 AI' : '⚔️ 2P',
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _state.mode == GameMode.vsAI ? AppColors.oColor : AppColors.xColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ScoreCard(
              label: 'PLAYER X',
              name: 'You',
              score: _state.xScore,
              color: AppColors.xColor,
              isActive: _state.currentPlayer == Player.x && _state.result == GameResult.ongoing,
              pulseController: _pulseController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Text(
                  'DRAW',
                  style: GoogleFonts.orbitron(
                    fontSize: 9, letterSpacing: 2, color: AppColors.muted),
                ),
                Text(
                  '${_state.draws}',
                  style: GoogleFonts.orbitron(
                    fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.gold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ScoreCard(
              label: _state.mode == GameMode.vsAI ? 'AI' : 'PLAYER O',
              name: _state.mode == GameMode.vsAI ? '🤖 CPU' : 'Friend',
              score: _state.oScore,
              color: AppColors.oColor,
              isActive: _state.currentPlayer == Player.o && _state.result == GameResult.ongoing,
              pulseController: _pulseController,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2);
  }

  Widget _buildStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                .animate(anim),
            child: child,
          ),
        ),
        child: _aiThinking
            ? _buildAIThinkingIndicator()
            : Text(
                _statusText,
                key: ValueKey(_statusText),
                style: GoogleFonts.rajdhani(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  color: _statusColor,
                  shadows: [Shadow(color: _statusColor.withOpacity(0.5), blurRadius: 10)],
                ),
              ),
      ),
    );
  }

  Widget _buildAIThinkingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '🤖 AI SOch Raha Hai',
          style: GoogleFonts.rajdhani(
            fontSize: 16, fontWeight: FontWeight.w700,
            letterSpacing: 2, color: AppColors.oColor,
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(3, (i) => Container(
          margin: const EdgeInsets.only(right: 4),
          child: Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              color: AppColors.oColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ).animate(delay: Duration(milliseconds: i * 200))
              .then()
              .moveY(begin: 0, end: -6, duration: 400.ms, curve: Curves.easeOut)
              .then()
              .moveY(begin: -6, end: 0, duration: 400.ms, curve: Curves.easeIn),
        )),
      ],
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
        animation: _shakeAnim,
        builder: (_, child) => Transform.translate(
          offset: Offset(_shakeAnim.value, 0),
          child: child,
        ),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(color: AppColors.xColor.withOpacity(0.06), blurRadius: 30),
                  BoxShadow(color: AppColors.oColor.withOpacity(0.06), blurRadius: 30),
                ],
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 9,
                itemBuilder: (_, i) => CellWidget(
                  player: _state.board[i],
                  isWinCell: _state.winLine?.contains(i) ?? false,
                  isAnimating: _animatingCells.contains(i),
                  isDisabled: _state.result != GameResult.ongoing || _aiThinking ||
                      (_state.mode == GameMode.vsAI && _state.currentPlayer == Player.o),
                  onTap: () => _handleTap(i),
                  pulseController: _pulseController,
                ),
              ),
            ),

            // Win line overlay
            if (_state.winLine != null)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CustomPaint(
                    painter: WinLinePainter(
                      winLine: _state.winLine!,
                      color: _state.result == GameResult.xWins
                          ? AppColors.xColor
                          : AppColors.oColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().scale(begin: const Offset(0.85, 0.85), duration: 600.ms, curve: Curves.elasticOut);
  }

  Widget _buildHistoryDots() {
    if (_state.history.isEmpty) return const SizedBox(height: 20);
    return SizedBox(
      height: 20,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 4,
        children: _state.history.take(20).map((h) {
          final color = h == 'X' ? AppColors.xColor : h == 'O' ? AppColors.oColor : AppColors.gold;
          return Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 4)],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: '↺  NEW ROUND',
              gradient: AppColors.xGradient,
              glowColor: AppColors.xColor,
              onTap: _newRound,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              label: '⟳  RESET ALL',
              gradient: AppColors.oGradient,
              glowColor: AppColors.oColor,
              onTap: _resetAll,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3);
  }

  Widget _buildWinOverlay() {
    final isX = _state.result == GameResult.xWins;
    final isDraw = _state.result == GameResult.draw;
    final isAI = _state.mode == GameMode.vsAI && _state.result == GameResult.oWins;

    final color = isDraw ? AppColors.gold : isX ? AppColors.xColor : AppColors.oColor;
    final emoji = isDraw ? '🤝' : isAI ? '🤖' : '🏆';
    final title = isDraw
        ? 'DRAW!'
        : isX
            ? 'X JEET GAYA!'
            : isAI
                ? 'AI JEET GAYA!'
                : 'O JEET GAYA!';
    final subtitle = isDraw ? 'Barabar! Koi nahi jita.' : 'Congratulations!';

    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: color.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.3), blurRadius: 40, spreadRadius: 4),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 60))
                    .animate()
                    .scale(begin: const Offset(0, 0), curve: Curves.elasticOut, duration: 600.ms)
                    .then()
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(begin: 0, end: -8, duration: 700.ms),

                const SizedBox(height: 12),

                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ).createShader(bounds),
                  child: Text(
                    title,
                    style: GoogleFonts.orbitron(
                      fontSize: 22, fontWeight: FontWeight.w900,
                      letterSpacing: 3, color: Colors.white,
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14, letterSpacing: 2, color: AppColors.muted),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'NEXT ROUND',
                        gradient: AppColors.xGradient,
                        glowColor: AppColors.xColor,
                        onTap: _newRound,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _SmallButton(
                      label: 'HOME',
                      onTap: _goHome,
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final LinearGradient gradient;
  final Color glowColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.gradient,
    required this.glowColor,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapUp: (_) {
        _c.reverse();
        widget.onTap();
      },
      onTapCancel: () => _c.reverse(),
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, child) => Transform.scale(
          scale: 1.0 - _c.value * 0.04,
          child: child,
        ),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(color: widget.glowColor.withOpacity(0.4), blurRadius: 16, spreadRadius: 1),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.orbitron(
                fontSize: 11, fontWeight: FontWeight.w700,
                letterSpacing: 2, color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SmallButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60, height: 52,
        decoration: BoxDecoration(
          color: AppColors.cell,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 9, fontWeight: FontWeight.w700,
              letterSpacing: 1, color: AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

class _GameBgPainter extends CustomPainter {
  final double t;
  _GameBgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.05 + t * 0.02)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 180, p1);

    final p2 = Paint()
      ..color = const Color(0xFFFF4081).withOpacity(0.05 + (1 - t) * 0.02)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.7), 180, p2);
  }

  @override
  bool shouldRepaint(_GameBgPainter old) => old.t != t;
}
