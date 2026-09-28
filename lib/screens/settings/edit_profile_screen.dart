import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_profile.dart';
import '../../providers/profile_providers.dart';
import '../../utils/bmi_calculator.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/common/primary_button.dart';
import '../onboarding/widgets/gender_selector.dart';
import '../onboarding/widgets/goal_selector.dart';

/// Edits the existing user profile in place (as opposed to onboarding, which
/// creates it for the first time).
class EditProfileScreen extends ConsumerStatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.profile.name);
  late final _ageController = TextEditingController(text: widget.profile.age.toString());
  late final _heightController = TextEditingController(text: widget.profile.heightCm.toString());
  late final _weightController = TextEditingController(text: widget.profile.weightKg.toString());
  late Gender _gender = widget.profile.gender;
  late FitnessGoal _goal = widget.profile.goal;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    try {
      final heightCm = double.parse(_heightController.text);
      final weightKg = double.parse(_weightController.text);
      final bmi = BmiCalculator.calculate(weightKg: weightKg, heightCm: heightCm);

      await ref.read(profileProvider.notifier).saveProfile(widget.profile.copyWith(
            name: _nameController.text.trim(),
            age: int.parse(_ageController.text),
            heightCm: heightCm,
            weightKg: weightKg,
            gender: _gender,
            goal: _goal,
            bmi: bmi,
            bmiCategory: BmiCalculator.categorize(bmi),
            updatedAt: DateTime.now(),
          ));
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => Validators.requiredText(v, fieldName: 'Name'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
              validator: Validators.ageRange,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Height (cm)'),
                    validator: (v) => Validators.positiveDouble(v, fieldName: 'Height'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                    validator: (v) => Validators.positiveDouble(v, fieldName: 'Weight'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Gender', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            GenderSelector(selected: _gender, onChanged: (g) => setState(() => _gender = g)),
            const SizedBox(height: AppSpacing.lg),
            Text('Fitness goal', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            GoalSelector(selected: _goal, onChanged: (g) => setState(() => _goal = g)),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(label: 'Save Changes', isLoading: _isSaving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
