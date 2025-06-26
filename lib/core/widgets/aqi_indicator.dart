import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_colors.dart';

class AqiIndicator extends StatefulWidget {
  final int aqiValue;
  final double size;
  final bool showLabel;

  const AqiIndicator({
    Key? key,
    required this.aqiValue,
    this.size = 120.0,
    this.showLabel = true,
  }) : super(key: key);

  @override
  State<AqiIndicator> createState() => _AqiIndicatorState();
}

class _AqiIndicatorState extends State<AqiIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    final progressValue = math.min(1.0, widget.aqiValue / 300);
    _progressAnimation = Tween<double>(begin: 0.0, end: progressValue)
        .animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getAqiColor() {
    if (widget.aqiValue <= 50) {
      return AppColors.aqiGood;
    } else if (widget.aqiValue <= 100) {
      return AppColors.aqiModerate;
    } else if (widget.aqiValue <= 150) {
      return AppColors.aqiUnhealthySensitive;
    } else if (widget.aqiValue <= 200) {
      return AppColors.aqiUnhealthy;
    } else if (widget.aqiValue <= 300) {
      return AppColors.aqiVeryUnhealthy;
    } else {
      return AppColors.aqiHazardous;
    }
  }

  String _getAqiCategory() {
    if (widget.aqiValue <= 50) {
      return 'BAIK';
    } else if (widget.aqiValue <= 100) {
      return 'SEDANG';
    } else if (widget.aqiValue <= 150) {
      return 'TIDAK SEHAT\nBAGI KELOMPOK SENSITIF';
    } else if (widget.aqiValue <= 200) {
      return 'TIDAK SEHAT';
    } else if (widget.aqiValue <= 300) {
      return 'SANGAT TIDAK SEHAT';
    } else {
      return 'BERBAHAYA';
    }
  }
  
  
  // Menentukan skala untuk indikator meter
  List<AqiScale> _getAqiScales() {
    return [
      AqiScale(max: 50, color: AppColors.aqiGood, label: '0-50'),
      AqiScale(max: 100, color: AppColors.aqiModerate, label: '51-100'),
      AqiScale(max: 150, color: AppColors.aqiUnhealthySensitive, label: '101-150'),
      AqiScale(max: 200, color: AppColors.aqiUnhealthy, label: '151-200'),
      AqiScale(max: 300, color: AppColors.aqiVeryUnhealthy, label: '201-300'),
      AqiScale(max: 500, color: AppColors.aqiHazardous, label: '301+'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final aqiColor = _getAqiColor();
    final scales = _getAqiScales();
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Container luar dengan efek shadow
                Container(
                  width: widget.size * 1.1,
                  height: widget.size * 1.1,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[300]!,
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                
                // Latar belakang sektor-sektor warna AQI
                SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CustomPaint(
                    painter: AqiBackgroundPainter(
                      scales: scales,
                      strokeWidth: widget.size * 0.08,
                    ),
                  ),
                ),
                
                // Arc progress animasi
                SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CustomPaint(
                    painter: ProgressArcPainter(
                      progress: _progressAnimation.value,
                      aqiValue: widget.aqiValue,
                      progressColor: aqiColor,
                      strokeWidth: widget.size * 0.1,
                    ),
                  ),
                ),
                
                // Inner content circle
                Container(
                  width: widget.size * 0.7,
                  height: widget.size * 0.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.grey[50]!,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[200]!,
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'AQI',
                        style: TextStyle(
                          fontSize: widget.size * 0.12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedCounter(
                        value: widget.aqiValue,
                        color: aqiColor,
                        fontSize: widget.size * 0.28,
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Indikator nilai dengan sedikit shadow
                if (_progressAnimation.value > 0.05)
                  Positioned(
                    top: widget.size * 0.5 - widget.size * 0.5 * math.sin(math.pi * 2 * _progressAnimation.value - math.pi / 2) - 12,
                    left: widget.size * 0.5 + widget.size * 0.5 * math.cos(math.pi * 2 * _progressAnimation.value - math.pi / 2) - 12,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: aqiColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: aqiColor.withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        
        if (widget.showLabel) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  aqiColor.withOpacity(0.9),
                  aqiColor,
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: aqiColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              _getAqiCategory(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}

// Widget untuk menampilkan animasi counter nilai AQI
class AnimatedCounter extends StatelessWidget {
  final int value;
  final Color color;
  final double fontSize;

  const AnimatedCounter({
    Key? key,
    required this.value,
    required this.color,
    required this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          '${value.toInt()}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        );
      },
    );
  }
}

// Painter untuk menggambar latar belakang dengan warna-warna kategori AQI
class AqiBackgroundPainter extends CustomPainter {
  final List<AqiScale> scales;
  final double strokeWidth;

  AqiBackgroundPainter({
    required this.scales,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    double startAngle = -math.pi / 2; // Mulai dari atas
    
    for (var scale in scales) {
      final sweepAngle = (scale.max / 300) * math.pi * 2;
      
      final paint = Paint()
        ..color = scale.color.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(AqiBackgroundPainter oldDelegate) {
    return oldDelegate.scales != scales ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}

// Painter untuk menggambar progress arc
class ProgressArcPainter extends CustomPainter {
  final double progress;
  final int aqiValue;
  final Color progressColor;
  final double strokeWidth;

  ProgressArcPainter({
    required this.progress,
    required this.aqiValue,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // Gambar progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    // Menggambar arc dari sudut -90 derajat (atas) berlawanan arah jarum jam
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Mulai dari atas
      progress * math.pi * 2, // Sudut berdasarkan progress
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(ProgressArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

// Kelas untuk menyimpan data skala AQI
class AqiScale {
  final int max;
  final Color color;
  final String label;

  AqiScale({
    required this.max,
    required this.color,
    required this.label,
  });
}