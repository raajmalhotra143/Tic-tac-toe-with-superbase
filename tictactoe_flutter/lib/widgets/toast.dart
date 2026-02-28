// Toast widget — mirrors React Toast.jsx
import 'package:flutter/material.dart';

class ToastOverlay extends StatelessWidget {
  final String message;
  const ToastOverlay({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Positioned(
      bottom: 40,
      left: 24,
      right: 24,
      child: AnimatedOpacity(
        opacity: message.isNotEmpty ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: const Color(0xFF3B3B5C)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// Helper mixin-like controller
class ToastController {
  String _message = '';
  void Function(void Function())? _setState;

  String get message => _message;

  void bind(void Function(void Function()) setState) {
    _setState = setState;
  }

  void show(String msg) {
    _setState?.call(() => _message = msg);
    Future.delayed(const Duration(milliseconds: 3000), () {
      _setState?.call(() => _message = '');
    });
  }
}
