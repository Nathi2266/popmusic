import 'package:flutter/material.dart';

class AppAnimations {
  // Page transition durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);

  // Standard curves
  static const Curve standardCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;

  // Fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = standardCurve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Slide in from right
  static Widget slideInRight({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = standardCurve,
    double offset = 100.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: offset, end: 0.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  // Slide in from bottom
  static Widget slideInUp({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = standardCurve,
    double offset = 100.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: offset, end: 0.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: child,
        );
      },
      child: child,
    );
  }

  // Scale in animation
  static Widget scaleIn({
    required Widget child,
    Duration duration = mediumDuration,
    Curve curve = smoothCurve,
    double begin = 0.8,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Staggered list animation
  static Widget staggeredList({
    required List<Widget> children,
    Duration staggerDuration = const Duration(milliseconds: 100),
    Duration itemDuration = mediumDuration,
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: itemDuration + (staggerDuration * index),
          curve: standardCurve,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset((1 - value) * 20, 0),
                child: child,
              ),
            );
          },
          child: child,
        );
      }).toList(),
    );
  }
}

// Custom page route with transitions
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SlideDirection direction;

  SlidePageRoute({
    required this.page,
    this.direction = SlideDirection.right,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AppAnimations.mediumDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offset = direction == SlideDirection.right
                ? const Offset(1.0, 0.0)
                : direction == SlideDirection.left
                    ? const Offset(-1.0, 0.0)
                    : direction == SlideDirection.up
                        ? const Offset(0.0, 1.0)
                        : const Offset(0.0, -1.0);

            return SlideTransition(
              position: Tween<Offset>(
                begin: offset,
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: AppAnimations.standardCurve,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

enum SlideDirection {
  right,
  left,
  up,
  down,
}

