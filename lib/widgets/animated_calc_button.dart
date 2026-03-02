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
    this.fontSize = 24,
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
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.1,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
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

    final textColor =
        widget.textColor ?? theme.colorScheme.onSurface;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onLongPress: widget.onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              if (widget.glow || _isPressed)
                BoxShadow(
                  color: baseColor.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(0, 6),
                blurRadius: 10,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              splashColor: theme.colorScheme.secondary.withOpacity(0.3),
              highlightColor: Colors.transparent,
              onTap: () {}, // handled above
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  child: Text(widget.label),
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