import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'theme.dart';

/// A ring filled to [value] (0..1), with the percentage in the middle.
class RingGauge extends StatelessWidget {
  const RingGauge({
    super.key,
    required this.value,
    required this.color,
    required this.label,
    this.detail,
    this.size = 96,
  });

  final double? value;
  final Color color;
  final String label;
  final String? detail;
  final double size;

  @override
  Widget build(BuildContext context) {
    final track = context.colors.surfaceContainerHigh;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(end: value ?? 0),
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeOutCubic,
          builder: (context, v, _) => SizedBox.square(
            dimension: size,
            child: CustomPaint(
              painter: _RingPainter(value: v, color: color, track: track),
              child: Center(
                child: Text(
                  value == null ? '–' : '${(v * 100).round()}%',
                  style: mono(
                    size: size * 0.2,
                    weight: FontWeight.w700,
                    color: context.colors.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: context.text.labelLarge),
        if (detail != null) ...[
          const SizedBox(height: 2),
          Text(
            detail!,
            style: mono(size: 11, color: context.colors.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.color, required this.track});
  final double value;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.09;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    // A gap at the bottom, like a speedometer: 270 degrees of sweep.
    const start = pi * 0.75;
    const sweep = pi * 1.5;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep, false, base..color = track);
    if (value > 0.001) {
      canvas.drawArc(
        rect,
        start,
        sweep * value.clamp(0, 1),
        false,
        base..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}

/// Lines over time, newest on the right. [series] values are 0..[maxY].
class HistoryChart extends StatelessWidget {
  const HistoryChart({
    super.key,
    required this.series,
    required this.colors,
    this.maxY,
    this.capacity = 60,
    this.minPoints = 12,
    this.height = 150,
    this.grid = true,
  });

  final List<List<double>> series;
  final List<Color> colors;

  /// Fixed top of the scale; null scales to the data.
  final double? maxY;

  /// The most points shown. Fewer than [minPoints] start from the left and
  /// leave room; between that and [capacity] they stretch to fill the width,
  /// and past it the oldest scroll off.
  final int capacity;
  final int minPoints;
  final double height;
  final bool grid;

  @override
  Widget build(BuildContext context) {
    final top =
        maxY ?? max(1.0, series.expand((s) => s).fold<double>(0, max) * 1.2);
    final outline = context.colors.outline.withValues(alpha: 0.5);
    final longest = series.fold<int>(0, (a, s) => max(a, s.length));
    final span = max(minPoints, min(longest, capacity)) - 1;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: span.toDouble(),
          minY: 0,
          maxY: top,
          clipData: const FlClipData.all(),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          gridData: FlGridData(
            show: grid,
            drawVerticalLine: false,
            horizontalInterval: top / 4,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: outline, strokeWidth: 1, dashArray: const [3, 4]),
          ),
          lineBarsData: [
            for (var i = 0; i < series.length; i++)
              LineChartBarData(
                spots: [
                  for (var j = 0; j < series[i].length; j++)
                    // Series of different lengths end together, on the right.
                    FlSpot(
                      (longest - series[i].length + j).toDouble(),
                      series[i][j],
                    ),
                ],
                isCurved: true,
                curveSmoothness: 0.25,
                preventCurveOverShooting: true,
                color: colors[i],
                barWidth: 2.2,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: colors[i].withValues(alpha: 0.10),
                ),
              ),
          ],
        ),
        duration: Duration.zero,
      ),
    );
  }
}

/// A horizontal bar filled to [value] (0..1).
class UsageBar extends StatelessWidget {
  const UsageBar({super.key, required this.value, required this.color});
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(99),
    child: SizedBox(
      height: 8,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: context.colors.surfaceContainerHigh),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0, 1),
            child: ColoredBox(color: color),
          ),
        ],
      ),
    ),
  );
}
