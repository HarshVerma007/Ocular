import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/app_constants.dart';

/// Simple time filter chips — dark style with green highlight.
/// Stateless to support external state resets from parent.
class TimeFilterChips extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onFilterChanged;

  const TimeFilterChips({
    super.key,
    required this.selectedIndex,
    this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
        itemCount: AppConstants.timeFilters.length,
        separatorBuilder: (_, i) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          final label = AppConstants.timeFilters[index];

          return GestureDetector(
            onTap: () {
              onFilterChanged?.call(index);
            },
            child: AnimatedContainer(
              duration: AppConstants.animFast,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.green : Colors.transparent,
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                border: Border.all(
                  color: isSelected ? AppTheme.green : AppTheme.border,
                  width: 1,
                ),
              ),
              child: Text(
                label,
                style: AppTheme.labelMedium.copyWith(
                  color: isSelected ? AppTheme.black : AppTheme.textDim,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
