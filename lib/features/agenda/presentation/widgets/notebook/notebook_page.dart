import 'package:flutter/material.dart';
import 'package:momo_ajanda/core/theme/app_colors.dart';

/// Defter sayfası widget'ı
class NotebookPage extends StatelessWidget {
  final DateTime date;
  final NotebookTheme theme;
  final List<Widget> children;
  final bool showTimeSlots;
  final ScrollController? scrollController;

  const NotebookPage({
    super.key,
    required this.date,
    this.theme = NotebookTheme.classic,
    this.children = const [],
    this.showTimeSlots = true,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.paperColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Çizgiler
          CustomPaint(
            painter: _NotebookLinesPainter(
              lineColor: theme.lineColor,
              marginColor: theme.marginColor,
            ),
            size: Size.infinite,
          ),

          // Sol kenar (cilt)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: theme.bindingColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
            ),
          ),

          // Spiral delikler
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: _SpiralHoles(color: theme.bindingColor),
          ),

          // İçerik
          Padding(
            padding: const EdgeInsets.only(left: 50, right: 16, top: 16),
            child: showTimeSlots
                ? _TimeSlotContent(
                    date: date,
                    theme: theme,
                    children: children,
                    scrollController: scrollController,
                  )
                : ListView(
                    controller: scrollController,
                    children: children,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Defter çizgileri painter
class _NotebookLinesPainter extends CustomPainter {
  final Color lineColor;
  final Color marginColor;

  _NotebookLinesPainter({
    required this.lineColor,
    required this.marginColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    final marginPaint = Paint()
      ..color = marginColor.withOpacity(0.5)
      ..strokeWidth = 2;

    // Yatay çizgiler (her 28 piksel)
    const lineHeight = 28.0;
    for (double y = lineHeight; y < size.height; y += lineHeight) {
      canvas.drawLine(
        Offset(50, y),
        Offset(size.width, y),
        linePaint,
      );
    }

    // Sol kenar boşluğu çizgisi
    canvas.drawLine(
      Offset(48, 0),
      Offset(48, size.height),
      marginPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Spiral delikler
class _SpiralHoles extends StatelessWidget {
  final Color color;

  const _SpiralHoles({required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final holeCount = (constraints.maxHeight / 40).floor();
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(holeCount, (index) {
            return Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: color.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

/// Saat dilimleri içeriği
class _TimeSlotContent extends StatelessWidget {
  final DateTime date;
  final NotebookTheme theme;
  final List<Widget> children;
  final ScrollController? scrollController;

  const _TimeSlotContent({
    required this.date,
    required this.theme,
    required this.children,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: 24, // 24 saat
      itemBuilder: (context, index) {
        final hour = index;
        final timeStr = '${hour.toString().padLeft(2, '0')}:00';

        // Bu saate ait widget'ları bul
        final hourWidgets = children.where((widget) {
          if (widget is TimeSlotEntry) {
            return widget.hour == hour;
          }
          return false;
        }).toList();

        return Container(
          height: 56, // 2 satır yüksekliği
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: theme.lineColor, width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saat göstergesi
              SizedBox(
                width: 50,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, right: 8),
                  child: Text(
                    timeStr,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textColor.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // İçerik alanı
              Expanded(
                child: hourWidgets.isEmpty
                    ? const SizedBox()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: hourWidgets,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Saat dilimine yerleştirilen giriş
class TimeSlotEntry extends StatelessWidget {
  final int hour;
  final String title;
  final Color? color;
  final VoidCallback? onTap;

  const TimeSlotEntry({
    super.key,
    required this.hour,
    required this.title,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: (color ?? Theme.of(context).primaryColor).withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: (color ?? Theme.of(context).primaryColor).withOpacity(0.5),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: color ?? Theme.of(context).primaryColor,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
