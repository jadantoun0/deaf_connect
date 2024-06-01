import 'package:flutter/material.dart';

class CustomToast {
  static OverlayEntry? overlayEntry;
  // to avoid showing two err msgs consecutively
  static bool isToastShowing = false;

  static void showToast(BuildContext context, String message,
      {bool success = false}) {
    if (isToastShowing) {
      return;
    }
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: success ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: success
                        ? const Icon(
                            Icons.check,
                            size: 20,
                            color: Colors.green,
                          )
                        : const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.red,
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    isToastShowing = true;
    Overlay.of(context).insert(overlayEntry!);
    if (overlayEntry != null) {
      // Hide the toast after a delay
      Future.delayed(const Duration(seconds: 3), () {
        if (overlayEntry != null && overlayEntry!.mounted) {
          overlayEntry?.remove();
          isToastShowing = false;
        }
      });
    }
  }
}
