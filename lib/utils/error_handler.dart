import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/error_widget.dart';
import 'toast_service.dart';

class ErrorHandler {
  static void handleError(
    BuildContext? context,
    Object error, {
    String? customMessage,
    VoidCallback? onRetry,
    bool showToast = true,
  }) {
    final errorMessage = customMessage ?? _getErrorMessage(error);
    
    if (showToast) {
      ToastService().showError(errorMessage);
    }

    if (kDebugMode) {
      print('Error: $error');
      print('Stack trace: ${StackTrace.current}');
    }

    // Log error for production analytics if needed
    // Analytics.logError(error: error, stackTrace: stackTrace);
  }

  static String _getErrorMessage(Object error) {
    if (error is String) {
      return error;
    }
    
    // Handle specific error types
    if (error.toString().contains('network') || error.toString().contains('connection')) {
      return 'Network error. Please check your connection.';
    }
    
    if (error.toString().contains('permission')) {
      return 'Permission denied. Please check app permissions.';
    }
    
    // Generic error message
    return 'An error occurred. Please try again.';
  }

  static Widget buildErrorWidget({
    required String message,
    String? details,
    VoidCallback? onRetry,
    IconData? icon,
  }) {
    return CustomErrorWidget(
      message: message,
      details: details,
      onRetry: onRetry,
      icon: icon ?? Icons.error_outline,
    );
  }
}

