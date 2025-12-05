import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momo_ajanda/features/assistant/application/momo_providers.dart';
import 'package:momo_ajanda/features/assistant/models/momo_state.dart';

class MomoAvatar extends ConsumerStatefulWidget {
  final double size;
  final bool showMessage;
  final bool animate;

  const MomoAvatar({
    super.key,
    this.size = 120,
    this.showMessage = true,
    this.animate = true,
  });

  @override
  ConsumerState<MomoAvatar> createState() => _MomoAvatarState();
}

class _MomoAvatarState extends ConsumerState<MomoAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final momoState = ref.watch(momoStateProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -_bounceAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: _buildAvatar(momoState),
        ),

        if (widget.showMessage) ...[
          const SizedBox(height: 16),
          _MessageBubble(message: momoState.message),
        ],
      ],
    );
  }

  Widget _buildAvatar(MomoState state) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: state.moodGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: state.moodColor.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ana yüz
          Text(
            state.moodEmoji,
            style: TextStyle(fontSize: widget.size * 0.5),
          ),

          // Ruh haline göre ek dekorasyon
          if (state.mood == MomoMood.excited)
            Positioned(
              top: 5,
              right: 5,
              child: _buildSparkle(),
            ),

          if (state.mood == MomoMood.sleeping)
            Positioned(
              top: 10,
              right: 0,
              child: Text('💤', style: TextStyle(fontSize: widget.size * 0.2)),
            ),

          if (state.mood == MomoMood.proud)
            Positioned(
              top: -5,
              child: Text('👑', style: TextStyle(fontSize: widget.size * 0.25)),
            ),
        ],
      ),
    );
  }

  Widget _buildSparkle() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Text('✨', style: TextStyle(fontSize: widget.size * 0.2)),
        );
      },
    );
  }
}

/// Konuşma balonu widget'ı
class _MessageBubble extends StatefulWidget {
  final String message;

  const _MessageBubble({required this.message});

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void didUpdateWidget(_MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            widget.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
