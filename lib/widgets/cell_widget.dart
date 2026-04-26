import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_logic.dart';
import '../theme/app_theme.dart';

class CellWidget extends StatefulWidget {
  final Player player;
  final bool isWinCell;
  final bool isAnimating;
  final bool isDisabled;
  final VoidCallback onTap;
  final AnimationController pulseController;

  const CellWidget({
    super.key,
    required this.player,
    required this.isWinCell,
    required this.isAnimating,
    required this.isDisabled,
    required this.onTap,
    required this.pulseController,
  });

  @override
  State<CellWidget> createState() => _CellWidgetState();
}

class _CellWidgetState extends State<CellWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  bool _isHovering = false;
  bool _justPlaced = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void didUpdateWidget(CellWidget old) {
    super.didUpdateWidget(old);
    if (old.player == Player.none && widget.player != Player.none) {
      setState(() => _justPlaced = true);
      HapticFeedback.lightImpact();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _justPlaced = false);
      });
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  Color get _borderColor {
    if (widget.isWinCell) {
      return widget.player == Player.x ? AppColors.xColor : AppColors.oColor;
    }
    if (widget.player == Player.x) return AppColors.xColor.withOpacity(0.7);
    if (widget.player == Player.o) return AppColors.oColor.withOpacity(0.7);
    if (_isHovering) return AppColors.borderHover;
    return AppColors.border;
  }

  Color get _bgColor {
    if (widget.isWinCell) {
      return widget.player == Player.x ? AppColors.xDark : AppColors.oDark;
    }
    if (_isHovering && widget.player == Player.none) return const Color(0xFF2A2A4E);
    return AppColors.cell;
  }

  List<BoxShadow> get _shadows {
    if (widget.isWinCell) {
      return widget.player == Player.x ? AppColors.xGlow : AppColors.oGlow;
    }
    if (widget.player == Player.x) return AppColors.xGlowSoft;
    if (widget.player == Player.o) return AppColors.oGlowSoft;
    return [];
  }

  String get _symbol => widget.player == Player.x ? 'X' : widget.player == Player.o ? 'O' : '';

  @override
  Widget build(BuildContext context) {
    Widget cell = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor, width: widget.isWinCell ? 1.5 : 1),
        boxShadow: _shadows,
      ),
      child: Stack(
        children: [
          // Shine overlay
          Positioned(
            top: 0, left: 0, right: 0,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withOpacity(0.04), Colors.transparent],
                ),
              ),
            ),
          ),

          // Symbol
          Center(
            child: _symbol.isEmpty
                ? const SizedBox()
                : _buildSymbol(),
          ),
        ],
      ),
    );

    // Win cell pulse animation
    if (widget.isWinCell) {
      cell = AnimatedBuilder(
        animation: widget.pulseController,
        builder: (_, child) => Transform.scale(
          scale: 1.0 + widget.pulseController.value * 0.06,
          child: child,
        ),
        child: cell,
      );
    }

    if (widget.player != Player.none || widget.isDisabled) {
      return cell;
    }

    return GestureDetector(
      onTapDown: (_) {
        _pressController.forward();
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedBuilder(
          animation: _pressController,
          builder: (_, child) => Transform.scale(
            scale: 1.0 - _pressController.value * 0.06,
            child: child,
          ),
          child: cell,
        ),
      ),
    );
  }

  Widget _buildSymbol() {
    final color = widget.player == Player.x ? AppColors.xColor : AppColors.oColor;
    final text = Text(
      _symbol,
      style: GoogleFonts.orbitron(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: color,
        shadows: [Shadow(color: color, blurRadius: 14)],
      ),
    );

    if (_justPlaced) {
      return text
          .animate()
          .scale(
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            duration: 400.ms,
            curve: Curves.elasticOut,
          )
          .rotate(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut)
          .fadeIn(duration: 200.ms);
    }

    return text;
  }
}
