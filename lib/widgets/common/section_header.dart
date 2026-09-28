import 'package:flutter/material.dart';

import '../../utils/constants.dart';

/// A title (optionally with a trailing action, like "See all") used to
/// introduce a section of a scrollable screen.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
