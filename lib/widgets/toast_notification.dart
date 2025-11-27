import 'package:flutter/material.dart';
import '../utils/toast_service.dart';

class ToastData {
  final int id;
  final String message;
  final ToastType type;
  final IconData? icon;

  ToastData({
    required this.id,
    required this.message,
    required this.type,
    this.icon,
  });
}

class ToastNotification extends StatelessWidget {
  final ToastData toast;

  const ToastNotification({
    super.key,
    required this.toast,
  });

  Color _getBackgroundColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const Color(0xFF4CAF50);
      case ToastType.error:
        return const Color(0xFFF44336);
      case ToastType.warning:
        return const Color(0xFFFF9800);
      case ToastType.info:
        return const Color(0xFF2196F3);
    }
  }

  Color _getIconColor(ToastType type) {
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset((1 - value) * 400, 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _getBackgroundColor(toast.type),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (toast.icon != null)
              Icon(
                toast.icon,
                color: _getIconColor(toast.type),
                size: 24,
              ),
            if (toast.icon != null) const SizedBox(width: 12),
            Flexible(
              child: Text(
                toast.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ToastContainer extends StatelessWidget {
  final Widget child;

  const ToastContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final toastService = ToastService();
    return Stack(
      children: [
        child,
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          right: 16,
          left: 16,
          child: ListenableBuilder(
            listenable: toastService,
            builder: (context, _) {
              final toasts = toastService.toasts;
              if (toasts.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: toasts.map((toast) {
                  return ToastNotification(
                    toast: ToastData(
                      id: toast.id,
                      message: toast.message,
                      type: toast.type,
                      icon: toast.icon,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

