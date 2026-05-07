import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/constants.dart';

/// An animated circular progress indicator with percentage display.
class CircularProgress extends StatefulWidget {
  final double percentage;
  final double size;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;
  final Widget? center;

  const CircularProgress({
    super.key,
    required this.percentage,
    this.size = 120,
    this.progressColor = AppColors.primary,
    this.backgroundColor = AppColors.surface,
    this.strokeWidth = 10,
    this.center,
  });

  @override
  State<CircularProgress> createState() => _CircularProgressState();
}

class _CircularProgressState extends State<CircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.percentage,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(CircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.percentage,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircularPainter(
                  percentage: _animation.value,
                  progressColor: widget.progressColor,
                  backgroundColor: widget.backgroundColor,
                  strokeWidth: widget.strokeWidth,
                ),
              ),
              widget.center ??
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_animation.value.toInt()}%',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.progressColor,
                        ),
                      ),
                      Text(
                        'Complete',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _CircularPainter extends CustomPainter {
  final double percentage;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularPainter({
    required this.percentage,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (percentage / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularPainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}
