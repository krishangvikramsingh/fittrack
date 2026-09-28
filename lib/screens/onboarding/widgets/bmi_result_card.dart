import 'package:flutter/material.dart';

import '../../../models/user_profile.dart';
import '../../../utils/constants.dart';

/// Shows a computed BMI value, its category chip, and a colored scale bar
/// indicating where that value falls - shown at the end of onboarding and
/// reused wherever a BMI needs displaying (e.g. edit profile).
class BmiResultCard extends StatelessWidget {
  final double bmi;
  final BmiCategory category;

  const BmiResultCard({super.key, required this.bmi, required this.category});

  static const Map<BmiCategory, Color> _categoryColors = {
    BmiCategory.underweight: Color(0xFF42A5F5),
    BmiCategory.normal: Color(0xFF43A047),
    BmiCategory.overweight: Color(0xFFFFA000),
    BmiCategory.obese: Color(0xFFE53935),
  };

  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[category]!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text('Your BMI', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              bmi.toStringAsFixed(1),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.sm),
            Chip(
              label: Text(category.label),
              backgroundColor: color.withValues(alpha: 0.15),
              labelStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
              side: BorderSide.none,
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: BmiCategory.values.map((c) {
                  return Expanded(
                    child: Container(
                      height: 10,
                      color: _categoryColors[c]!.withValues(alpha: c == category ? 1 : 0.3),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
