import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalcButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const CalcButton({super.key, required this.label, required this.onTap});

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    scale = Tween(begin: 1.0, end: 0.9).animate(controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        controller.forward();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapUp: (_) => controller.reverse(),
      child: ScaleTransition(
        scale: scale,
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          ),
          child: Center(
            child: Text(widget.label,
                style: const TextStyle(fontSize: 24)),
          ),
        ),
      ),
    );
  }
}