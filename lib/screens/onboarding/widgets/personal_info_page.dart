import 'package:flutter/material.dart';

import '../../../models/user_profile.dart';
import '../../../utils/constants.dart';
import '../../../utils/validators.dart';
import 'gender_selector.dart';

/// Onboarding page 2: name, age and gender.
class PersonalInfoPage extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController ageController;
  final Gender? gender;
  final ValueChanged<Gender> onGenderChanged;

  const PersonalInfoPage({
    super.key,
    required this.nameController,
    required this.ageController,
    required this.gender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us about yourself', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (v) => Validators.requiredText(v, fieldName: 'Name'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Age'),
            validator: Validators.ageRange,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Gender', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          GenderSelector(selected: gender, onChanged: onGenderChanged),
        ],
      ),
    );
  }
}
