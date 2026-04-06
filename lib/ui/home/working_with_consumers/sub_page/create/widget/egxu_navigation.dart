import 'package:flutter/material.dart';

class EgxuNavigation extends StatelessWidget {
  final int step;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const EgxuNavigation({
    super.key,
    required this.step,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (step > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: onBack,
              child: const Text("⬅ Orqaga"),
            ),
          ),
        if (step > 0) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onNext,
            child: Text(step < 3 ? "Keyingi ➡" : "Yakunlash"),
          ),
        ),
      ],
    );
  }
}
