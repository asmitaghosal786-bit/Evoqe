import 'package:flutter/material.dart';

class DefaultAvatar extends StatelessWidget {
  const DefaultAvatar({
    super.key,
    required this.gender,
    this.profile = 'front',
    this.showLabel = false,
  });

  final String? gender;
  final String profile;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final normalizedGender = gender?.toLowerCase();
    final genderIcon = normalizedGender == 'male'
        ? Icons.male
        : normalizedGender == 'female'
        ? Icons.female
        : Icons.person_outline_rounded;
    final profileLabel = switch (profile) {
      'portrait' => 'Portrait',
      'front' => 'Front',
      'back' => 'Back',
      'left' => 'Left',
      'right' => 'Right',
      _ => 'Front',
    };
    final genderLabel = gender ?? 'Default';

    return Semantics(
      label: '$genderLabel default avatar, $profileLabel profile',
      child: Container(
        color: const Color(0xFFE2DDD3),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.accessibility_new_rounded,
              size: 96,
              color: const Color(0xFF6E6760),
            ),
            const SizedBox(height: 8),
            Icon(genderIcon, color: const Color(0xFF3E3129), size: 24),
            if (showLabel) ...[
              const SizedBox(height: 6),
              Text(
                '$genderLabel · $profileLabel',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5A544D),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
