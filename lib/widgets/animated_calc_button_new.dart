import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedCalcButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Color? textColor;
  final bool glow;
  final bool isOperator;
  final double fontSize;

  const AnimatedCalcButton({
    super.key,
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.color,
    this.textColor,
    this.glow = false,
    this.isOperator = false,
    this.fontSize = 20,
  });

  @override
  State<AnimatedCalcButton> createState() => _AnimatedCalcButtonState();
}

class _AnimatedCalcButtonState extends State<AnimatedCalcButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    super.initState();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = widget.color ??
        (widget.isOperator
            ? theme.colorScheme.primary
            : theme.colorScheme.surface);
    final textColor = widget.textColor ?? theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.all(1.5),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: baseColor,
          borderRadius: BorderRadius.circular(8),
          elevation: _isPressed ? 2 : 6,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onLongPress: widget.onLongPress,
            borderRadius: BorderRadius.circular(8),
            splashColor: theme.colorScheme.secondary.withValues(alpha: 0.5),
            highlightColor: Colors.transparent,
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
