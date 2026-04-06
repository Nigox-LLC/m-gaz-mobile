import 'package:flutter/material.dart';
import '../../di.dart';
import '../utils/colors.dart';

void showSuccess(String message) {
  _showOverlayToast(
    message: message,
    backgroundColor: Colors.green.withValues(alpha: 0.9),
    icon: Icons.check_circle,
  );
}

void showErrors(String message) {
  _showOverlayToast(
    message: message,
    backgroundColor: Colors.red.withValues(alpha: 0.9),
    icon: Icons.error,
  );
}

void _showOverlayToast({
  required String message,
  required Color backgroundColor,
  required IconData icon,
}) {
  final overlay = mainKey.currentState?.overlay;
  if (overlay == null) return;

  final duration = Duration(
    milliseconds: (1000 + message.length * 50).clamp(1000, 4000),
  );

  final overlayEntry = OverlayEntry(
    builder:
        (_) => Positioned(
          top:
              MediaQueryData.fromView(
                WidgetsBinding.instance.window,
              ).padding.top +
              50,
          left: 20,
          right: 20,
          child: IgnorePointer(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
  );

  overlay.insert(overlayEntry);
  Future.delayed(duration, () => overlayEntry.remove());
}

extension MyException on Object {
  String get message {
    return "$this";
  }
}

void showCustomSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  final snackBar = SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Icon(Icons.error, color: AppColors.white),
        const SizedBox(width: 5),
        Expanded(child: Text(message)),
      ],
    ),
    duration: duration,
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.cF04438,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
  Color backgroundColor = Colors.red,
  Color textColor = Colors.white,
}) {
  if (message.trim().isEmpty) return;

  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder:
        (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 50,
          left: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message,
                style: TextStyle(color: textColor, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
  );

  overlay.insert(overlayEntry);
  Future.delayed(duration, () => overlayEntry.remove());
}
