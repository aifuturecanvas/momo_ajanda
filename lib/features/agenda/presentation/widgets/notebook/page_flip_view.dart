import 'package:flutter/material.dart';

/// Sayfa çevirme efekti ile görünüm
class PageFlipView extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int initialPage;
  final ValueChanged<int>? onPageChanged;
  final PageController? controller;

  const PageFlipView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.initialPage = 0,
    this.onPageChanged,
    this.controller,
  });

  @override
  State<PageFlipView> createState() => _PageFlipViewState();
}

class _PageFlipViewState extends State<PageFlipView> {
  late PageController _controller;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? PageController(initialPage: widget.initialPage);
    _currentPage = widget.initialPage.toDouble();
    _controller.addListener(_onPageScroll);
  }

  void _onPageScroll() {
    setState(() {
      _currentPage = _controller.page ?? 0;
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: widget.itemCount,
      onPageChanged: widget.onPageChanged,
      itemBuilder: (context, index) {
        // Sayfa çevirme efekti için transform hesapla
        double difference = index - _currentPage;

        // -1 ile 1 arasında sınırla
        difference = difference.clamp(-1.0, 1.0);

        // Perspektif ve rotasyon
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspektif
          ..rotateY(difference * 0.5); // Y ekseni rotasyonu

        // Sayfa gölgesi
        final shadowOpacity = (difference.abs() * 0.3).clamp(0.0, 0.3);

        return Transform(
          transform: transform,
          alignment:
              difference >= 0 ? Alignment.centerLeft : Alignment.centerRight,
          child: Stack(
            children: [
              // Sayfa içeriği
              widget.itemBuilder(context, index),

              // Gölge efekti
              if (difference != 0)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: difference > 0
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        end: difference > 0
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        colors: [
                          Colors.black.withOpacity(shadowOpacity),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
