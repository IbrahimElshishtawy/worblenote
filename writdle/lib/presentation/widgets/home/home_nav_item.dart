import 'package:flutter/material.dart';
import 'package:writdle/presentation/widgets/home/home_tab_item.dart';

class HomeNavItem extends StatelessWidget {
  const HomeNavItem({
    super.key,
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final HomeTabItem tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? scheme.primary.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 220),
                scale: isSelected ? 1.05 : 1,
                child: Icon(
                  tab.icon,
                  color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: theme.textTheme.labelMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                ),
                child: Text(tab.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
