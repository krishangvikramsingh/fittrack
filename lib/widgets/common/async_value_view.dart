import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/constants.dart';

/// Renders an [AsyncValue]'s three states (loading/error/data) consistently
/// everywhere in the app, so screens don't each hand-roll their own
/// spinner/error UI.
class AsyncValueView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) data;
  final Widget Function(BuildContext context)? loading;
  final Widget Function(BuildContext context, Object error)? error;

  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (d) => data(context, d),
      loading: () => loading?.call(context) ??
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(),
            ),
          ),
      error: (err, _) => error?.call(context, err) ?? _DefaultError(error: err),
    );
  }
}

class _DefaultError extends StatelessWidget {
  final Object error;
  const _DefaultError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Something went wrong.\n$error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
