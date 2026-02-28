import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Animated page indicator: active dot expands, inactive dots shrink. Smooth transition.
class AnimatedPageIndicator extends StatelessWidget {
  const AnimatedPageIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
    this.activeColor,
    this.inactiveColor,
    this.dotSize = 8,
    this.activeWidth = 28,
    this.spacing = 6,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeInOutCubic,
  });

  final int pageCount;
  final double currentPage;
  final Color? activeColor;
  final Color? inactiveColor;
  final double dotSize;
  final double activeWidth;
  final double spacing;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = activeColor ?? theme.colorScheme.primary;
    final inactive = inactiveColor ?? theme.colorScheme.primary.withValues(alpha: 0.25);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(pageCount, (index) {
        final distance = (currentPage - index).abs();
        final isActive = distance < 0.5;
        final progress = (1 - distance.clamp(0.0, 1.0)).toDouble();
        final width = lerpDouble(dotSize, activeWidth, progress) ?? dotSize;
        final color = Color.lerp(inactive, active, progress) ?? inactive;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: AnimatedContainer(
            duration: duration,
            curve: curve,
            width: width,
            height: dotSize,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(dotSize / 2),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: active.withValues(alpha: 0.4),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
