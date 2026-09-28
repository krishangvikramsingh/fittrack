import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/weight_providers.dart';
import '../../../utils/constants.dart';
import '../../../utils/validators.dart';
import '../../../widgets/common/primary_button.dart';

/// Bottom sheet for logging a new weight entry, opened from the Progress
/// screen's weight-trend chart card.
class AddWeightSheet extends ConsumerStatefulWidget {
  const AddWeightSheet({super.key});

  @override
  ConsumerState<AddWeightSheet> createState() => _AddWeightSheetState();
}

class _AddWeightSheetState extends ConsumerState<AddWeightSheet> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(weightLogsProvider.notifier).addEntry(double.parse(_weightController.text));
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log your weight', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _weightController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              validator: (v) => Validators.positiveDouble(v, fieldName: 'Weight'),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(label: 'Save', isLoading: _isSaving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
