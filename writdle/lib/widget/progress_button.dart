import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressButton extends StatelessWidget {
  final double percent;
  final VoidCallback onTap;

  const ProgressButton({super.key, required this.percent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? CupertinoColors.systemGrey.withOpacity(0.3)
              : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 4,
                    backgroundColor: CupertinoColors.systemGrey4,
                    valueColor: AlwaysStoppedAnimation(
                      percent == 1.0
                          ? CupertinoColors.activeGreen
                          : CupertinoColors.systemPurple,
                    ),
                  ),
                ),
                Text(
                  '${(percent * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                percent == 1.0 ? '🎉 كل المهام تمت' : 'عرض التقدم اليومي',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
