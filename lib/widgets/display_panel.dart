import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';

class DisplayPanel extends StatefulWidget {
  final String expression;
  final String result;
  final VoidCallback? onDelete;
  final Function(String)? onExpressionChanged;

  const DisplayPanel({
    super.key,
    required this.expression,
    required this.result,
    this.onDelete,
    this.onExpressionChanged,
  });

  @override
  State<DisplayPanel> createState() => _DisplayPanelState();
}

class _DisplayPanelState extends State<DisplayPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DisplayPanel oldWidget) {
    if (oldWidget.result != widget.result) {
      _controller.forward(from: 0);
      HapticFeedback.selectionClick();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    });

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null &&
            details.primaryVelocity! > AppConstants.swipeDeleteVelocity &&
            widget.onDelete != null) {
          widget.onDelete!();
          HapticFeedback.lightImpact();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            /// Expression Scrollable Row
            SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Text(
                widget.expression,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// Animated Result
            FadeTransition(
              opacity: _fadeAnimation,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  widget.result,
                  key: ValueKey(widget.result),
                  textAlign: TextAlign.right,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: _autoFontSize(widget.result),
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _autoFontSize(String text) {
    if (text.length < 8) return 48;
    if (text.length < 14) return 36;
    if (text.length < 20) return 28;
    return 22;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}