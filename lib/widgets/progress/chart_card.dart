import 'package:flutter/material.dart';

import '../../utils/constants.dart';

/// A titled card wrapper shared by every chart on the Progress screen, so
/// each chart doesn't repeat the same title/padding/card boilerplate.
class ChartCard extends StatelessWidget {
  final String title;
  final Widget? action;
  final Widget child;

  const ChartCard({super.key, required this.title, required this.child, this.action});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                if (action != null) action!,
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}
