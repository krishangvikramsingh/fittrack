import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../utils/date_utils.dart';

/// Greets the user by name (time-of-day appropriate) and shows today's date.
class DashboardHeader extends StatelessWidget {
  final String name;

  const DashboardHeader({super.key, required this.name});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_greeting${name.isNotEmpty ? ', $name' : ''}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            AppDateUtils.dayMonthYearFormat.format(DateTime.now()),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
