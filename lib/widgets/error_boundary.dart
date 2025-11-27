import 'package:flutter/material.dart';
import '../utils/error_handler.dart';
import '../widgets/error_widget.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;
  Object? error;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        setState(() {
          hasError = true;
          error = details.exception;
        });
        ErrorHandler.handleError(
          context,
          details.exception,
          showToast: false,
        );
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Scaffold(
        body: CustomErrorWidget(
          message: 'Something went wrong',
          details: error?.toString(),
          onRetry: () {
            setState(() {
              hasError = false;
              error = null;
            });
          },
        ),
      );
    }
    return widget.child;
  }
}

