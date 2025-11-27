import 'package:flutter/material.dart';

enum ToastType {
  success,
  error,
  warning,
  info,
}

class ToastMessage {
  final int id;
  final String message;
  final ToastType type;
  final Duration duration;
  final IconData? icon;

  ToastMessage({
    required this.id,
    required this.message,
    required this.type,
    required this.duration,
    this.icon,
  });
}

class ToastService extends ChangeNotifier {
  static final ToastService _instance = ToastService._internal();
  factory ToastService() => _instance;
  ToastService._internal();

  final List<ToastMessage> _toasts = [];
  List<ToastMessage> get toasts => List.unmodifiable(_toasts);

  void show({
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    final toast = ToastMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      message: message,
      type: type,
      duration: duration,
      icon: icon,
    );

    _toasts.add(toast);
    notifyListeners();

    // Auto-remove after duration
    Future.delayed(duration, () {
      remove(toast.id);
    });
  }

  void showSuccess(String message, {Duration? duration, IconData? icon}) {
    show(
      message: message,
      type: ToastType.success,
      duration: duration ?? const Duration(seconds: 3),
      icon: icon ?? Icons.check_circle,
    );
  }

  void showError(String message, {Duration? duration, IconData? icon}) {
    show(
      message: message,
      type: ToastType.error,
      duration: duration ?? const Duration(seconds: 4),
      icon: icon ?? Icons.error,
    );
  }

  void showWarning(String message, {Duration? duration, IconData? icon}) {
    show(
      message: message,
      type: ToastType.warning,
      duration: duration ?? const Duration(seconds: 3),
      icon: icon ?? Icons.warning,
    );
  }

  void showInfo(String message, {Duration? duration, IconData? icon}) {
    show(
      message: message,
      type: ToastType.info,
      duration: duration ?? const Duration(seconds: 3),
      icon: icon ?? Icons.info,
    );
  }

  void remove(int id) {
    _toasts.removeWhere((toast) => toast.id == id);
    notifyListeners();
  }

  void clear() {
    _toasts.clear();
    notifyListeners();
  }
}

